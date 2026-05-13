import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/section_title.dart';
import '../state/balance_controller.dart';
import 'widgets/connected_banks.dart';
import 'widgets/net_worth_card.dart';
import 'widgets/top_bar.dart';
import 'widgets/transaction_list.dart';
import 'widgets/uma_insight_strip.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(balanceProvider);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(top: 6, bottom: 130),
        children: [
          const TopBar(),
          NetWorthCard(balance: balance),
          const SectionTitle(title: 'Connected accounts', actionLabel: 'Manage'),
          const ConnectedBanks(),
          const UmaInsightStrip(
            text:
                'You spent ₺312 less on dining out this week. Want me to move it to savings?',
          ),
          const SectionTitle(title: 'Recent transactions', actionLabel: 'See all'),
          const TransactionList(),
        ],
      ),
    );
  }
}
