import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/firebase/analytics_service.dart';
import 'core/firebase/fcm_service.dart';
import 'core/firebase/firebase_bootstrap.dart';
import 'core/firebase/remote_config_service.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.load();
  final bootstrap = await FirebaseBootstrap.ensureInitialized();
  await NotificationService.instance.init();
  await RemoteConfigService(bootstrap).init();
  await FcmService(bootstrap).init();

  debugPrint('[Env] ${Env.debugSummary}');
  debugPrint('[Startup] ${bootstrap.summary}');

  // Crashlytics: Firebase hazırsa hata yakalama aktif.
  if (bootstrap.ready && !kDebugMode && !kIsWeb) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  runApp(
    ProviderScope(
      child: Consumer(
        builder: (context, ref, _) {
          // Eager init: Remote Config fetch + FCM token kaydı.
          ref
            ..watch(remoteConfigServiceProvider)
            ..watch(fcmServiceProvider)
            ..watch(analyticsServiceProvider);
          return const VeraApp();
        },
      ),
    ),
  );
}
