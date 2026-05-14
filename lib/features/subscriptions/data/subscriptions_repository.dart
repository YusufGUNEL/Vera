import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/data/transaction.dart';
import '../domain/subscription_alert.dart';
import '../domain/subscription_item.dart';
import '../domain/subscription_status.dart';
import 'recurring_transaction_parser.dart';

class SubscriptionsRepository {
  SubscriptionsRepository(this._parser);

  final RecurringTransactionParser _parser;

  List<SubscriptionItem> getSubscriptions() {
    final detectedVendors =
        _parser.detectVendors(kTransactions.map((txn) => txn.name).toList());

    final items = <SubscriptionItem>[
      SubscriptionItem(
        id: 'netflix',
        name: 'Netflix Premium',
        vendor: 'Netflix',
        category: 'Entertainment',
        monthlyPrice: 150,
        previousPrice: detectedVendors.contains('Netflix') ? 129 : 150,
        renewalLabel: 'Renews in 2 days',
        lastUsedLabel: 'Last watched 18 days ago',
        status: SubscriptionStatus.priceIncreased,
        recommendation: 'Downgrade one tier or pause until next month.',
        icon: Icons.movie_outlined,
      ),
      const SubscriptionItem(
        id: 'spotify',
        name: 'Spotify Family',
        vendor: 'Spotify',
        category: 'Music',
        monthlyPrice: 100,
        previousPrice: 100,
        renewalLabel: 'Renews in 12 days',
        lastUsedLabel: 'Used this morning',
        status: SubscriptionStatus.healthy,
        recommendation: 'Keep active. High usage across your household.',
        icon: Icons.headphones_outlined,
      ),
      const SubscriptionItem(
        id: 'youtube-premium',
        name: 'YouTube Premium',
        vendor: 'Google',
        category: 'Video',
        monthlyPrice: 58,
        previousPrice: 58,
        renewalLabel: 'Renews tomorrow',
        lastUsedLabel: 'No activity in 27 days',
        status: SubscriptionStatus.unused,
        recommendation:
            'Freeze this plan and save monthly without losing history.',
        icon: Icons.smart_display_outlined,
        canFreeze: true,
      ),
      const SubscriptionItem(
        id: 'icloud',
        name: 'iCloud+ 200 GB',
        vendor: 'Apple',
        category: 'Storage',
        monthlyPrice: 40,
        previousPrice: 40,
        renewalLabel: 'Renews in 5 days',
        lastUsedLabel: 'Storage 92% full',
        status: SubscriptionStatus.renewalSoon,
        recommendation:
            'Keep active, but review annual storage cost next cycle.',
        icon: Icons.cloud_outlined,
      ),
    ];

    return items;
  }

  List<SubscriptionAlert> buildAlerts(List<SubscriptionItem> items) {
    final savings = estimatedMonthlySavings(items);
    final priceUpItems =
        items.where((item) => item.status == SubscriptionStatus.priceIncreased);
    final unusedItems =
        items.where((item) => item.status == SubscriptionStatus.unused).length;

    return [
      SubscriptionAlert(
        title: 'Potential monthly savings',
        message:
            'Vera found subscriptions you can pause or downgrade without hurting your routine.',
        metricLabel: 'SAVE',
        metricValue: 'TL ${savings.toStringAsFixed(0)}',
      ),
      SubscriptionAlert(
        title: 'Price increase detected',
        message: priceUpItems.isEmpty
            ? 'No unusual price jumps detected this cycle.'
            : 'One or more plans increased in price compared with last month.',
        metricLabel: 'RAISED',
        metricValue: '${priceUpItems.length}',
      ),
      SubscriptionAlert(
        title: 'Low-usage plans',
        message: unusedItems == 0
            ? 'All subscriptions show healthy engagement.'
            : '$unusedItems plan looks underused based on your recent activity pattern.',
        metricLabel: 'IDLE',
        metricValue: '$unusedItems',
      ),
    ];
  }

  String buildInsight(List<SubscriptionItem> items) {
    final savings = estimatedMonthlySavings(items);
    final needsAttention =
        items.where((item) => item.status.needsAttention).length;

    if (needsAttention == 0) {
      return 'Your subscriptions look healthy this month. No immediate savings leak stands out.';
    }

    return 'You have $needsAttention subscriptions that deserve a quick review. Vera estimates you can recover around TL ${savings.toStringAsFixed(0)} per month by pausing unused plans and downgrading recent price increases.';
  }

  double estimatedMonthlySavings(List<SubscriptionItem> items) {
    return items.fold<double>(0, (sum, item) {
      return switch (item.status) {
        SubscriptionStatus.unused => sum + item.monthlyPrice,
        SubscriptionStatus.priceIncreased =>
          sum + item.priceDelta.clamp(0, 9999),
        SubscriptionStatus.renewalSoon => sum + 0,
        SubscriptionStatus.healthy => sum + 0,
      };
    });
  }
}

final recurringTransactionParserProvider = Provider<RecurringTransactionParser>(
  (ref) => const RecurringTransactionParser(),
);

final subscriptionsRepositoryProvider =
    Provider<SubscriptionsRepository>((ref) {
  return SubscriptionsRepository(ref.watch(recurringTransactionParserProvider));
});
