import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_storage.dart';
import '../domain/auth_session.dart';

class AuthController extends StateNotifier<AuthSession> {
  AuthController(this._storage)
      : super(const AuthSession(status: AuthStatus.loading)) {
    _restore();
  }

  final AuthStorage _storage;

  Future<void> _restore() async {
    final session = await _storage.readSession();
    if (session == null) {
      state = const AuthSession(status: AuthStatus.signedOut);
      return;
    }
    state = session;
  }

  Future<void> signInDemo({
    required String displayName,
    required String email,
  }) async {
    final session = AuthSession(
      status: AuthStatus.signedIn,
      userId: 'demo-user',
      displayName: displayName,
      email: email,
      signedInAt: DateTime.now(),
      authMethod: 'demo vault',
    );
    await _storage.writeSession(session);
    state = session;
  }

  Future<void> signOut() async {
    await _storage.clearSession();
    state = const AuthSession(status: AuthStatus.signedOut);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthSession>((ref) {
  return AuthController(ref.watch(authStorageProvider));
});
