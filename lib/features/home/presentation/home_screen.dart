import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../shared/widgets/section_title.dart';
import '../../receipt_scan/presentation/receipt_scan_sheet.dart';
import '../../statement_import/presentation/statement_import_sheet.dart';
import '../../uma_chat/presentation/open_uma.dart';
import '../data/bank.dart';
import '../data/savings_summary.dart';
import '../data/transaction.dart';
import '../data/upcoming_bill.dart';
import '../state/home_controller.dart';
import '../state/spending_insight_controller.dart';
import '../state/upcoming_bills_controller.dart';
import 'widgets/add_bank_sheet.dart';
import 'widgets/add_bill_sheet.dart';
import 'widgets/add_manual_transaction_sheet.dart';
import 'widgets/bank_actions_sheet.dart';
import 'widgets/category_budget_card.dart';
import 'widgets/connected_banks.dart';
import 'widgets/credit_summary_card.dart';
import 'widgets/goal_card.dart';
import 'widgets/home_first_steps_card.dart';
import 'widgets/net_worth_card.dart';
import 'widgets/notification_center_sheet.dart';
import 'widgets/proactive_insight_card.dart';
import 'widgets/savings_story_card.dart';
import 'widgets/top_bar.dart';
import 'widgets/transaction_detail_sheet.dart';
import 'widgets/transaction_list.dart';
import 'widgets/uma_insight_strip.dart';
import 'widgets/upcoming_bills_strip.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openScanner(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => const ReceiptScanSheet(),
    );
  }

  void _openAddBank(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => const AddBankSheet(),
    );
  }

  void _openBankActions(BuildContext context, Bank bank) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => BankActionsSheet(bank: bank),
    );
  }

  void _openStatementImport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => const StatementImportSheet(),
    );
  }

  void _openNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => const NotificationCenterSheet(),
    );
  }

  void _openTxnDetail(BuildContext context, Txn txn) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => TransactionDetailSheet(txn: txn),
    );
  }

  void _openBillDetail(BuildContext context, WidgetRef ref, UpcomingBill bill) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => AddBillSheet(initial: bill),
    );
  }

  void _openAddBill(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => const AddBillSheet(),
    );
  }

  void _openAddManualTransaction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => const AddManualTransactionSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);
    final bills = ref.watch(upcomingBillsControllerProvider);
    final insight = ref.watch(spendingInsightControllerProvider);
    final l10n = context.l10n;
    final savings = summarizeSavings(state.transactions);
    final hasTransactions = state.transactions.isNotEmpty;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () => ref.read(homeControllerProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.only(top: 6, bottom: 130),
          children: [
            TopBar(
              onScanTap: () => _openScanner(context),
              onImportTap: () => _openStatementImport(context),
              onNotificationsTap: () => _openNotifications(context),
            ),
            NetWorthCard(
              balance: state.banks.isEmpty
                  ? 0
                  : state.banks
                      .fold<double>(0, (sum, bank) => sum + bank.balance),
              monthDelta: savings.income - savings.spending,
              lastUpdatedLabel: state.lastUpdatedTime == null
                  ? l10n.firstSyncPending
                  : l10n.updatedAt(state.lastUpdatedTime!),
              refreshing: state.refreshing,
              history: state.history,
              onSend: () =>
                  openUma(context, ref, prompt: l10n.umaPromptSend),
              onRequest: () =>
                  openUma(context, ref, prompt: l10n.umaPromptRequest),
              onTopUp: () =>
                  openUma(context, ref, prompt: l10n.umaPromptTopUp),
              onPay: () => openUma(context, ref, prompt: l10n.umaPromptPay),
            ),
            if (!hasTransactions && state.banks.isEmpty)
              HomeFirstStepsCard(
                onImport: () => _openStatementImport(context),
                onScan: () => _openScanner(context),
                onAddBank: () => _openAddBank(context),
              ),
            if (hasTransactions)
              SavingsStoryCard(
                savedAmount: savings.saved,
                deltaPercent: savings.deltaPercent,
                onTap: () =>
                    openUma(context, ref, prompt: l10n.umaPromptAnalyze),
              ),
            const GoalCard(),
            const ProactiveInsightCard(),
            SectionTitle(
              title: l10n.upcomingBills,
              actionLabel: '+ ${l10n.actionAdd}',
              onAction: () => _openAddBill(context),
            ),
            UpcomingBillsStrip(
              bills: bills,
              onBillTap: (bill) => _openBillDetail(context, ref, bill),
              onAddTap: () => _openAddBill(context),
            ),
            SectionTitle(
              title: l10n.connectedAccounts,
              actionLabel: state.banks.isEmpty
                  ? '+ ${l10n.actionAdd}'
                  : (state.refreshing ? l10n.syncingDots : l10n.refresh),
              onAction: () => state.banks.isEmpty
                  ? _openAddBank(context)
                  : ref.read(homeControllerProvider.notifier).refresh(),
            ),
            ConnectedBanks(
              banks: state.banks,
              onBankTap: (bank) => _openBankActions(context, bank),
              onBankLongPress: (bank) => _openBankActions(context, bank),
              onAddBankTap: () => _openAddBank(context),
            ),
            UmaInsightStrip(
              text: insight.text.isEmpty ? state.insight : insight.text,
              loading: insight.loading,
              ctaLabel: !hasTransactions
                  ? (state.banks.isEmpty
                      ? l10n.umaInsightImportCta
                      : l10n.umaInsightAddFirstTxnCta)
                  : l10n.umaInsightDeepenCta,
              onTap: () {
                if (!hasTransactions && state.banks.isEmpty) {
                  _openStatementImport(context);
                  return;
                }
                if (!hasTransactions) {
                  _openAddManualTransaction(context);
                  return;
                }
                openUma(context, ref, prompt: l10n.umaPromptAnalyze);
              },
            ),
            CategoryBudgetCard(
              transactions: state.transactions,
              onTap: () =>
                  openUma(context, ref, prompt: l10n.umaPromptAnalyze),
            ),
            const CreditSummaryCard(),
            SectionTitle(
              title: l10n.recentTransactions,
              actionLabel: state.transactions.isEmpty
                  ? '+ ${l10n.actionAdd}'
                  : '+ ${l10n.actionAdd} (${state.transactions.length})',
              onAction: () => _openAddManualTransaction(context),
            ),
            TransactionList(
              transactions: state.transactions,
              onTap: (txn) => _openTxnDetail(context, txn),
              onAddManual: () => _openAddManualTransaction(context),
              onScan: () => _openScanner(context),
              onImport: () => _openStatementImport(context),
            ),
          ],
        ),
      ),
    );
  }
}
