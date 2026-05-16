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
    // Note: userTxns is dynamic here due to import constraints, but we pass it to local repo correctly.
    if (!isEnabled) {
      // It's safe to cast inside if needed or let the local handle it.
      return _local.getSubscriptions(userTxns: userTxns.cast());
    }

    try {
      final snap = await _collection!.get();
      if (snap.docs.isEmpty) {
        // İlk giriş: local mock/detected datayı toplayıp kaydet
        final initialItems = _local.getSubscriptions(userTxns: userTxns.cast());
        await _seedSubscriptions(initialItems);
        return initialItems;
      }
      return snap.docs
          .map((doc) => SubscriptionItem.fromMap(doc.data()))
          .toList();
    } catch (_) {
      return _local.getSubscriptions(userTxns: userTxns.cast());
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

  Future<void> _seedSubscriptions(List<SubscriptionItem> items) async {
    if (!isEnabled) return;
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (final item in items) {
        batch.set(
          _collection!.doc(item.id),
          {
            ...item.toMap(),
            'syncedAt': FieldValue.serverTimestamp(),
          },
        );
      }
      await batch.commit();
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
