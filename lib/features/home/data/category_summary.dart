import 'package:flutter/material.dart';

import 'transaction.dart';

class CategorySpend {
  const CategorySpend({
    required this.category,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String category;
  final double amount;
  final Color color;
  final IconData icon;
}

const _kCategoryAccent = <String, Color>{
  'Market': Color(0xFFE67E22),
  'Yeme & İçme': Color(0xFF8E5A3C),
  'Abonelik': Color(0xFFC03A2B),
  'Transfer': Color(0xFF2D5FB0),
  'Fatura': Color(0xFF8E44AD),
  'Akaryakıt': Color(0xFF34495E),
  'Sağlık': Color(0xFFC0392B),
  'Eğitim': Color(0xFF2980B9),
  'Eğlence': Color(0xFFE74C3C),
  'Maaş': Color(0xFF2F8B5C),
};

const _kCategoryIcon = <String, IconData>{
  'Market': Icons.shopping_cart_outlined,
  'Yeme & İçme': Icons.local_cafe_outlined,
  'Abonelik': Icons.subscriptions_outlined,
  'Transfer': Icons.send_outlined,
  'Fatura': Icons.receipt_long_outlined,
  'Akaryakıt': Icons.local_gas_station_outlined,
  'Sağlık': Icons.local_hospital_outlined,
  'Eğitim': Icons.school_outlined,
  'Eğlence': Icons.movie_outlined,
  'Maaş': Icons.work_outline,
};

const _kFallbackPalette = <Color>[
  Color(0xFF9B59B6),
  Color(0xFF16A085),
  Color(0xFFD35400),
  Color(0xFF7F8C8D),
];

/// Aggregates negative (spending) transactions by category. Returns the top
/// [maxBuckets] entries sorted by amount desc; remainder collapses into an
/// "Other" bucket. Income transactions are ignored.
List<CategorySpend> summarizeSpending(
  List<Txn> transactions, {
  int maxBuckets = 5,
  String otherLabel = 'Diğer',
  Color otherColor = const Color(0xFF95A5A6),
}) {
  final totals = <String, double>{};
  for (final txn in transactions) {
    if (txn.isCredit) continue;
    final key = txn.category.isEmpty ? otherLabel : txn.category;
    totals.update(key, (v) => v + txn.amount.abs(),
        ifAbsent: () => txn.amount.abs());
  }
  if (totals.isEmpty) return const [];

  final entries = totals.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final top = entries.take(maxBuckets).toList();
  final rest = entries.skip(maxBuckets).fold<double>(0, (s, e) => s + e.value);

  final out = <CategorySpend>[];
  for (var i = 0; i < top.length; i++) {
    final e = top[i];
    out.add(
      CategorySpend(
        category: e.key,
        amount: e.value,
        color: _kCategoryAccent[e.key] ??
            _kFallbackPalette[i % _kFallbackPalette.length],
        icon: _kCategoryIcon[e.key] ?? Icons.payments_outlined,
      ),
    );
  }
  if (rest > 0) {
    out.add(
      CategorySpend(
        category: otherLabel,
        amount: rest,
        color: otherColor,
        icon: Icons.more_horiz,
      ),
    );
  }
  return out;
}

double totalSpending(List<CategorySpend> spends) {
  return spends.fold<double>(0, (s, c) => s + c.amount);
}
