import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/auth_session.dart';

const _kAuthUserIdKey = 'auth.user_id';
const _kAuthDisplayNameKey = 'auth.display_name';
const _kAuthEmailKey = 'auth.email';
const _kAuthSignedInAtKey = 'auth.signed_in_at';
const _kAuthMethodKey = 'auth.method';

class AuthStorage {
  AuthStorage({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  Future<AuthSession?> readSession() async {
    final values = await _secureStorage.readAll();
    final userId = values[_kAuthUserIdKey];
    final displayName = values[_kAuthDisplayNameKey];
    final email = values[_kAuthEmailKey];

    if (userId == null || displayName == null || email == null) return null;

    return AuthSession(
      status: AuthStatus.signedIn,
      userId: userId,
      displayName: displayName,
      email: email,
      signedInAt: DateTime.tryParse(values[_kAuthSignedInAtKey] ?? ''),
      authMethod: values[_kAuthMethodKey] ?? 'demo vault',
    );
  }

  Future<void> writeSession(AuthSession session) async {
    await _secureStorage.write(key: _kAuthUserIdKey, value: session.userId);
    await _secureStorage.write(
      key: _kAuthDisplayNameKey,
      value: session.displayName,
    );
    await _secureStorage.write(key: _kAuthEmailKey, value: session.email);
    await _secureStorage.write(
      key: _kAuthSignedInAtKey,
      value: session.signedInAt?.toIso8601String(),
    );
    await _secureStorage.write(
      key: _kAuthMethodKey,
      value: session.authMethod,
    );
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: _kAuthUserIdKey);
    await _secureStorage.delete(key: _kAuthDisplayNameKey);
    await _secureStorage.delete(key: _kAuthEmailKey);
    await _secureStorage.delete(key: _kAuthSignedInAtKey);
    await _secureStorage.delete(key: _kAuthMethodKey);
  }
}

final authStorageProvider = Provider<AuthStorage>((ref) {
  return AuthStorage();
});
