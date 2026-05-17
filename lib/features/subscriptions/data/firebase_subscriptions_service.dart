import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../../auth/data/firebase_auth_service.dart';
import '../domain/subscription_item.dart';
import 'subscriptions_repository.dart';

/// Abonelikleri Firestore'a senkron eder.
/// Firebase hazır değilse SubscriptionsRepository mock verisine düşer.
class FirebaseSubscriptionsService {
  FirebaseSubscriptionsService(
    this._bootstrapState,
    this._authService,
    this._local,
  );

  final FirebaseBootstrapState _bootstrapState;
  final FirebaseAuthService _authService;
  final SubscriptionsRepository _local;

  bool get isEnabled =>
      _bootstrapState.ready && _authService.currentUser != null;

  CollectionReference<Map<String, dynamic>>? get _collection {
    final uid = _authService.currentUser?.uid;
    if (uid == null || !_bootstrapState.ready) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('subscriptions');
  }

  Future<List<SubscriptionItem>> loadSubscriptions({
    required List<dynamic> userTxns,
  }) async {
    // The cheapest source of truth: re-detect from the user's transactions.
    // Firestore only persists user-edited overrides on top of that — never a
    // canned seed of brand names.
    final detected = _local.getSubscriptions(userTxns: userTxns.cast());
    if (!isEnabled) return detected;

    try {
      final snap = await _collection!.get();
      final stored = snap.docs
          .map((doc) => SubscriptionItem.fromMap(doc.data()))
          .toList();
      // Stored overrides win by id; new detections are appended.
      final byId = {for (final s in stored) s.id: s};
      for (final d in detected) {
        byId.putIfAbsent(d.id, () => d);
      }
      return byId.values.toList();
    } catch (_) {
      return detected;
    }
  }

  Future<void> saveSubscription(SubscriptionItem item) async {
    if (!isEnabled) return;
    try {
      await _collection!.doc(item.id).set({
        ...item.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }
}

final firebaseSubscriptionsServiceProvider =
    Provider<FirebaseSubscriptionsService>((ref) {
  return FirebaseSubscriptionsService(
    ref.watch(firebaseBootstrapProvider),
    ref.watch(firebaseAuthServiceProvider),
    ref.watch(subscriptionsRepositoryProvider),
  );
});
