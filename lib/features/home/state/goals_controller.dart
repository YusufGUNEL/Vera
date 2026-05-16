import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/goal.dart';
import '../data/goals_store.dart';

class GoalsController extends StateNotifier<FinancialGoal> {
  GoalsController(this._store) : super(FinancialGoal.seed) {
    _bootstrap();
  }

  final GoalsStore _store;

  Future<void> _bootstrap() async {
    state = await _store.load();
  }

  Future<void> updateGoal({double? target, double? saved}) async {
    state = state.copyWith(target: target, saved: saved);
    await _store.save(state);
  }

  Future<void> reset() async {
    await _store.clear();
    state = FinancialGoal.seed;
  }
}

final goalsControllerProvider =
    StateNotifierProvider<GoalsController, FinancialGoal>((ref) {
  return GoalsController(ref.watch(goalsStoreProvider));
});
