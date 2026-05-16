import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../../auth/data/firebase_auth_service.dart';
import '../domain/uma_audit_event.dart';
import 'uma_audit_store.dart';

/// Uma audit olaylarını Firestore'a kaydeder.
/// Firebase hazır değilse yerel UmaAuditStore'a düşer (offline-first).
class FirebaseUmaAuditStore {
  FirebaseUmaAuditStore(
    this._bootstrapState,
    this._authService,
    this._localStore,
  );

  final FirebaseBootstrapState _bootstrapState;
  final FirebaseAuthService _authService;
  final UmaAuditStore _localStore;

  bool get isEnabled =>
      _bootstrapState.ready && _authService.currentUser != null;

  CollectionReference<Map<String, dynamic>>? get _collection {
    final uid = _authService.currentUser?.uid;
    if (uid == null || !_bootstrapState.ready) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('umaAudit');
  }

  Future<List<UmaAuditEvent>> load() async {
    if (!isEnabled) return _localStore.load();

    try {
      final snap = await _collection!
          .orderBy('timestamp', descending: true)
          .limit(120)
          .get();
      return snap.docs
          .map((doc) => UmaAuditEvent.fromMap(doc.data()))
          .toList();
    } catch (_) {
      return _localStore.load();
    }
  }

  Future<void> append(UmaAuditEvent event) async {
    // Her zaman local'e yaz (offline güvencesi).
    await _localStore.append(event);

    if (!isEnabled) return;
    try {
      await _collection!.doc(event.id).set({
        ...event.toMap(),
        'syncedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Local kayıt zaten yapıldı, sessizce geç.
    }
  }

  Future<void> clear() async {
    await _localStore.clear();
    if (!isEnabled) return;
    try {
      final snap = await _collection!.get();
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (_) {}
  }
}

final firebaseUmaAuditStoreProvider = Provider<FirebaseUmaAuditStore>((ref) {
  return FirebaseUmaAuditStore(
    ref.watch(firebaseBootstrapProvider),
    ref.watch(firebaseAuthServiceProvider),
    ref.watch(umaAuditStoreProvider),
  );
});
