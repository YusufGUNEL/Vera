import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../../auth/data/firebase_auth_service.dart';
import '../domain/uma_memory.dart';
import 'uma_memory_store.dart';

class FirebaseUmaMemoryStore {
  FirebaseUmaMemoryStore(
    this._bootstrapState,
    this._authService,
    this._localStore,
  );

  final FirebaseBootstrapState _bootstrapState;
  final FirebaseAuthService _authService;
  final UmaMemoryStore _localStore;

  bool get isEnabled =>
      _bootstrapState.ready && _authService.currentUser != null;

  DocumentReference<Map<String, dynamic>>? get _doc {
    final uid = _authService.currentUser?.uid;
    if (uid == null || !_bootstrapState.ready) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('umaMemory')
        .doc('current');
  }

  Future<UmaMemoryProfile> loadProfile() async {
    final local = await _localStore.loadProfile();
    if (!isEnabled) return local;
    try {
      final snap = await _doc!.get();
      final data = snap.data();
      if (data == null) return local;
      final profile = UmaMemoryProfile.fromMap(
        (data['profile'] as Map?)?.cast<String, dynamic>() ?? const {},
      );
      await _localStore.saveProfile(profile);
      return profile;
    } catch (_) {
      return local;
    }
  }

  Future<UmaConversationSummary> loadConversationSummary() async {
    final local = await _localStore.loadConversationSummary();
    if (!isEnabled) return local;
    try {
      final snap = await _doc!.get();
      final data = snap.data();
      if (data == null) return local;
      final summary = UmaConversationSummary.fromMap(
        (data['summary'] as Map?)?.cast<String, dynamic>() ?? const {},
      );
      await _localStore.saveConversationSummary(summary);
      return summary;
    } catch (_) {
      return local;
    }
  }

  Future<void> save({
    required UmaMemoryProfile profile,
    required UmaConversationSummary summary,
  }) async {
    await _localStore.saveProfile(profile);
    await _localStore.saveConversationSummary(summary);
    if (!isEnabled) return;
    try {
      await _doc!.set({
        'profile': profile.toMap(),
        'summary': summary.toMap(),
        'syncedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }
}

final firebaseUmaMemoryStoreProvider = Provider<FirebaseUmaMemoryStore>((ref) {
  return FirebaseUmaMemoryStore(
    ref.watch(firebaseBootstrapProvider),
    ref.watch(firebaseAuthServiceProvider),
    ref.watch(umaMemoryStoreProvider),
  );
});
