import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kBudgetKey = 'home.category.budgets';

/// Per-category monthly limit map (category → TL limit). Persisted in
/// SharedPreferences as JSON. Missing keys mean "no limit".
class CategoryBudgetStore {
  const CategoryBudgetStore();

  Future<Map<String, double>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kBudgetKey);
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const {};
      return decoded.map(
        (k, v) => MapEntry('$k', (v as num).toDouble()),
      );
    } catch (_) {
      return const {};
    }
  }

  Future<Map<String, double>> setLimit(String category, double limit) async {
    final existing = await load();
    final updated = {...existing};
    if (limit <= 0) {
      updated.remove(category);
    } else {
      updated[category] = limit;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kBudgetKey, jsonEncode(updated));
    return updated;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kBudgetKey);
  }
}

final categoryBudgetStoreProvider =
    Provider<CategoryBudgetStore>((ref) => const CategoryBudgetStore());
