import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import 'account_deletion_service.dart';
import '../domain/auth_session.dart';

class FirebaseAuthService {
  FirebaseAuthService(this._bootstrapState, this._ref);

  final FirebaseBootstrapState _bootstrapState;
  final Ref _ref;

  bool get isEnabled => _bootstrapState.ready;

  User? get currentUser => isEnabled ? FirebaseAuth.instance.currentUser : null;

  GoogleSignIn? _googleClient;

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
    final credential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
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
    final googleClient = _googleClient;
    if (googleClient != null) {
      await googleClient.signOut();
    }
    if (!isEnabled) return;
    await FirebaseAuth.instance.signOut();
  }

  Future<void> deleteAccount() async {
    if (!isEnabled || currentUser == null) return;
    await _ref.read(accountDeletionServiceProvider).deleteCurrentAccount();
  }

  Future<AuthSession?> signInWithGoogle() async {
    if (!isEnabled) return null;

    UserCredential credential;
    if (kIsWeb) {
      final provider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile');
      credential = await FirebaseAuth.instance.signInWithPopup(provider);
    } else {
      final googleUser = await (_googleClient ??= GoogleSignIn()).signIn();
      if (googleUser == null) return null;
      final auth = await googleUser.authentication;
      final providerCredential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      credential = await FirebaseAuth.instance.signInWithCredential(
        providerCredential,
      );
    }

    final user = credential.user;
    if (user == null) return null;
    return AuthSession(
      status: AuthStatus.signedIn,
      userId: user.uid,
      displayName: user.displayName ?? user.email ?? 'Vera User',
      email: user.email,
      signedInAt: user.metadata.creationTime ?? DateTime.now(),
      authMethod: 'google',
    );
  }
}

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService(ref.watch(firebaseBootstrapProvider), ref);
});
