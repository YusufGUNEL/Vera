import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../home/data/imported_transactions_store.dart';
import '../../home/data/transaction.dart';
import '../../home/data/upcoming_bill.dart';
import '../../home/state/goals_controller.dart';
import '../../home/state/home_controller.dart';
import '../../home/state/upcoming_bills_controller.dart';

/// Tool names exposed to Gemini. Keep these in sync with the
/// [umaTools] declaration list and the dispatch switch in [executeUmaTool].
class UmaToolNames {
  static const createSavingsGoal = 'create_savings_goal';
  static const addUpcomingBill = 'add_upcoming_bill';
  static const addExpense = 'add_expense';
}

/// Declarations passed to Gemini so the model knows what Uma can actually do.
/// Schemas are kept narrow on purpose — the simpler the contract, the more
/// reliably small models pick the right tool and fill the args.
final List<Tool> umaTools = [
  Tool(functionDeclarations: [
    FunctionDeclaration(
      UmaToolNames.createSavingsGoal,
      'Create or replace the user\'s primary savings goal in Turkish Lira. '
          'Use only when the user explicitly asks to set a goal '
          '(e.g. "100k acil durum fonu oluştur", "create a 50000 emergency fund").',
      Schema.object(
        properties: {
          'target_amount_tl': Schema.number(
            description: 'Goal target amount in Turkish Lira (TL).',
          ),
          'monthly_contribution_tl': Schema.number(
            description:
                'Optional monthly amount the user plans to set aside, in TL. '
                'Pass 0 if not stated.',
          ),
        },
        requiredProperties: ['target_amount_tl'],
      ),
    ),
    FunctionDeclaration(
      UmaToolNames.addUpcomingBill,
      'Add a new upcoming bill to the user\'s tracked bills list. '
          'Use when the user asks to remember/track a payment that is due soon.',
      Schema.object(
        properties: {
          'name': Schema.string(
            description: 'Short human-readable bill name, e.g. "Elektrik".',
          ),
          'amount_tl': Schema.number(
            description: 'Bill amount in Turkish Lira.',
          ),
          'due_in_days': Schema.integer(
            description:
                'How many days from now the bill is due. 0 = today, 7 = next week.',
          ),
        },
        requiredProperties: ['name', 'amount_tl', 'due_in_days'],
      ),
    ),
    FunctionDeclaration(
      UmaToolNames.addExpense,
      'Log a manual expense transaction the user just told Uma about. '
          'Do NOT use for incoming money or transfers between own accounts.',
      Schema.object(
        properties: {
          'name': Schema.string(
            description: 'Merchant or short description, e.g. "Migros".',
          ),
          'amount_tl': Schema.number(
            description:
                'Positive amount in Turkish Lira. The tool will store it as a debit.',
          ),
          'category': Schema.string(
            description:
                'Optional category in plain Turkish or English, e.g. "market", '
                '"fuel", "restaurant". Empty if unsure.',
          ),
        },
        requiredProperties: ['name', 'amount_tl'],
      ),
    ),
  ]),
];

/// Outcome of a tool execution that the repository can surface to the user.
class UmaToolOutcome {
  const UmaToolOutcome({
    required this.toolName,
    required this.success,
    required this.confirmation,
  });

  final String toolName;
  final bool success;
  final String confirmation;
}

/// Dispatches a Gemini function call to the right controller. Returns the
/// raw map sent back to the model AND records a localized confirmation for
/// the caller to use as the final reply text.
Future<({Map<String, Object?> response, UmaToolOutcome outcome})>
    executeUmaTool({
  required String name,
  required Map<String, Object?> args,
  required Ref ref,
  required AppStrings l10n,
}) async {
  switch (name) {
    case UmaToolNames.createSavingsGoal:
      final target = _asDouble(args['target_amount_tl']) ?? 0;
      final monthly = _asDouble(args['monthly_contribution_tl']) ?? 0;
      if (target <= 0) {
        return (
          response: {'error': 'invalid_target'},
          outcome: UmaToolOutcome(
            toolName: name,
            success: false,
            confirmation: '',
          ),
        );
      }
      await ref.read(goalsControllerProvider.notifier).setGoal(
            target: target,
            monthlyContribution: monthly,
          );
      return (
        response: {
          'success': true,
          'target_tl': target,
          'monthly_tl': monthly,
        },
        outcome: UmaToolOutcome(
          toolName: name,
          success: true,
          confirmation: l10n.umaToolGoalCreated(fmtTL(target)),
        ),
      );

    case UmaToolNames.addUpcomingBill:
      final billName = (args['name'] as String?)?.trim();
      final amount = _asDouble(args['amount_tl']);
      final days = _asInt(args['due_in_days']);
      if (billName == null || billName.isEmpty || amount == null || amount <= 0 || days == null) {
        return (
          response: {'error': 'invalid_args'},
          outcome: UmaToolOutcome(
            toolName: name,
            success: false,
            confirmation: '',
          ),
        );
      }
      final today = DateTime.now();
      final due = DateTime(today.year, today.month, today.day)
          .add(Duration(days: days));
      await ref.read(upcomingBillsControllerProvider.notifier).add(
            UpcomingBill(
              id: 'uma-${DateTime.now().millisecondsSinceEpoch}',
              name: billName,
              amount: amount,
              dueDate: due,
              iconCode: Icons.receipt_long_outlined.codePoint,
              accentColor: 0xFF7C3AED,
            ),
          );
      return (
        response: {'success': true, 'name': billName, 'days': days},
        outcome: UmaToolOutcome(
          toolName: name,
          success: true,
          confirmation: l10n.umaToolBillAdded(billName, days),
        ),
      );

    case UmaToolNames.addExpense:
      final txnName = (args['name'] as String?)?.trim();
      final amount = _asDouble(args['amount_tl']);
      final category = (args['category'] as String?)?.trim();
      if (txnName == null || txnName.isEmpty || amount == null || amount <= 0) {
        return (
          response: {'error': 'invalid_args'},
          outcome: UmaToolOutcome(
            toolName: name,
            success: false,
            confirmation: '',
          ),
        );
      }
      final palette = iconAndColorForCategory(category);
      final now = DateTime.now();
      final time =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      await ref.read(homeControllerProvider.notifier).addImportedTransactions([
        Txn(
          id: now.millisecondsSinceEpoch ~/ 1000,
          name: txnName,
          category: category == null || category.isEmpty
              ? l10n.categoryOther
              : category,
          icon: palette.icon,
          amount: -amount.abs(),
          when: l10n.todayAt(time),
          color: palette.color,
        ),
      ]);
      return (
        response: {'success': true, 'name': txnName},
        outcome: UmaToolOutcome(
          toolName: name,
          success: true,
          confirmation:
              l10n.umaToolExpenseAdded(txnName, fmtTL(amount.abs())),
        ),
      );

    default:
      return (
        response: {'error': 'unknown_tool'},
        outcome: UmaToolOutcome(
          toolName: name,
          success: false,
          confirmation: '',
        ),
      );
  }
}

double? _asDouble(Object? v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

int? _asInt(Object? v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}
