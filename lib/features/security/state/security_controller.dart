import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/notification_service.dart';
import '../../home/data/transaction.dart';
import '../../home/state/home_controller.dart';
import '../data/fraud_heuristic.dart';
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

  String? get lastUpdatedTime {
    final dt = lastUpdated;
    if (dt == null) return null;
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  int get blockedCount => checks.where((check) {
        return check.blocked &&
            decisions[check.id] != ReviewDecision.approvedByUser;
      }).length;

  /// Checks the user has resolved (kept blocked or approved) plus the
  /// non-blocked items that Fraud Radar already cleared in the current feed.
  int get reviewedCount {
    final cleared = checks.where((c) => !c.blocked).length;
    return cleared + decisions.length;
  }

  /// Distinct device labels seen in the feed (e.g. MacBook Pro, iPhone 17).
  /// We pull "device-like" check names; the count never goes below 1 since
  /// the user is always on at least one device.
  int get trustedDevices {
    final pattern = RegExp(
      r'(macbook|iphone|ipad|android|samsung|xiaomi|cihaz|device|laptop|pc|windows|browser|tarayıcı)',
      caseSensitive: false,
    );
    final unique = checks
        .where((c) => pattern.hasMatch(c.name))
        .map((c) => c.location)
        .toSet();
    return unique.isEmpty ? 1 : unique.length;
  }

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
  SecurityController(
    this._repository,
    this._notifications,
    this._heuristic,
    this._ref,
  ) : super(const SecurityState()) {
    _bootstrap();
    _timer = Timer.periodic(const Duration(seconds: 35), (_) => refresh());
    _txnSub = _ref.listen<List<Txn>>(
      homeControllerProvider.select((s) => s.transactions),
      (_, next) => _runHeuristic(next),
    );
  }

  final SecurityFeedRepository _repository;
  final NotificationService _notifications;
  final FraudHeuristic _heuristic;
  final Ref _ref;
  Timer? _timer;
  ProviderSubscription<List<Txn>>? _txnSub;
  final Set<int> _notifiedIds = <int>{};
  bool _firstApplyDone = false;
  List<SecurityCheck> _baseFeed = const [];
  List<SecurityCheck> _heuristicFeed = const [];

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
    _baseFeed = data.checks;
    final merged = _mergedChecks();
    final expanded = {
      ...state.expandedIds,
      for (final check in merged)
        if (check.blocked && check.reason != null) check.id,
    };
    state = state.copyWith(
      checks: merged,
      lastUpdated: data.lastUpdated,
      expandedIds: expanded,
    );
    // Fire one local notification per newly-blocked check.
    if (_firstApplyDone) {
      _fireNotificationsForNewBlocks(merged);
    } else {
      // On bootstrap, seed the notified set with existing blocked ids so we
      // don't spam the device with notifications on app launch.
      _notifiedIds.addAll(
        merged.where((c) => c.blocked).map((c) => c.id),
      );
      _firstApplyDone = true;
    }
  }

  void _runHeuristic(List<Txn> txns) {
    _heuristicFeed = _heuristic.analyze(txns);
    if (!mounted) return;
    final merged = _mergedChecks();
    state = state.copyWith(
      checks: merged,
      lastUpdated: state.lastUpdated ?? DateTime.now(),
    );
    if (_firstApplyDone) _fireNotificationsForNewBlocks(merged);
  }

  List<SecurityCheck> _mergedChecks() {
    final seen = <int>{};
    final out = <SecurityCheck>[];
    for (final c in [..._heuristicFeed, ..._baseFeed]) {
      if (seen.add(c.id)) out.add(c);
    }
    return out;
  }

  Future<void> _fireNotificationsForNewBlocks(
      List<SecurityCheck> checks) async {
    for (final check in checks) {
      if (!check.blocked) continue;
      if (_notifiedIds.contains(check.id)) continue;
      _notifiedIds.add(check.id);
      try {
        await _notifications.showFraudAlert(
          title: 'Vera • Şüpheli işlem engellendi',
          body: '${check.name} · ${check.location}',
          payload: '/security',
        );
      } catch (_) {
        // Notifications best-effort; never break the controller flow.
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _txnSub?.close();
    super.dispose();
  }
}

final securityControllerProvider =
    StateNotifierProvider<SecurityController, SecurityState>((ref) {
  return SecurityController(
    ref.watch(securityFeedRepositoryProvider),
    ref.watch(notificationServiceProvider),
    ref.watch(fraudHeuristicProvider),
    ref,
  );
});
