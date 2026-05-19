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
        final candidateLines = candidates
            .map(
              (c) =>
                  '- ID: ${c.id} | Name: ${c.name} | Vendor: ${c.vendor} | '
                  'Category: ${c.category} | Current: ${c.monthlyPrice.toStringAsFixed(2)} TL | '
                  'Previous: ${c.previousPrice.toStringAsFixed(2)} TL | '
                  'Occurrences: ${c.occurrences}',
            )
            .join('\n');

        // Pull the matching raw transactions for each candidate so Gemini can
        // verify whether the merchant truly looks recurring. We cap the per-
        // candidate sample so the prompt stays small.
        final txnSnippets = candidates
            .map((c) {
              final matches = userTxns
                  .where(
                    (txn) =>
                        txn.amount < 0 &&
                        txn.name.toLowerCase().contains(
                              c.vendor.toLowerCase(),
                            ),
                  )
                  .take(6)
                  .map(
                    (txn) =>
                        '    · ${txn.name} | ${txn.amount.toStringAsFixed(2)} TL | ${txn.when}',
                  )
                  .join('\n');
              return matches.isEmpty
                  ? '${c.id}: (no matching raw transaction lines)'
                  : '${c.id}:\n$matches';
            })
            .join('\n');

        final prompt =
            'You are a financial assistant filtering a candidate list of '
            'recurring subscriptions extracted from a user\'s bank statement.\n\n'
            'KEEP only entries that look like real recurring services: '
            'streaming (Netflix, Spotify, YouTube Premium, Disney+, Exxen, '
            'BluTV, Gain, tabii), cloud storage (iCloud, Google One, Dropbox), '
            'SaaS / AI tools (GitHub, OpenAI, Anthropic/Claude, Notion, '
            'Figma), gym & fitness memberships, software licenses, telco / '
            'internet / TV plans, insurance.\n\n'
            'REJECT anything that looks like a one-off purchase or everyday '
            'spending: grocery stores (Migros, BIM, A101, ŞOK, Carrefour, '
            'Macrocenter, neighborhood markets like "MUSTAFA AYTUMUR"), '
            'restaurants, cafes, fast food, gas stations (Shell, OPET, BP, '
            'Petrol Ofisi), pharmacies, hospitals, hotels, flights, ATM '
            'withdrawals, transfers (EFT/Havale/FAST), salary credits, rent '
            'payments, one-off retail.\n\n'
            'Candidates (each line is one candidate):\n$candidateLines\n\n'
            'Raw transaction lines for each candidate:\n$txnSnippets\n\n'
            'Return ONLY a JSON array containing the IDs of the entries you '
            'want to KEEP — no markdown, no commentary, no code fences. '
            'Example: ["detected_netflix","detected_spotify"]. If none are '
            'real subscriptions, return [].';

        final responseText = await _gemini.generateText(prompt);
        final cleanText = responseText
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        if (cleanText.isEmpty) return candidates;
        final List<dynamic> validIds = jsonDecode(cleanText);
        final validSet = validIds.map((id) => id.toString()).toSet();
        final filtered =
            candidates.where((c) => validSet.contains(c.id)).toList();
        // If Gemini returned something obviously broken (e.g. dropped
        // everything but the heuristic said multiple are likely real), keep
        // the heuristic result so we never show an empty Plans list when the
        // user clearly has subscriptions.
        if (filtered.isEmpty && candidates.length >= 2) return candidates;
        return filtered;
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
