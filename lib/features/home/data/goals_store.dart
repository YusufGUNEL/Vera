import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'goal.dart';

const _kGoalKey = 'home.goal.emergency';

class GoalsStore {
  const GoalsStore();

  Future<FinancialGoal> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kGoalKey);
    if (raw == null || raw.isEmpty) return FinancialGoal.empty;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return FinancialGoal.fromMap(decoded);
      }
      return FinancialGoal.empty;
    } catch (_) {
      return FinancialGoal.empty;
    }
  }

  Future<void> save(FinancialGoal goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kGoalKey, jsonEncode(goal.toMap()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kGoalKey);
  }
}

final goalsStoreProvider = Provider<GoalsStore>((ref) => const GoalsStore());
