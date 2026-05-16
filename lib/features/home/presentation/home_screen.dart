import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/section_title.dart';
import '../../receipt_scan/presentation/receipt_scan_sheet.dart';
import '../../statement_import/presentation/statement_import_sheet.dart';
import '../../uma_chat/presentation/open_uma.dart';
import '../data/bank.dart';
import '../data/savings_summary.dart';
import '../data/transaction.dart';
import '../data/upcoming_bill.dart';
import '../state/home_controller.dart';
import 'widgets/add_bank_sheet.dart';
import 'widgets/bank_actions_sheet.dart';
import 'widgets/category_budget_card.dart';
import 'widgets/connected_banks.dart';
import 'widgets/credit_summary_card.dart';
import 'widgets/goal_card.dart';
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
    final l10n = context.l10n;
    openUma(
      context,
      ref,
      prompt:
          l10n.billDetailPrompt(bill.name, fmtTL(bill.amount), bill.daysUntilDue),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);
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
              onSend: () =>
                  openUma(context, ref, prompt: l10n.umaPromptSend),
              onRequest: () =>
                  openUma(context, ref, prompt: l10n.umaPromptRequest),
              onTopUp: () =>
                  openUma(context, ref, prompt: l10n.umaPromptTopUp),
              onPay: () => openUma(context, ref, prompt: l10n.umaPromptPay),
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
            SectionTitle(title: l10n.upcomingBills),
            UpcomingBillsStrip(
              bills: kUpcomingBills,
              onBillTap: (bill) => _openBillDetail(context, ref, bill),
            ),
            SectionTitle(
              title: l10n.connectedAccounts,
              actionLabel: state.refreshing ? l10n.syncingDots : l10n.refresh,
              onAction: () =>
                  ref.read(homeControllerProvider.notifier).refresh(),
            ),
            ConnectedBanks(
              banks: state.banks,
              onBankTap: (bank) => _openBankActions(context, bank),
              onBankLongPress: (bank) => _openBankActions(context, bank),
              onAddBankTap: () => _openAddBank(context),
            ),
            UmaInsightStrip(
              text: state.insight,
              onTap: () => openUma(context, ref),
            ),
            CategoryBudgetCard(
              transactions: state.transactions,
              onTap: () =>
                  openUma(context, ref, prompt: l10n.umaPromptAnalyze),
            ),
            const CreditSummaryCard(),
            SectionTitle(
              title: l10n.recentTransactions,
              actionLabel: l10n.itemsCount(state.transactions.length),
            ),
            TransactionList(
              transactions: state.transactions,
              onTap: (txn) => _openTxnDetail(context, txn),
            ),
          ],
        ),
      ),
    );
  }
}
