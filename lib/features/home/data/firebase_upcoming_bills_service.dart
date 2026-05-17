import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../../auth/data/firebase_auth_service.dart';
import 'upcoming_bill.dart';

/// Syncs the user-managed list of upcoming bills with Firestore.
/// Falls through silently when Firebase isn't configured (local-only mode).
class FirebaseUpcomingBillsService {
  FirebaseUpcomingBillsService(this._bootstrapState, this._authService);

  final FirebaseBootstrapState _bootstrapState;
  final FirebaseAuthService _authService;

  bool get isEnabled =>
      _bootstrapState.ready && _authService.currentUser != null;

  CollectionReference<Map<String, dynamic>>? get _collection {
    final user = _authService.currentUser;
    if (user == null || !_bootstrapState.ready) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('upcomingBills');
  }

  Future<List<UpcomingBill>> load() async {
    final collection = _collection;
    if (collection == null) return const [];
    try {
      final snap = await collection.get();
      return snap.docs.map((doc) => UpcomingBill.fromMap(doc.data())).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveAll(List<UpcomingBill> bills) async {
    final collection = _collection;
    if (collection == null) return;
    try {
      final batch = FirebaseFirestore.instance.batch();
      final existing = await collection.get();
      for (final doc in existing.docs) {
        batch.delete(doc.reference);
      }
      for (final bill in bills) {
        batch.set(collection.doc(bill.id), bill.toMap());
      }
      await batch.commit();
    } catch (_) {}
  }
}

final firebaseUpcomingBillsServiceProvider =
    Provider<FirebaseUpcomingBillsService>((ref) {
  return FirebaseUpcomingBillsService(
    ref.watch(firebaseBootstrapProvider),
    ref.watch(firebaseAuthServiceProvider),
  );
});
