import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../home/data/transaction.dart';
import '../domain/subscription_alert.dart';
import '../domain/subscription_item.dart';
import '../domain/subscription_status.dart';
import 'recurring_transaction_parser.dart';

/// Builds the subscription catalogue for the user.
///
/// We do not seed any "famous brand" subscriptions. Everything must come from
/// the user's own transactions (manual entry, statement import, receipt OCR)
/// so the list reflects real spending — never a marketing demo.
class SubscriptionsRepository {
  SubscriptionsRepository(this._parser);

  final RecurringTransactionParser _parser;

  List<SubscriptionItem> getSubscriptions({
    List<Txn> userTxns = const [],
    required AppStrings l10n,
  }) {
    if (userTxns.isEmpty) return const [];
    return _parser.detectSubscriptions(userTxns, l10n);
  }

  List<SubscriptionAlert> buildAlerts(
    List<SubscriptionItem> items,
    AppStrings l10n,
  ) {
    final savings = estimatedMonthlySavings(items);
    final priceUpItems =
        items.where((item) => item.status == SubscriptionStatus.priceIncreased);
    final unusedItems =
        items.where((item) => item.status == SubscriptionStatus.unused).length;

    return [
      SubscriptionAlert(
        title: l10n.subsAlertSavingsTitle,
        message: items.isEmpty
            ? l10n.subsAlertSavingsMessageEmpty
            : l10n.subsAlertSavingsMessageActive,
        metricLabel: l10n.subsAlertSavingsMetric,
        metricValue: '${savings.toStringAsFixed(0)} TL',
      ),
      SubscriptionAlert(
        title: l10n.subsAlertPriceTitle,
        message: priceUpItems.isEmpty
            ? l10n.subsAlertPriceMessageNone
            : l10n.subsAlertPriceMessageSome,
        metricLabel: l10n.subsAlertPriceMetric,
        metricValue: '${priceUpItems.length}',
      ),
      SubscriptionAlert(
        title: l10n.subsAlertUnusedTitle,
        message: unusedItems == 0
            ? l10n.subsAlertUnusedMessageNone
            : l10n.subsAlertUnusedMessageSome(unusedItems),
        metricLabel: l10n.subsAlertUnusedMetric,
        metricValue: '$unusedItems',
      ),
    ];
  }

  String buildInsight(List<SubscriptionItem> items, AppStrings l10n) {
    if (items.isEmpty) {
      return l10n.subsInsightEmpty;
    }
    final savings = estimatedMonthlySavings(items);
    final needsAttention =
        items.where((item) => item.status.needsAttention).length;

    if (needsAttention == 0) {
      return l10n.subsInsightHealthy;
    }

    return l10n.subsInsightNeedsAttention(
      needsAttention,
      '${savings.toStringAsFixed(0)} TL',
    );
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
