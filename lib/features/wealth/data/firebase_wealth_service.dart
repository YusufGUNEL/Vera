import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../../auth/data/firebase_auth_service.dart';
import '../domain/autonomy_policy.dart';
import '../domain/portfolio_allocation.dart';
import '../domain/rebalance_action.dart';
import 'wealth_repository.dart';

/// Portföy ve otonom politika verilerini Firestore'a senkron eder.
/// Firebase hazır değilse WealthRepository'nin yerel boş varsayılanına döner.
class FirebaseWealthService {
  FirebaseWealthService(
    this._bootstrapState,
    this._authService,
    this._local,
  );

  final FirebaseBootstrapState _bootstrapState;
  final FirebaseAuthService _authService;
  final WealthRepository _local;

  bool get isEnabled =>
      _bootstrapState.ready && _authService.currentUser != null;

  DocumentReference<Map<String, dynamic>>? get _wealthDoc {
    final uid = _authService.currentUser?.uid;
    if (uid == null || !_bootstrapState.ready) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('wealthData')
        .doc('current');
  }

  CollectionReference<Map<String, dynamic>>? get _actionsCollection {
    final uid = _authService.currentUser?.uid;
    if (uid == null || !_bootstrapState.ready) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('wealthActions');
  }

  // ─── Portföy ──────────────────────────────────────────────────────────────

  Future<List<PortfolioAllocation>> loadPortfolio() async {
    if (!isEnabled) return _local.portfolio();

    try {
      final snap = await _wealthDoc!.get();
      final data = snap.data();
      if (data == null) return const [];
      final rawList = (data['portfolio'] as List?) ?? [];
      return rawList
          .whereType<Map<String, dynamic>>()
          .map(PortfolioAllocation.fromMap)
          .toList();
    } catch (_) {
      return _local.portfolio();
    }
  }

  Future<void> savePortfolio(List<PortfolioAllocation> portfolio) async {
    if (!isEnabled) return;
    try {
      await _wealthDoc!.set(
        {
          'portfolio': portfolio.map((a) => a.toMap()).toList(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {}
  }

  // ─── Otonom Politika ──────────────────────────────────────────────────────

  Future<AutonomyPolicy> loadPolicy() async {
    if (!isEnabled) return _local.initialPolicy();

    try {
      final snap = await _wealthDoc!.get();
      final data = snap.data();
      if (data == null || data['policy'] == null) {
        return _local.initialPolicy();
      }
      return AutonomyPolicy.fromMap(data['policy'] as Map<String, dynamic>);
    } catch (_) {
      return _local.initialPolicy();
    }
  }

  Future<void> savePolicy(AutonomyPolicy policy) async {
    if (!isEnabled) return;
    try {
      await _wealthDoc!.set(
        {
          'policy': policy.toMap(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {}
  }

  // ─── Rebalance Aksiyonları ────────────────────────────────────────────────

  Future<List<RebalanceAction>> loadActions() async {
    if (!isEnabled) return _local.actions();

    try {
      final snap = await _actionsCollection!
          .orderBy('when', descending: true)
          .limit(50)
          .get();
      return snap.docs
          .map((doc) => RebalanceAction.fromMap(doc.data()))
          .toList();
    } catch (_) {
      return _local.actions();
    }
  }
}

final firebaseWealthServiceProvider = Provider<FirebaseWealthService>((ref) {
  return FirebaseWealthService(
    ref.watch(firebaseBootstrapProvider),
    ref.watch(firebaseAuthServiceProvider),
    ref.watch(wealthRepositoryProvider),
  );
});
