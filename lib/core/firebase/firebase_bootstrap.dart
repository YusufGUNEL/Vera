import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';
import '../../firebase_options.dart';

class FirebaseBootstrapState {
  const FirebaseBootstrapState({
    required this.enabled,
    required this.initialized,
    this.hasCoreConfig = false,
    this.source = 'unconfigured',
    this.debugMessage,
    this.error,
  });

  final bool enabled;
  final bool initialized;
  final bool hasCoreConfig;
  final String source;
  final String? debugMessage;
  final Object? error;

  bool get ready => enabled && initialized && error == null;

  bool get runningLocalOnly => !ready;

  String get summary {
    final parts = <String>[
      'enabled=$enabled',
      'initialized=$initialized',
      'hasCoreConfig=$hasCoreConfig',
      'source=$source',
    ];
    if (debugMessage != null && debugMessage!.isNotEmpty) {
      parts.add('debug=$debugMessage');
    }
    if (error != null) {
      parts.add('error=$error');
    }
    return parts.join(' ');
  }
}

class FirebaseBootstrap {
  FirebaseBootstrap._();

  static FirebaseBootstrapState _state =
      const FirebaseBootstrapState(
        enabled: false,
        initialized: false,
        hasCoreConfig: false,
      );

  static FirebaseBootstrapState get state => _state;

  static Future<FirebaseBootstrapState> ensureInitialized() async {
    if (_state.initialized || _state.error != null) return _state;

    final options = _currentOptions;
    if (options == null) {
      _state = FirebaseBootstrapState(
        enabled: false,
        initialized: false,
        hasCoreConfig: Env.hasFirebaseCoreConfig,
        source: 'local-only',
        debugMessage: Env.hasFirebaseCoreConfig
            ? 'Firebase options are not available for this platform.'
            : 'Firebase core config is missing; continuing in local-only mode.',
      );
      debugPrint('[FirebaseBootstrap] ${_state.summary}');
      return _state;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: options);
      }

      if (!kIsWeb) {
        await FirebaseAppCheck.instance.activate(
          androidProvider: kDebugMode
              ? AndroidProvider.debug
              : AndroidProvider.playIntegrity,
          appleProvider:
              kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
        );
      }

      _state = const FirebaseBootstrapState(
        enabled: true,
        initialized: true,
        hasCoreConfig: true,
        source: 'firebase_options',
        debugMessage: 'Firebase initialized successfully.',
      );
    } catch (error) {
      _state = FirebaseBootstrapState(
        enabled: true,
        initialized: false,
        hasCoreConfig: true,
        source: 'firebase_options',
        debugMessage:
            'Firebase initialization failed; app will continue in local-only mode.',
        error: error,
      );
    }
    debugPrint('[FirebaseBootstrap] ${_state.summary}');
    return _state;
  }

  static FirebaseOptions? get _currentOptions {
    try {
      return DefaultFirebaseOptions.currentPlatform;
    } catch (_) {
      // Fall through to env-based configuration for unsupported or
      // not-yet-configured platforms.
    }

    if (!Env.hasFirebaseCoreConfig) return null;

    if (kIsWeb) {
      final appId = Env.firebaseAppIdWeb;
      if (appId == null) return null;
      return FirebaseOptions(
        apiKey: Env.firebaseApiKey!,
        appId: appId,
        messagingSenderId: Env.firebaseMessagingSenderId!,
        projectId: Env.firebaseProjectId!,
        storageBucket: Env.firebaseStorageBucket,
        authDomain: Env.firebaseAuthDomain,
        measurementId: Env.firebaseMeasurementId,
      );
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final appId = Env.firebaseAppIdAndroid;
      if (appId == null) return null;
      return FirebaseOptions(
        apiKey: Env.firebaseApiKey!,
        appId: appId,
        messagingSenderId: Env.firebaseMessagingSenderId!,
        projectId: Env.firebaseProjectId!,
        storageBucket: Env.firebaseStorageBucket,
      );
    }

    return null;
  }
}

final firebaseBootstrapProvider = Provider<FirebaseBootstrapState>((ref) {
  return FirebaseBootstrap.state;
});
