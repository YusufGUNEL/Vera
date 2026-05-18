import 'package:flutter/material.dart';

import '../../../core/localization/app_strings.dart';
import '../../home/data/transaction.dart';
import '../domain/subscription_item.dart';
import '../domain/subscription_status.dart';

/// Known subscription vendors → (display name, category, icon).
/// Used to recognize a transaction line as a subscription even if it only
/// appears once. Lowercase keyword fragments.
const _kSubscriptionCatalog = <String, _CatalogEntry>{
  'netflix': _CatalogEntry(
    name: 'Netflix',
    categoryKey: 'entertainment',
    icon: Icons.movie_outlined,
  ),
  'spotify': _CatalogEntry(
    name: 'Spotify',
    categoryKey: 'music',
    icon: Icons.headphones_outlined,
  ),
  'youtube': _CatalogEntry(
    name: 'YouTube Premium',
    categoryKey: 'video',
    icon: Icons.smart_display_outlined,
  ),
  'icloud': _CatalogEntry(
    name: 'iCloud+',
    categoryKey: 'storage',
    icon: Icons.cloud_outlined,
  ),
  'apple': _CatalogEntry(
    name: 'Apple Services',
    categoryKey: 'storage',
    icon: Icons.apple,
  ),
  'amazon prime': _CatalogEntry(
    name: 'Amazon Prime',
    categoryKey: 'entertainment',
    icon: Icons.shopping_bag_outlined,
  ),
  'disney': _CatalogEntry(
    name: 'Disney+',
    categoryKey: 'entertainment',
    icon: Icons.movie_outlined,
  ),
  'exxen': _CatalogEntry(
    name: 'Exxen',
    categoryKey: 'entertainment',
    icon: Icons.movie_outlined,
  ),
  'blutv': _CatalogEntry(
    name: 'BluTV',
    categoryKey: 'entertainment',
    icon: Icons.movie_outlined,
  ),
  'gain': _CatalogEntry(
    name: 'Gain',
    categoryKey: 'entertainment',
    icon: Icons.movie_outlined,
  ),
  'tabii': _CatalogEntry(
    name: 'tabii',
    categoryKey: 'entertainment',
    icon: Icons.movie_outlined,
  ),
  'github': _CatalogEntry(
    name: 'GitHub',
    categoryKey: 'developer',
    icon: Icons.code_outlined,
  ),
  'openai': _CatalogEntry(
    name: 'OpenAI',
    categoryKey: 'ai',
    icon: Icons.smart_toy_outlined,
  ),
  'anthropic': _CatalogEntry(
    name: 'Anthropic',
    categoryKey: 'ai',
    icon: Icons.smart_toy_outlined,
  ),
  'claude': _CatalogEntry(
    name: 'Claude',
    categoryKey: 'ai',
    icon: Icons.smart_toy_outlined,
  ),
};

class RecurringTransactionParser {
  const RecurringTransactionParser();

  /// Legacy keyword detection on names; kept for backwards compat with the
  /// seed list logic that hides "priceIncreased" pill if vendor isn't seen.
  List<String> detectVendors(List<String> transactionNames) {
    final matches = <String>{};
    for (final name in transactionNames) {
      final lower = name.toLowerCase();
      for (final entry in _kSubscriptionCatalog.entries) {
        if (lower.contains(entry.key)) matches.add(entry.value.name);
      }
    }
    return matches.toList()..sort();
  }

  /// Detects subscriptions from a list of user transactions. A txn is flagged
  /// as a subscription if either:
  ///   1. its name matches an entry in [_kSubscriptionCatalog], or
  ///   2. its (normalized name, amount) pair appears 2+ times in the list.
  ///
  /// Returns synthesized [SubscriptionItem]s with sane defaults. Caller is
  /// responsible for deduping against the seed list.
  List<SubscriptionItem> detectSubscriptions(List<Txn> txns, AppStrings l10n) {
    final outgoing = txns.where((t) => t.amount < 0).toList();

    final grouped = <String, _Group>{};
    for (final txn in outgoing) {
      final key = _normalize(txn.name);
      final group = grouped.putIfAbsent(
        key,
        () => _Group(displayName: txn.name, amount: txn.amount.abs()),
      );
      group.count += 1;
      // Track the largest absolute amount we've seen, as the working monthly
      // price guess.
      if (txn.amount.abs() > group.amount) {
        group.amount = txn.amount.abs();
      }
    }

    final items = <SubscriptionItem>[];
    grouped.forEach((key, group) {
      final catalog = _matchCatalog(key);
      final isRecurring = group.count >= 2;
      if (catalog == null && !isRecurring) return;

      final display = catalog?.name ?? group.displayName;
      final id = 'detected_${_slug(key)}';
      items.add(
        SubscriptionItem(
          id: id,
          name: display,
          vendor: display,
          category: catalog?.categoryKey ?? 'other',
          monthlyPrice: group.amount,
          previousPrice: group.amount,
          renewalLabel: l10n.subsDetectedFromImport,
          lastUsedLabel: isRecurring
              ? l10n.subsSeenInRecentTransactions(group.count)
              : l10n.subsKnownVendorLabel,
          status: SubscriptionStatus.unused,
          recommendation: l10n.subsRecommendationDetected,
          icon: catalog?.icon ?? Icons.subscriptions_outlined,
        ),
      );
    });

    return items;
  }

  String _normalize(String s) {
    return s
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _slug(String s) =>
      s.replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'^_|_$'), '');

  _CatalogEntry? _matchCatalog(String normalized) {
    for (final entry in _kSubscriptionCatalog.entries) {
      if (normalized.contains(entry.key)) return entry.value;
    }
    return null;
  }
}

class _Group {
  _Group({required this.displayName, required this.amount});
  final String displayName;
  double amount;
  int count = 0;
}

class _CatalogEntry {
  const _CatalogEntry({
    required this.name,
    required this.categoryKey,
    required this.icon,
  });

  final String name;
  final String categoryKey;
  final IconData icon;
}
