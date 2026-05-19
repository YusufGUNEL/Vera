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

/// Merchants we can be confident are NOT subscriptions even if they recur.
/// Lowercase fragments matched against the normalized transaction name.
const _kEverydayMerchantBlocklist = <String>[
  'migros',
  'bim',
  'a101',
  'a-101',
  ' sok ',
  ' şok ',
  'sok market',
  'şok market',
  'carrefour',
  'macrocenter',
  'macro center',
  'mopas',
  'metro',
  'hakmar',
  'file market',
  'tarim kredi',
  'tarım kredi',
  'cigkofteci',
  'çiğköfteci',
  'kasap',
  'manav',
  'firin',
  'fırın',
  'pastane',
  'cafe',
  'kahve',
  'starbucks',
  'kahve dunyasi',
  'kahve dünyası',
  'burger',
  'mcdonalds',
  'mc donalds',
  'kfc',
  'pizza',
  'dominos',
  'sushi',
  'sokak lezzeti',
  'shell',
  'opet',
  'petrol ofisi',
  'lukoil',
  'bp ',
  'aytemiz',
  'total',
  'akaryakit',
  'akaryakıt',
  'eczane',
  'pharmacy',
  'hastane',
  'doktor',
  'restaurant',
  'restoran',
  'lokanta',
  'otel ',
  'hotel ',
  'havayollari',
  'havayolları',
  'thy',
  'pegasus',
  'turkish airlines',
];

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

  /// Detects subscriptions from a list of user transactions.
  ///
  /// We are strict on purpose — the Plans tab should only list things that
  /// look like real recurring services (Netflix, Spotify, gym membership, …)
  /// and never noise from groceries, gas stations, or one-off purchases. A
  /// candidate is kept when:
  ///   1. its name matches a known subscription vendor catalog, OR
  ///   2. its (normalized name, amount) pair appears 2+ times with a
  ///      consistent amount AND the merchant is not on the everyday blocklist.
  ///
  /// Returns synthesized [SubscriptionItem]s with sane defaults. Caller is
  /// responsible for deduping against the seed list and may further filter
  /// with Gemini before showing the list to the user.
  List<SubscriptionItem> detectSubscriptions(List<Txn> txns, AppStrings l10n) {
    final outgoing = txns.where((t) => t.amount < 0).toList();

    final grouped = <String, _Group>{};
    for (final txn in outgoing) {
      final lowerName = txn.name.toLowerCase();
      // Skip obvious transfers/EFTs/ATM/cash flow.
      if (lowerName.contains('eft') ||
          lowerName.contains('havale') ||
          lowerName.contains('transfer') ||
          lowerName.contains('fast') ||
          lowerName.contains('gelen') ||
          lowerName.contains('giden') ||
          lowerName.contains('atm') ||
          lowerName.contains('para çekme') ||
          lowerName.contains('para cekme') ||
          lowerName.contains('odeme') ||
          lowerName.contains('ödeme') ||
          lowerName.contains('iade')) {
        continue;
      }

      final key = _normalize(txn.name);
      if (key.isEmpty) continue;
      final group = grouped.putIfAbsent(
        key,
        () => _Group(displayName: txn.name, normalizedKey: key),
      );
      group.add(txn.amount.abs());
    }

    final items = <SubscriptionItem>[];
    grouped.forEach((key, group) {
      final catalog = _matchCatalog(key);
      final isRecurring = group.count >= 2;
      final isBlockedMerchant = _isEverydayMerchant(key);

      // Catalog vendor — keep it even on a single occurrence.
      if (catalog != null) {
        // Single-occurrence catalog matches still need a sane price band so
        // we don't accidentally promote a one-off Apple Store purchase to a
        // monthly subscription.
        if (!isRecurring) {
          if (catalog.categoryKey == 'ai') return;
          if (group.maxAmount > 1000.0) return;
        }
      } else {
        // No catalog match → demand recurrence AND a consistent amount AND
        // the merchant must not look like a grocery / gas / restaurant.
        if (!isRecurring) return;
        if (isBlockedMerchant) return;
        if (!group.amountsLookConsistent) return;
        if (group.maxAmount < 5.0 || group.maxAmount > 5000.0) return;
      }

      final display = catalog?.name ?? _prettifyName(group.displayName);
      final id = 'detected_${_slug(key)}';
      final currentPrice = group.latestAmount;
      final previousPrice = group.previousAmount ?? currentPrice;
      final priceMovedUp =
          previousPrice > 0 && currentPrice > previousPrice * 1.02;
      final status = !isRecurring && catalog != null
          ? SubscriptionStatus.unused
          : priceMovedUp
              ? SubscriptionStatus.priceIncreased
              : SubscriptionStatus.healthy;
      items.add(
        SubscriptionItem(
          id: id,
          name: display,
          vendor: display,
          category: catalog?.categoryKey ?? 'other',
          monthlyPrice: currentPrice,
          previousPrice: previousPrice,
          occurrences: group.count,
          renewalLabel: l10n.subsDetectedFromImport,
          lastUsedLabel: isRecurring
              ? l10n.subsSeenInRecentTransactions(group.count)
              : l10n.subsKnownVendorLabel,
          status: status,
          recommendation: l10n.subsRecommendationDetected,
          icon: catalog?.icon ?? Icons.subscriptions_outlined,
        ),
      );
    });

    return items;
  }

  bool _isEverydayMerchant(String normalized) {
    final padded = ' $normalized ';
    for (final needle in _kEverydayMerchantBlocklist) {
      if (padded.contains(needle)) return true;
    }
    return false;
  }

  String _normalize(String s) {
    return s
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9ğüşıöç ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _prettifyName(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return raw;
    final parts = trimmed.split(RegExp(r'\s+'));
    return parts
        .map((p) => p.isEmpty
            ? p
            : '${p[0].toUpperCase()}${p.substring(1).toLowerCase()}')
        .join(' ');
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
  _Group({required this.displayName, required this.normalizedKey});
  final String displayName;
  final String normalizedKey;
  int count = 0;
  double latestAmount = 0;
  double maxAmount = 0;
  double minAmount = double.infinity;
  double? previousAmount;

  void add(double amount) {
    if (count == 0) {
      latestAmount = amount;
      maxAmount = amount;
      minAmount = amount;
      count = 1;
      return;
    }
    if (previousAmount == null && amount != latestAmount) {
      previousAmount = latestAmount;
      latestAmount = amount;
    }
    if (amount > maxAmount) maxAmount = amount;
    if (amount < minAmount) minAmount = amount;
    count += 1;
  }

  /// True if every recorded amount is within ±15% of the largest seen amount.
  /// Subscriptions have a constant or slowly-rising price; groceries swing.
  bool get amountsLookConsistent {
    if (count < 2) return true;
    if (maxAmount <= 0) return false;
    final spread = (maxAmount - minAmount) / maxAmount;
    return spread <= 0.15;
  }
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
