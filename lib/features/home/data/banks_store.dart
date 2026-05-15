import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bank.dart';

const _kCustomBanksKey = 'home.custom.banks';

/// Persistent store for banks the user manually added.
class BanksStore {
  const BanksStore();

  Future<List<Bank>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kCustomBanksKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Bank.fromMap)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<Bank>> add(Bank bank) async {
    final existing = await load();
    final merged = [...existing, bank];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kCustomBanksKey,
      jsonEncode(merged.map((b) => b.toMap()).toList()),
    );
    return merged;
  }

  Future<List<Bank>> remove(String id) async {
    final existing = await load();
    final filtered = existing.where((b) => b.id != id).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kCustomBanksKey,
      jsonEncode(filtered.map((b) => b.toMap()).toList()),
    );
    return filtered;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCustomBanksKey);
  }
}

final banksStoreProvider = Provider<BanksStore>((ref) {
  return const BanksStore();
});
