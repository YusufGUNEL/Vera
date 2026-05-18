import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/goal.dart';
import '../data/goals_store.dart';

class GoalsController extends StateNotifier<FinancialGoal> {
  GoalsController(this._store) : super(FinancialGoal.empty) {
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

  /// Replaces the current goal entirely. Used by Uma's function-calling tool
  /// when the user asks to create a savings goal from scratch.
  Future<void> setGoal({
    required double target,
    double saved = 0,
    double monthlyContribution = 0,
  }) async {
    final next = FinancialGoal(
      target: target,
      saved: saved,
      monthlyContribution: monthlyContribution,
    );
    await _store.save(next);
    state = next;
  }

  Future<void> reset() async {
    await _store.clear();
    state = FinancialGoal.empty;
  }
}

final goalsControllerProvider =
    StateNotifierProvider<GoalsController, FinancialGoal>((ref) {
  return GoalsController(ref.watch(goalsStoreProvider));
});
