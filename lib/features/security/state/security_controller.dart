import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/security_check.dart';
import '../data/security_feed_repository.dart';
import '../domain/security_feed_data.dart';

enum ReviewDecision { pending, keptBlocked, approvedByUser }

class SecurityState {
  const SecurityState({
    this.checks = const [],
    this.lastUpdated,
    this.refreshing = false,
    this.expandedIds = const {},
    this.decisions = const {},
  });

  final List<SecurityCheck> checks;
  final DateTime? lastUpdated;
  final bool refreshing;
  final Set<int> expandedIds;
  final Map<int, ReviewDecision> decisions;

  String get refreshedLabel {
    if (lastUpdated == null) return 'Waiting for first scan';
    final dt = lastUpdated!;
    return 'Last scan ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  int get blockedCount => checks.where((check) {
        return check.blocked &&
            decisions[check.id] != ReviewDecision.approvedByUser;
      }).length;

  int get reviewedCount => 147 + decisions.length;

  SecurityState copyWith({
    List<SecurityCheck>? checks,
    DateTime? lastUpdated,
    bool? refreshing,
    Set<int>? expandedIds,
    Map<int, ReviewDecision>? decisions,
  }) {
    return SecurityState(
      checks: checks ?? this.checks,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      refreshing: refreshing ?? this.refreshing,
      expandedIds: expandedIds ?? this.expandedIds,
      decisions: decisions ?? this.decisions,
    );
  }
}

class SecurityController extends StateNotifier<SecurityState> {
  SecurityController(this._repository) : super(const SecurityState()) {
    _bootstrap();
    _timer = Timer.periodic(const Duration(seconds: 35), (_) => refresh());
  }

  final SecurityFeedRepository _repository;
  Timer? _timer;

  Future<void> _bootstrap() async {
    final cached = await _repository.loadCached();
    if (cached != null) {
      _apply(cached);
    }
    await refresh();
  }

  Future<void> refresh() async {
    if (state.refreshing) return;
    state = state.copyWith(refreshing: true);
    final data = await _repository.refresh();
    _apply(data);
    state = state.copyWith(refreshing: false);
  }

  void toggleExpanded(int id) {
    final updated = {...state.expandedIds};
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    state = state.copyWith(expandedIds: updated);
  }

  void setDecision(int id, ReviewDecision decision) {
    final updated = {...state.decisions, id: decision};
    state = state.copyWith(decisions: updated);
  }

  void _apply(SecurityFeedData data) {
    final expanded = {
      ...state.expandedIds,
      for (final check in data.checks)
        if (check.blocked && check.reason != null) check.id,
    };
    state = state.copyWith(
      checks: data.checks,
      lastUpdated: data.lastUpdated,
      expandedIds: expanded,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final securityControllerProvider =
    StateNotifierProvider<SecurityController, SecurityState>((ref) {
  return SecurityController(ref.watch(securityFeedRepositoryProvider));
});
