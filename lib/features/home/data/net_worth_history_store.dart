import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/state/auth_controller.dart';

const _kHistoryKey = 'home.networth.history';
const _kMaxPoints = 60; // ~2 months of daily samples — plenty for a sparkline.

class NetWorthPoint {
  const NetWorthPoint({required this.day, required this.amount});
  final DateTime day;
  final double amount;

  Map<String, dynamic> toMap() => {
        'day': day.toIso8601String(),
        'amount': amount,
      };

  factory NetWorthPoint.fromMap(Map<String, dynamic> m) => NetWorthPoint(
        day: DateTime.parse(m['day'] as String),
        amount: (m['amount'] as num).toDouble(),
      );
}

/// Persists a small rolling window of daily net-worth snapshots so the Home
/// screen can render a sparkline. Lives in SharedPreferences only — Firestore
/// can be added later but we keep the prototype dependency-light.
class NetWorthHistoryStore {
  const NetWorthHistoryStore();

  Future<List<NetWorthPoint>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kHistoryKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(NetWorthPoint.fromMap)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Appends a point for *today* (overwrites if today already has one) and
  /// trims the list to [_kMaxPoints]. Returns the new history.
  Future<List<NetWorthPoint>> record(double amount) async {
    if (amount.isNaN || amount.isInfinite) {
      return load();
    }
    final today = DateTime.now();
    final dayKey = DateTime(today.year, today.month, today.day);

    final existing = await load();
    final filtered = existing.where((p) {
      final d = DateTime(p.day.year, p.day.month, p.day.day);
      return d != dayKey;
    }).toList();
    final updated = [
      ...filtered,
      NetWorthPoint(day: dayKey, amount: amount),
    ];
    updated.sort((a, b) => a.day.compareTo(b.day));
    final trimmed = updated.length > _kMaxPoints
        ? updated.sublist(updated.length - _kMaxPoints)
        : updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kHistoryKey,
      jsonEncode(trimmed.map((p) => p.toMap()).toList()),
    );
    return trimmed;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kHistoryKey);
  }
}

final netWorthHistoryStoreProvider =
    Provider<NetWorthHistoryStore>((ref) {
  ref.watch(authControllerProvider);
  return const NetWorthHistoryStore();
});
