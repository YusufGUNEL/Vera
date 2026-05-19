import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/services/gemini_service.dart';
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
  SubscriptionsRepository(this._parser, this._gemini);

  final RecurringTransactionParser _parser;
  final GeminiService _gemini;

  Future<List<SubscriptionItem>> getSubscriptions({
    List<Txn> userTxns = const [],
    required AppStrings l10n,
  }) async {
    if (userTxns.isEmpty) return const [];
    final candidates = _parser.detectSubscriptions(userTxns, l10n);
    if (candidates.isEmpty) return candidates;

    if (_gemini.isAvailable) {
      try {
        final prompt = '''
You are an expert financial assistant analyzing bank transactions to detect recurring subscriptions.
Here is a list of candidate subscriptions detected by simple keyword matching:
\${candidates.map((c) => '- ID: \${c.id}, Name: \${c.name}, Monthly Price: \${c.monthlyPrice} TL, Vendor: \${c.vendor}, Category: \${c.category}').join('\\n')}

Analyze these candidates and determine which ones are actual recurring subscriptions (like software licenses, streaming services, gym memberships, utilities, SaaS, cloud storage, etc.) and which ones are likely NOT subscriptions (like one-off retail purchases of hardware, personal money transfers, rent/bills, one-off hotel/flight bookings, salary, etc.).

Output only a valid JSON array containing the IDs of the VALID subscriptions to keep, for example:
["detected_netflix", "detected_spotify"]

Do not include markdown code blocks, do not include any other text, just the raw JSON array.
''';
        final responseText = await _gemini.generateText(prompt);
        final cleanText = responseText.replaceAll('```json', '').replaceAll('```', '').trim();
        final List<dynamic> validIds = jsonDecode(cleanText);
        final validSet = validIds.map((id) => id.toString()).toSet();
        return candidates.where((c) => validSet.contains(c.id)).toList();
      } catch (_) {
        return candidates;
      }
    }
    return candidates;
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
  return SubscriptionsRepository(
    ref.watch(recurringTransactionParserProvider),
    ref.watch(geminiServiceProvider),
  );
});
