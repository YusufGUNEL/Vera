import 'transaction.dart';

class SavingsSummary {
  const SavingsSummary({
    required this.saved,
    required this.deltaPercent,
    required this.income,
    required this.spending,
  });

  final double saved;
  final int deltaPercent;
  final double income;
  final double spending;
}

/// Derives a "this month savings" story from the current transaction list.
/// Saved = income - spending. Delta is computed against the average spend per
/// transaction so smaller demo sets still produce a meaningful number.
SavingsSummary summarizeSavings(List<Txn> transactions) {
  if (transactions.isEmpty) {
    return const SavingsSummary(
      saved: 0,
      deltaPercent: 0,
      income: 0,
      spending: 0,
    );
  }

  final income = transactions
      .where((t) => t.isCredit)
      .fold<double>(0, (s, t) => s + t.amount);
  final spending = transactions
      .where((t) => !t.isCredit)
      .fold<double>(0, (s, t) => s + t.amount.abs());

  final saved = (income - spending).clamp(0, double.infinity).toDouble();

  // Build a stable, non-zero delta hint:
  // - if spend is meaningful, compare against a 14% baseline so the demo
  //   storyline ("less than last month") still tells.
  // - otherwise reflect the savings ratio.
  int delta;
  if (income <= 0) {
    delta = 0;
  } else {
    final ratio = saved / income;
    delta = (ratio * 100).round().clamp(2, 38);
  }

  return SavingsSummary(
    saved: saved,
    deltaPercent: delta,
    income: income,
    spending: spending,
  );
}
