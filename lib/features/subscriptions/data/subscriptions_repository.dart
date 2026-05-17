import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  List<SubscriptionItem> getSubscriptions({List<Txn> userTxns = const []}) {
    if (userTxns.isEmpty) return const [];
    return _parser.detectSubscriptions(userTxns);
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
        message: items.isEmpty
            ? 'Henüz abonelik tespit edilmedi. Ekstre yükle veya manuel ekle, Vera takip etsin.'
            : 'Vera, rutinini bozmadan dondurabileceğin veya alt pakete düşürebileceğin abonelikler buldu.',
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
    if (items.isEmpty) {
      return 'Vera ekstreni veya fişlerini analiz edip aboneliklerini bu listede toplar.';
    }
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
