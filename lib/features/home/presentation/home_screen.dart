import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/section_title.dart';
import '../state/home_controller.dart';
import 'widgets/connected_banks.dart';
import 'widgets/net_worth_card.dart';
import 'widgets/top_bar.dart';
import 'widgets/transaction_list.dart';
import 'widgets/uma_insight_strip.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () => ref.read(homeControllerProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.only(top: 6, bottom: 130),
          children: [
            const TopBar(),
            NetWorthCard(
              balance: state.banks.isEmpty
                  ? 0
                  : state.banks
                      .fold<double>(0, (sum, bank) => sum + bank.balance),
              lastUpdatedLabel: state.refreshedLabel,
              refreshing: state.refreshing,
            ),
            SectionTitle(
              title: 'Connected accounts',
              actionLabel: state.refreshing ? 'Syncing...' : 'Refresh',
              onAction: () =>
                  ref.read(homeControllerProvider.notifier).refresh(),
            ),
            ConnectedBanks(banks: state.banks),
            UmaInsightStrip(text: state.insight),
            SectionTitle(
              title: 'Recent transactions',
              actionLabel: '${state.transactions.length} items',
            ),
            TransactionList(transactions: state.transactions),
          ],
        ),
      ),
    );
  }
}
