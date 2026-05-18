import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/localization/locale_controller.dart';
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

  /// Lightweight YTD estimate from the cumulative net moves Uma made, scaled
  /// against total portfolio size. Returns 0 when the portfolio is empty.
  double get ytdPercent {
    if (total <= 0) return 0;
    final movement = actions
        .where((a) => !a.undone)
        .fold<double>(0, (s, a) => s + a.amount);
    return (movement / total) * 100;
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
  WealthController(this._service, this._repository, this._l10n)
      : super(
          WealthState(
            policy: _repository.initialPolicy(),
            allocations: const [],
            actions: const [],
            insight: _repository.insightFor(
              _repository.initialPolicy(),
              const [],
              _l10n,
            ),
          ),
        ) {
    _load();
  }

  final FirebaseWealthService _service;
  final WealthRepository _repository;
  AppStrings _l10n;

  void updateL10n(AppStrings l10n) {
    _l10n = l10n;
    state = state.copyWith(
      insight: _repository.insightFor(state.policy, state.actions, l10n),
    );
  }

  Future<void> _load() async {
    final policy = await _service.loadPolicy();
    final allocations = await _service.loadPortfolio();
    final actions = await _service.loadActions();

    state = state.copyWith(
      policy: policy,
      allocations: _recomputeWeights(allocations),
      actions: actions,
      insight: _repository.insightFor(policy, actions, _l10n),
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

  Future<void> addAllocation({
    required String label,
    required double amount,
    required String paletteKey,
  }) async {
    if (amount <= 0) return;
    final merged = [
      ...state.allocations,
      PortfolioAllocation(
        label: label,
        amount: amount,
        weight: 0,
        paletteKey: paletteKey,
      ),
    ];
    final updated = _recomputeWeights(merged);
    state = state.copyWith(allocations: updated);
    await _service.savePortfolio(updated);
  }

  Future<void> removeAllocation(String label) async {
    final filtered = state.allocations.where((a) => a.label != label).toList();
    final updated = _recomputeWeights(filtered);
    state = state.copyWith(allocations: updated);
    await _service.savePortfolio(updated);
  }

  void _updatePolicy(AutonomyPolicy policy) {
    state = state.copyWith(
      policy: policy,
      insight: _repository.insightFor(policy, state.actions, _l10n),
    );
  }

  void undoAction(String id) {
    final updated = [
      for (final action in state.actions)
        action.id == id ? action.copyWith(undone: true) : action,
    ];
    state = state.copyWith(
      actions: updated,
      insight: _repository.insightFor(state.policy, updated, _l10n),
    );
  }

  List<PortfolioAllocation> _recomputeWeights(
    List<PortfolioAllocation> items,
  ) {
    final total = items.fold<double>(0, (s, a) => s + a.amount);
    if (total <= 0) return items;
    return [
      for (final a in items)
        PortfolioAllocation(
          label: a.label,
          amount: a.amount,
          weight: (a.amount / total) * 100,
          paletteKey: a.paletteKey,
        ),
    ];
  }
}

final wealthControllerProvider =
    StateNotifierProvider<WealthController, WealthState>((ref) {
  final controller = WealthController(
    ref.watch(firebaseWealthServiceProvider),
    ref.watch(wealthRepositoryProvider),
    ref.read(stringsProvider),
  );
  ref.listen<AppStrings>(stringsProvider, (_, next) {
    controller.updateL10n(next);
  });
  return controller;
});
