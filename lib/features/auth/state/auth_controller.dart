import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/firebase/analytics_service.dart';
import '../../../core/firebase/firebase_bootstrap.dart';
import '../../onboarding/state/onboarding_controller.dart';
import '../../profile_settings/data/firebase_profile_service.dart';
import '../data/auth_storage.dart';
import '../data/firebase_auth_service.dart';
import '../domain/auth_session.dart';

class AuthController extends StateNotifier<AuthSession> {
  AuthController(
    this._storage,
    this._firebaseAuthService,
    this._firebaseProfileService,
    this._analytics,
    this._ref,
  ) : super(const AuthSession(status: AuthStatus.loading)) {
    _restore();
  }

  final AuthStorage _storage;
  final FirebaseAuthService _firebaseAuthService;
  final FirebaseProfileService _firebaseProfileService;
  final AnalyticsService _analytics;
  final Ref _ref;

  Future<void> _restore() async {
    final firebaseSession = _firebaseAuthService.currentSession;
    if (firebaseSession != null) {
      await _storage.writeSession(firebaseSession);
      state = firebaseSession;
      return;
    }

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

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final session = await _firebaseAuthService.signInWithEmail(
      email: email,
      password: password,
    );
    await _storage.writeSession(session);
    await _firebaseProfileService.saveProfileShell(
      displayName: session.displayName ?? email,
      email: session.email ?? email,
    );
    await _analytics.logLogin(method: 'firebase_email');
    await _analytics.setUserId(session.userId);
    if (!kDebugMode) {
      await FirebaseCrashlytics.instance.setUserIdentifier(session.userId ?? '');
    }
    state = session;
  }

  Future<void> signUpWithEmail({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final session = await _firebaseAuthService.signUpWithEmail(
      displayName: displayName,
      email: email,
      password: password,
    );
    await _storage.writeSession(session);
    await _firebaseProfileService.saveProfileShell(
      displayName: displayName,
      email: email,
    );
    await _analytics.logSignUp(method: 'firebase_email');
    await _analytics.setUserId(session.userId);
    if (!kDebugMode) {
      await FirebaseCrashlytics.instance.setUserIdentifier(session.userId ?? '');
    }
    state = session;
  }

  Future<void> signOut() async {
    await _firebaseAuthService.signOut();
    await _storage.clearSession();
    await _clearLocalCaches();
    await _ref.read(onboardingControllerProvider.notifier).reset();
    state = const AuthSession(status: AuthStatus.signedOut);
  }

  /// Removes every per-user piece of state we keep in SharedPreferences so
  /// the next account cannot see traces of the previous one.
  Future<void> _clearLocalCaches() async {
    final prefs = await SharedPreferences.getInstance();
    const keys = <String>[
      'home.feed.cache',
      'home.imported.txns',
      'home.custom.banks',
      'home.upcoming.bills',
      'home.goal.emergency',
      'home.category.budgets',
      'security.feed.cache',
      'subscriptions.cache',
      'uma.history',
      'uma.audit',
      'uma.feedback',
    ];
    for (final k in keys) {
      await prefs.remove(k);
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthSession>((ref) {
  ref.watch(firebaseBootstrapProvider);
  return AuthController(
    ref.watch(authStorageProvider),
    ref.watch(firebaseAuthServiceProvider),
    ref.watch(firebaseProfileServiceProvider),
    ref.watch(analyticsServiceProvider),
    ref,
  );
});
