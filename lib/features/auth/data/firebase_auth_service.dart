import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../domain/auth_session.dart';

class FirebaseAuthService {
  FirebaseAuthService(this._bootstrapState);

  final FirebaseBootstrapState _bootstrapState;

  bool get isEnabled => _bootstrapState.ready;

  User? get currentUser => isEnabled ? FirebaseAuth.instance.currentUser : null;

  AuthSession? get currentSession {
    final user = currentUser;
    if (user == null) return null;
    return AuthSession(
      status: AuthStatus.signedIn,
      userId: user.uid,
      displayName: user.displayName ?? user.email ?? 'Vera User',
      email: user.email,
      signedInAt: user.metadata.creationTime ?? DateTime.now(),
      authMethod: 'firebase auth',
    );
  }

  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    return AuthSession(
      status: AuthStatus.signedIn,
      userId: user.uid,
      displayName: user.displayName ?? user.email ?? 'Vera User',
      email: user.email,
      signedInAt: user.metadata.creationTime ?? DateTime.now(),
      authMethod: 'firebase auth',
    );
  }

  Future<AuthSession> signUpWithEmail({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(displayName);
    await user.reload();
    final refreshed = FirebaseAuth.instance.currentUser ?? user;
    return AuthSession(
      status: AuthStatus.signedIn,
      userId: refreshed.uid,
      displayName: refreshed.displayName ?? displayName,
      email: refreshed.email ?? email,
      signedInAt: refreshed.metadata.creationTime ?? DateTime.now(),
      authMethod: 'firebase auth',
    );
  }

  Future<void> signOut() async {
    if (!isEnabled) return;
    await FirebaseAuth.instance.signOut();
  }
}

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService(ref.watch(firebaseBootstrapProvider));
});
