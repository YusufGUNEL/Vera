import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/firebase_wealth_service.dart';
import '../data/wealth_repository.dart';
import '../domain/autonomy_policy.dart';
import '../domain/portfolio_allocation.dart';
import '../domain/rebalance_action.dart';

class WealthState {
  const WealthState({
    required this.policy,
    required this.allocations,
    required this.actions,
    required this.insight,
  });

  final AutonomyPolicy policy;
  final List<PortfolioAllocation> allocations;
  final List<RebalanceAction> actions;
  final String insight;

  double get total =>
      allocations.fold<double>(0, (sum, item) => sum + item.amount);

  /// Today's portfolio delta in TL derived from active actions that landed
  /// "today". Reversed actions are excluded.
  double get todayDelta {
    return actions
        .where((a) => !a.undone)
        .where((a) {
          final w = a.when.toLowerCase();
          return w.contains('bugün') || w.contains('today');
        })
        .fold<double>(0, (sum, a) => sum + a.amount);
  }

  /// YTD percent estimated from the cumulative net moves Uma executed,
  /// scaled to total portfolio size. Falls back to 0 when the portfolio is
  /// empty.
  double get ytdPercent {
    if (total <= 0) return 0;
    final base = 12.0; // baseline market drift the demo assumes
    final movement = actions
        .where((a) => !a.undone)
        .fold<double>(0, (s, a) => s + a.amount);
    return base + (movement / total) * 100;
  }

  WealthState copyWith({
    AutonomyPolicy? policy,
    List<PortfolioAllocation>? allocations,
    List<RebalanceAction>? actions,
    String? insight,
  }) {
    return WealthState(
      policy: policy ?? this.policy,
      allocations: allocations ?? this.allocations,
      actions: actions ?? this.actions,
      insight: insight ?? this.insight,
    );
  }
}

class WealthController extends StateNotifier<WealthState> {
  WealthController(this._service, this._repository)
      : super(
          WealthState(
            policy: _repository.initialPolicy(),
            allocations: const [],
            actions: const [],
            insight: '',
          ),
        ) {
    _load();
  }

  final FirebaseWealthService _service;
  final WealthRepository _repository;

  Future<void> _load() async {
    final policy = await _service.loadPolicy();
    final allocations = await _service.loadPortfolio();
    final actions = await _service.loadActions();
    
    state = state.copyWith(
      policy: policy,
      allocations: allocations,
      actions: actions,
      insight: _repository.insightFor(policy, actions),
    );
  }

  void setAutonomous(bool enabled) async {
    final p = state.policy.copyWith(enabled: enabled);
    await _service.savePolicy(p);
    _updatePolicy(p);
  }

  void setRiskProfile(String riskProfile) async {
    final p = state.policy.copyWith(riskProfile: riskProfile);
    await _service.savePolicy(p);
    _updatePolicy(p);
  }

  void setMonthlyMoveLimit(double limit) async {
    final p = state.policy.copyWith(monthlyMoveLimit: limit);
    await _service.savePolicy(p);
    _updatePolicy(p);
  }

  void setApprovalMode(ApprovalMode mode) async {
    final p = state.policy.copyWith(approvalMode: mode);
    await _service.savePolicy(p);
    _updatePolicy(p);
  }

  void _updatePolicy(AutonomyPolicy policy) {
    state = state.copyWith(
      policy: policy,
      insight: _repository.insightFor(policy, state.actions),
    );
  }

  void undoAction(String id) {
    final updated = [
      for (final action in state.actions)
        action.id == id ? action.copyWith(undone: true) : action,
    ];
    state = state.copyWith(
      actions: updated,
      insight: _repository.insightFor(state.policy, updated),
    );
  }
}

final wealthControllerProvider =
    StateNotifierProvider<WealthController, WealthState>((ref) {
  return WealthController(
    ref.watch(firebaseWealthServiceProvider),
    ref.watch(wealthRepositoryProvider),
  );
});
