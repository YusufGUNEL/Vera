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

  List<SubscriptionItem> getSubscriptions({List<Txn> userTxns = const []}) {
    // Merge user transactions with the seeded sample so the catalog matching
    // still works in a totally fresh install.
    final allTxns = [...userTxns, ...kTransactions];
    final detectedVendors =
        _parser.detectVendors(allTxns.map((txn) => txn.name).toList());

    final items = <SubscriptionItem>[
      SubscriptionItem(
        id: 'netflix',
        name: 'Netflix Premium',
        vendor: 'Netflix',
        category: 'Eğlence',
        monthlyPrice: 150,
        previousPrice: detectedVendors.contains('Netflix') ? 129 : 150,
        renewalLabel: '2 gün içinde yenilenir',
        lastUsedLabel: '18 gündür izlenmedi',
        status: SubscriptionStatus.priceIncreased,
        recommendation: 'Bir alt pakete düş veya bu ay dondur.',
        icon: Icons.movie_outlined,
      ),
      const SubscriptionItem(
        id: 'spotify',
        name: 'Spotify Aile',
        vendor: 'Spotify',
        category: 'Müzik',
        monthlyPrice: 100,
        previousPrice: 100,
        renewalLabel: '12 gün içinde yenilenir',
        lastUsedLabel: 'Bu sabah kullanıldı',
        status: SubscriptionStatus.healthy,
        recommendation: 'Aktif kalsın. Tüm hane sıkı kullanıyor.',
        icon: Icons.headphones_outlined,
      ),
      const SubscriptionItem(
        id: 'youtube-premium',
        name: 'YouTube Premium',
        vendor: 'Google',
        category: 'Video',
        monthlyPrice: 58,
        previousPrice: 58,
        renewalLabel: 'Yarın yenilenir',
        lastUsedLabel: '27 gündür aktivite yok',
        status: SubscriptionStatus.unused,
        recommendation:
            'Bu planı dondur, geçmişini kaybetmeden aylık tasarruf et.',
        icon: Icons.smart_display_outlined,
        canFreeze: true,
      ),
      const SubscriptionItem(
        id: 'icloud',
        name: 'iCloud+ 200 GB',
        vendor: 'Apple',
        category: 'Depolama',
        monthlyPrice: 40,
        previousPrice: 40,
        renewalLabel: '5 gün içinde yenilenir',
        lastUsedLabel: 'Depolama %92 dolu',
        status: SubscriptionStatus.renewalSoon,
        recommendation:
            'Aktif kalsın ama yıllık depolama maliyetini sonraki dönemde gözden geçir.',
        icon: Icons.cloud_outlined,
      ),
    ];

    // Detect additional subscriptions in the user's imported transactions
    // (receipt OCR + statement import). Dedupe against the seed by vendor.
    final detected = _parser.detectSubscriptions(userTxns);
    final seedVendors =
        items.map((s) => s.vendor.toLowerCase()).toSet();
    for (final d in detected) {
      if (seedVendors.contains(d.vendor.toLowerCase())) continue;
      items.add(d);
    }

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
        title: 'Aylık tasarruf potansiyeli',
        message:
            'Vera, rutinini bozmadan dondurabileceğin veya alt pakete düşürebileceğin abonelikler buldu.',
        metricLabel: 'KAZANÇ',
        metricValue: '${savings.toStringAsFixed(0)} TL',
      ),
      SubscriptionAlert(
        title: 'Fiyat artışı tespit edildi',
        message: priceUpItems.isEmpty
            ? 'Bu dönem alışılmadık fiyat sıçraması yok.'
            : 'Bir veya daha fazla planın fiyatı geçen aya göre arttı.',
        metricLabel: 'ARTAN',
        metricValue: '${priceUpItems.length}',
      ),
      SubscriptionAlert(
        title: 'Az kullanılan planlar',
        message: unusedItems == 0
            ? 'Tüm abonelikler sağlıklı kullanılıyor.'
            : 'Son aktivite örüntüne göre $unusedItems plan az kullanılıyor görünüyor.',
        metricLabel: 'BOŞTA',
        metricValue: '$unusedItems',
      ),
    ];
  }

  String buildInsight(List<SubscriptionItem> items) {
    final savings = estimatedMonthlySavings(items);
    final needsAttention =
        items.where((item) => item.status.needsAttention).length;

    if (needsAttention == 0) {
      return 'Abonelikler bu ay sağlıklı görünüyor. Acil bir tasarruf kaçağı yok.';
    }

    return 'Hızlıca incelemen gereken $needsAttention abonelik var. Vera, kullanılmayanları dondurarak ve fiyat artışı olanları alt pakete düşürerek aylık ${savings.toStringAsFixed(0)} TL kadar geri kazanabileceğini hesaplıyor.';
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
