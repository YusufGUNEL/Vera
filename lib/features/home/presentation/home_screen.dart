import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../shared/widgets/section_title.dart';
import '../../receipt_scan/presentation/receipt_scan_sheet.dart';
import '../../statement_import/presentation/statement_import_sheet.dart';
import '../../uma_chat/presentation/uma_chat_sheet.dart';
import '../data/upcoming_bill.dart';
import '../state/home_controller.dart';
import 'widgets/connected_banks.dart';
import 'widgets/credit_summary_card.dart';
import 'widgets/net_worth_card.dart';
import 'widgets/savings_story_card.dart';
import 'widgets/top_bar.dart';
import 'widgets/transaction_list.dart';
import 'widgets/uma_insight_strip.dart';
import 'widgets/upcoming_bills_strip.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openUma(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => const UmaChatSheet(),
    );
  }

  void _openScanner(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => const ReceiptScanSheet(),
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

  void _showSoon(BuildContext context, String label) {
    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label · ${l10n.comingSoon}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);
    final l10n = context.l10n;

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
            ),
            NetWorthCard(
              balance: state.banks.isEmpty
                  ? 0
                  : state.banks
                      .fold<double>(0, (sum, bank) => sum + bank.balance),
              lastUpdatedLabel: state.refreshedLabel,
              refreshing: state.refreshing,
              onSend: () => _showSoon(context, l10n.actionSend),
              onRequest: () => _showSoon(context, l10n.actionRequest),
              onTopUp: () => _showSoon(context, l10n.actionTopUp),
              onPay: () => _showSoon(context, l10n.actionPay),
            ),
            SavingsStoryCard(
              savedAmount: 2480,
              deltaPercent: 14,
              onTap: () => _openUma(context),
            ),
            SectionTitle(title: l10n.upcomingBills),
            UpcomingBillsStrip(
              bills: kUpcomingBills,
              onBillTap: (bill) => _showSoon(context, bill.name),
            ),
            SectionTitle(
              title: l10n.connectedAccounts,
              actionLabel: state.refreshing ? l10n.syncingDots : l10n.refresh,
              onAction: () =>
                  ref.read(homeControllerProvider.notifier).refresh(),
            ),
            ConnectedBanks(
              banks: state.banks,
              onBankTap: (bank) => _showSoon(context, bank.name),
              onAddBankTap: () => _showSoon(context, l10n.connectBank),
            ),
            UmaInsightStrip(
              text: state.insight,
              onTap: () => _openUma(context),
            ),
            const CreditSummaryCard(),
            SectionTitle(
              title: l10n.recentTransactions,
              actionLabel: l10n.itemsCount(state.transactions.length),
            ),
            TransactionList(
              transactions: state.transactions,
              onTap: (txn) => _showSoon(context, txn.name),
            ),
          ],
        ),
      ),
    );
  }
}
