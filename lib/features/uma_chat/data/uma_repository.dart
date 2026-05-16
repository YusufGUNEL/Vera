import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/utils/formatters.dart';
import '../../home/data/category_summary.dart';
import '../../home/state/goals_controller.dart';
import '../../home/state/home_controller.dart';
import '../../subscriptions/state/subscriptions_controller.dart';
import '../domain/uma_intent.dart';
import '../domain/uma_message.dart';
import 'intent_router.dart';

class UmaRepository {
  UmaRepository(this._gemini, this._router, this._ref);

  final GeminiService _gemini;
  final IntentRouter _router;
  final Ref _ref;

  AppStrings get _strings => AppStrings(_ref.read(localeControllerProvider));

  Future<UmaMessage> handle(String userText) async {
    final intent = _router.parse(userText);
    final l10n = _strings;

    switch (intent.type) {
      case UmaIntentType.buyGold:
        final banks = _ref.read(homeControllerProvider).banks;
        final primary =
            banks.isEmpty ? 'Garanti BBVA' : banks.first.name;
        final last4 = banks.isEmpty ? '••••' : banks.first.last4;
        return UmaMessage(
          role: UmaRole.uma,
          text: l10n.umaReplyBuyGold(primary),
          card: OrderCard(
            type: UmaActionType.buyGold,
            title: l10n.orderTitleBuyGold,
            from: '${l10n.connectedAccounts} · $primary $last4',
            to: '$primary Gold',
            amount: 29840,
            bankApp: primary,
            detailLabel: l10n.orderTitleGoldRate,
            detailValue: 'TL 2.984/g',
          ),
        );
      case UmaIntentType.payCreditCard:
        final banks = _ref.read(homeControllerProvider).banks;
        // pick a bank that "looks" like the credit card bill target — fall
        // back to the second bank or the first.
        final bank = banks.length > 1 ? banks[1] : (banks.isNotEmpty ? banks.first : null);
        final bankName = bank?.name ?? 'Akbank';
        return UmaMessage(
          role: UmaRole.uma,
          text: l10n.umaReplyPayCard(bankName),
          card: OrderCard(
            type: UmaActionType.payCreditCard,
            title: l10n.orderTitlePayCard,
            from: '${l10n.connectedAccounts} · $bankName ${bank?.last4 ?? '••••'}',
            to: bankName,
            amount: 12450,
            bankApp: bankName,
            detailLabel: l10n.orderTitleDue,
            detailValue: l10n.orderTitleDueToday,
          ),
        );
      case UmaIntentType.moveToSavings:
        final goal = _ref.read(goalsControllerProvider);
        const moveAmount = 2500.0;
        final after = goal.target <= 0
            ? 0
            : (((goal.saved + moveAmount) / goal.target) * 100)
                .clamp(0, 100)
                .round();
        final banks = _ref.read(homeControllerProvider).banks;
        final source =
            banks.isEmpty ? 'Yapı Kredi' : banks.first.name;
        final last4 = banks.isEmpty ? '••••' : banks.first.last4;
        return UmaMessage(
          role: UmaRole.uma,
          text: l10n.umaReplyMoveSavings(after),
          card: OrderCard(
            type: UmaActionType.moveToSavings,
            title: l10n.goalEmergencyFund,
            from: '$source $last4',
            to: l10n.goalEmergencyFund,
            amount: moveAmount,
            bankApp: source,
            detailLabel: l10n.goalsSectionTitle,
            detailValue: '$after%',
          ),
        );
      case UmaIntentType.showSubscriptions:
        final subs = _ref.read(subscriptionsControllerProvider);
        if (subs.items.isEmpty) {
          return UmaMessage(
            role: UmaRole.uma,
            text: l10n.umaReplySubscriptionsEmpty(),
          );
        }
        return UmaMessage(
          role: UmaRole.uma,
          text: l10n.umaReplySubscriptions(
            subs.items.length,
            fmtTL(subs.monthlyTotal),
          ),
        );
      case UmaIntentType.analyzeSpending:
        final txns = _ref.read(homeControllerProvider).transactions;
        final spending =
            summarizeSpending(txns, otherLabel: l10n.categoryOther);
        if (spending.isEmpty) {
          return UmaMessage(
            role: UmaRole.uma,
            text: l10n.umaReplyAnalyzeEmpty(),
          );
        }
        final top = spending.first;
        final total = totalSpending(spending);
        return UmaMessage(
          role: UmaRole.uma,
          text: l10n.umaReplyAnalyze(
            top.category,
            fmtTL(top.amount),
            fmtTL(total),
          ),
        );
      case UmaIntentType.explainWealth:
        return UmaMessage(
          role: UmaRole.uma,
          text: l10n.umaReplyExplainWealth,
        );
      case UmaIntentType.checkLoanEligibility:
        return UmaMessage(
          role: UmaRole.uma,
          text: l10n.umaReplyLoan,
        );
      case UmaIntentType.explainSecurityAlert:
        return UmaMessage(
          role: UmaRole.uma,
          text: l10n.umaReplySecurity,
        );
      case UmaIntentType.unknown:
        break;
    }

    try {
      final reply = await _gemini.generateText(_systemPrompt(userText));
      return UmaMessage(role: UmaRole.uma, text: reply.trim());
    } catch (_) {
      return UmaMessage(role: UmaRole.uma, text: l10n.umaReplyFallback);
    }
  }

  String _systemPrompt(String userText) {
    return '''
You are Uma, the AI coach inside Vera, a Turkish personal finance app.
Vera does NOT execute bank transactions itself. It analyzes the user's data
(imported statements, receipts, screenshots, manual entries) and forwards
real actions to the user's bank app for them to confirm.

Tone: warm, concise (1-3 sentences), helpful. Use TL when relevant.
Never invent specific transaction history or prices the user hasn't asked about.
Never claim Vera will move money. If the user wants an action, say you will
open the right bank app and that they'll confirm there.

User: $userText
Uma:''';
  }
}

final umaRepositoryProvider = Provider<UmaRepository>((ref) {
  return UmaRepository(
    ref.watch(geminiServiceProvider),
    ref.watch(intentRouterProvider),
    ref,
  );
});
