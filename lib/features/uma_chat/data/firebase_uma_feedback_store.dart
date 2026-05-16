import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../../auth/data/firebase_auth_service.dart';
import '../domain/uma_feedback.dart';
import 'uma_feedback_store.dart';

/// Uma feedback'lerini Firestore'a kaydeder.
/// Firebase hazır değilse yerel UmaFeedbackStore'a düşer (offline-first).
class FirebaseUmaFeedbackStore {
  FirebaseUmaFeedbackStore(
    this._bootstrapState,
    this._authService,
    this._localStore,
  );

  final FirebaseBootstrapState _bootstrapState;
  final FirebaseAuthService _authService;
  final UmaFeedbackStore _localStore;

  bool get isEnabled =>
      _bootstrapState.ready && _authService.currentUser != null;

  CollectionReference<Map<String, dynamic>>? get _collection {
    final uid = _authService.currentUser?.uid;
    if (uid == null || !_bootstrapState.ready) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('umaFeedback');
  }

  Future<List<UmaFeedbackEntry>> load() async {
    if (!isEnabled) return _localStore.load();

    try {
      final snap = await _collection!
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      return snap.docs
          .map((doc) => UmaFeedbackEntry.fromMap(doc.data()))
          .toList();
    } catch (_) {
      return _localStore.load();
    }
  }

  Future<void> save(UmaFeedbackEntry entry) async {
    await _localStore.save(entry);

    if (!isEnabled) return;
    try {
      await _collection!.doc(entry.messageId).set({
        ...entry.toMap(),
        'syncedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
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

  Future<String> buildPromptContext() async {
    // Prompt context her zaman local'den okunur (hız için).
    return _localStore.buildPromptContext();
  }
}

final firebaseUmaFeedbackStoreProvider =
    Provider<FirebaseUmaFeedbackStore>((ref) {
  return FirebaseUmaFeedbackStore(
    ref.watch(firebaseBootstrapProvider),
    ref.watch(firebaseAuthServiceProvider),
    ref.watch(umaFeedbackStoreProvider),
  );
});
