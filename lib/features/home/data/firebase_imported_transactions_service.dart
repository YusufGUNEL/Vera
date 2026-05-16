import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../../auth/data/firebase_auth_service.dart';
import 'transaction.dart';

class FirebaseImportedTransactionsService {
  FirebaseImportedTransactionsService(this._bootstrapState, this._authService);

  final FirebaseBootstrapState _bootstrapState;
  final FirebaseAuthService _authService;

  bool get isEnabled => _bootstrapState.ready && _authService.currentUser != null;

  CollectionReference<Map<String, dynamic>>? get _collection {
    final user = _authService.currentUser;
    if (user == null || !_bootstrapState.ready) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('importedTransactions');
  }

  Future<List<Txn>> load() async {
    final collection = _collection;
    if (collection == null) return const [];
    final snap = await collection.get();
    final items = snap.docs.map((doc) => Txn.fromMap(doc.data())).toList();
    items.sort((a, b) => b.id.compareTo(a.id));
    return items;
  }

  Future<void> saveAll(List<Txn> txns) async {
    final collection = _collection;
    if (collection == null) return;
    final batch = FirebaseFirestore.instance.batch();
    final existing = await collection.get();
    for (final doc in existing.docs) {
      batch.delete(doc.reference);
    }
    for (final txn in txns) {
      batch.set(
        collection.doc('txn_${txn.id}'),
        {
          ...txn.toMap(),
          'syncedAt': FieldValue.serverTimestamp(),
        },
      );
    }
    await batch.commit();
  }
}

final firebaseImportedTransactionsServiceProvider =
    Provider<FirebaseImportedTransactionsService>((ref) {
  return FirebaseImportedTransactionsService(
    ref.watch(firebaseBootstrapProvider),
    ref.watch(firebaseAuthServiceProvider),
  );
});
