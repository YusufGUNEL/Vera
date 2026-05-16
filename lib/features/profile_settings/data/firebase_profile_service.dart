import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../../auth/data/firebase_auth_service.dart';
import '../domain/profile_state.dart';

class FirebaseProfileService {
  FirebaseProfileService(this._bootstrapState, this._authService);

  final FirebaseBootstrapState _bootstrapState;
  final FirebaseAuthService _authService;

  bool get isEnabled => _bootstrapState.ready && _authService.currentUser != null;

  DocumentReference<Map<String, dynamic>>? get _doc {
    final user = _authService.currentUser;
    if (user == null || !_bootstrapState.ready) return null;
    return FirebaseFirestore.instance.collection('users').doc(user.uid);
  }

  Future<void> saveProfileShell({
    required String displayName,
    required String email,
  }) async {
    final doc = _doc;
    if (doc == null) return;
    await doc.set(
      {
        'displayName': displayName,
        'email': email,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<ProfileState?> loadSettings() async {
    final doc = _doc;
    if (doc == null) return null;
    final snap = await doc.collection('private').doc('settings').get();
    final data = snap.data();
    if (data == null) return null;
    return ProfileState.fromMap(data);
  }

  Future<void> saveSettings(ProfileState state) async {
    final doc = _doc;
    if (doc == null) return;
    await doc.collection('private').doc('settings').set(
      {
        ...state.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}

final firebaseProfileServiceProvider = Provider<FirebaseProfileService>((ref) {
  return FirebaseProfileService(
    ref.watch(firebaseBootstrapProvider),
    ref.watch(firebaseAuthServiceProvider),
  );
});
