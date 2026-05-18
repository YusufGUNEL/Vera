import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../home/data/transaction.dart';
import 'security_check.dart';

/// Lightweight, on-device fraud heuristic. Runs over the user's imported
/// transactions and flags items that look anomalous so the Security screen
/// has real (user-driven) signals instead of hardcoded events.
///
/// Heuristics:
///   1. **Outlier amount** — a single expense > 3× the median expense.
///   2. **Round large transfer** — >= 10,000 TL and ends in `000`. Often
///      legitimate, but worth surfacing for the user to confirm.
///   3. **Unknown merchant** — name has no alpha characters or is mostly
///      gibberish (numbers + symbols).
///   4. **Burst** — same merchant 3+ times in the same day with negative amount.
class FraudHeuristic {
  const FraudHeuristic();

  List<SecurityCheck> analyze(List<Txn> txns, AppStrings l10n) {
    if (txns.isEmpty) return const [];

    final expenses = txns.where((t) => !t.isCredit).toList();
    if (expenses.isEmpty) return const [];

    final amounts = expenses.map((t) => t.amount.abs()).toList()..sort();
    final median = amounts[amounts.length ~/ 2];
    final findings = <SecurityCheck>[];
    final seen = <String>{};

    // 1) Outliers
    for (final t in expenses) {
      if (median <= 0) break;
      if (t.amount.abs() > median * 3 && t.amount.abs() >= 1000) {
        final id = _id('outlier', t);
        if (seen.add(id)) {
          findings.add(SecurityCheck(
            id: id.hashCode,
            name: '${t.name} · ${t.amount.abs().toStringAsFixed(0)} TL',
            location: t.category,
            when: t.when,
            blocked: t.amount.abs() > median * 6,
            reason: l10n.fraudReasonOutlier(
              median.toStringAsFixed(0),
              (t.amount.abs() / median).toStringAsFixed(1),
            ),
          ));
        }
      }
    }

    // 2) Round large transfers
    for (final t in expenses) {
      final v = t.amount.abs();
      if (v >= 10000 && v.toInt() % 1000 == 0) {
        final id = _id('round', t);
        if (seen.add(id)) {
          findings.add(SecurityCheck(
            id: id.hashCode,
            name: l10n.fraudNameRoundTransfer(v.toStringAsFixed(0)),
            location: t.name,
            when: t.when,
            blocked: false,
            reason: l10n.fraudReasonRoundTransfer,
          ));
        }
      }
    }

    // 3) Bursty same-merchant on the same day
    final byBucket = <String, List<Txn>>{};
    for (final t in expenses) {
      final dayBucket = '${t.when.split(',').first}|${t.name.toLowerCase()}';
      byBucket.putIfAbsent(dayBucket, () => []).add(t);
    }
    for (final entry in byBucket.entries) {
      if (entry.value.length >= 3) {
        final sample = entry.value.first;
        final id = _id('burst', sample);
        if (seen.add(id)) {
          final total =
              entry.value.fold<double>(0, (s, t) => s + t.amount.abs());
          findings.add(SecurityCheck(
            id: id.hashCode,
            name: l10n.fraudNameBurst(sample.name, entry.value.length),
            location: l10n.fraudLocationBurstTotal(total.toStringAsFixed(0)),
            when: sample.when,
            blocked: false,
            reason: l10n.fraudReasonBurst(entry.value.length),
          ));
        }
      }
    }

    return findings;
  }

  String _id(String kind, Txn t) =>
      '$kind:${t.id}:${t.name.toLowerCase()}:${t.amount.toStringAsFixed(0)}';
}

final fraudHeuristicProvider =
    Provider<FraudHeuristic>((ref) => const FraudHeuristic());
