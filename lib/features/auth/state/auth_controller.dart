import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/auth_session.dart';

const _kAuthSignedInKey = 'auth.signed_in';
const _kAuthUserIdKey = 'auth.user_id';
const _kAuthDisplayNameKey = 'auth.display_name';
const _kAuthEmailKey = 'auth.email';

class AuthController extends StateNotifier<AuthSession> {
  AuthController() : super(const AuthSession(status: AuthStatus.loading)) {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final signedIn = prefs.getBool(_kAuthSignedInKey) ?? false;

    if (!signedIn) {
      state = const AuthSession(status: AuthStatus.signedOut);
      return;
    }

    state = AuthSession(
      status: AuthStatus.signedIn,
      userId: prefs.getString(_kAuthUserIdKey) ?? 'demo-user',
      displayName: prefs.getString(_kAuthDisplayNameKey) ?? 'Mert Aksoy',
      email: prefs.getString(_kAuthEmailKey) ?? 'mert@aksoy.com',
    );
  }

  Future<void> signInDemo({
    required String displayName,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAuthSignedInKey, true);
    await prefs.setString(_kAuthUserIdKey, 'demo-user');
    await prefs.setString(_kAuthDisplayNameKey, displayName);
    await prefs.setString(_kAuthEmailKey, email);

    state = AuthSession(
      status: AuthStatus.signedIn,
      userId: 'demo-user',
      displayName: displayName,
      email: email,
    );
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAuthSignedInKey);
    await prefs.remove(_kAuthUserIdKey);
    await prefs.remove(_kAuthDisplayNameKey);
    await prefs.remove(_kAuthEmailKey);
    state = const AuthSession(status: AuthStatus.signedOut);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthSession>((ref) {
  return AuthController();
});
