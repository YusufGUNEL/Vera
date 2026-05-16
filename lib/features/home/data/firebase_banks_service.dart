import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../../auth/data/firebase_auth_service.dart';
import 'bank.dart';

class FirebaseBanksService {
  FirebaseBanksService(this._bootstrapState, this._authService);

  final FirebaseBootstrapState _bootstrapState;
  final FirebaseAuthService _authService;

  bool get isEnabled => _bootstrapState.ready && _authService.currentUser != null;

  CollectionReference<Map<String, dynamic>>? get _collection {
    final user = _authService.currentUser;
    if (user == null || !_bootstrapState.ready) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('banks');
  }

  Future<List<Bank>> load() async {
    final collection = _collection;
    if (collection == null) return const [];
    final snap = await collection.get();
    return snap.docs.map((doc) => Bank.fromMap(doc.data())).toList();
  }

  Future<void> saveAll(List<Bank> banks) async {
    final collection = _collection;
    if (collection == null) return;
    final batch = FirebaseFirestore.instance.batch();
    final existing = await collection.get();
    for (final doc in existing.docs) {
      batch.delete(doc.reference);
    }
    for (final bank in banks) {
      batch.set(collection.doc(bank.id), bank.toMap());
    }
    await batch.commit();
  }
}

final firebaseBanksServiceProvider = Provider<FirebaseBanksService>((ref) {
  return FirebaseBanksService(
    ref.watch(firebaseBootstrapProvider),
    ref.watch(firebaseAuthServiceProvider),
  );
});
