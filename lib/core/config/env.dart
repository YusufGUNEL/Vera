import 'package:flutter_dotenv/flutter_dotenv.dart';

/// .env degerlerine type-safe erisim.
/// Yeni env degiskeni eklerken: 1) .env.example'a ekle, 2) burada getter olustur.
class Env {
  Env._();

  static String get geminiModel =>
      dotenv.maybeGet('GEMINI_MODEL') ?? 'gemini-2.5-flash';

  static String? get geminiApiKey => _clean('GEMINI_API_KEY');

  static String? get homeFeedUrl => dotenv.maybeGet('HOME_FEED_URL');

  static String? get securityFeedUrl => dotenv.maybeGet('SECURITY_FEED_URL');

  static String? get firebaseApiKey => _clean('FIREBASE_API_KEY');

  static String? get firebaseAppIdAndroid => _clean('FIREBASE_APP_ID_ANDROID');

  static String? get firebaseAppIdWeb => _clean('FIREBASE_APP_ID_WEB');

  static String? get firebaseMessagingSenderId =>
      _clean('FIREBASE_MESSAGING_SENDER_ID');

  static String? get firebaseProjectId => _clean('FIREBASE_PROJECT_ID');

  static String? get firebaseStorageBucket => _clean('FIREBASE_STORAGE_BUCKET');

  static String? get firebaseAuthDomain => _clean('FIREBASE_AUTH_DOMAIN');

  static String? get firebaseMeasurementId => _clean('FIREBASE_MEASUREMENT_ID');

  static bool get hasFirebaseCoreConfig {
    return firebaseApiKey != null &&
        firebaseMessagingSenderId != null &&
        firebaseProjectId != null;
  }

  static String? _clean(String key) {
    final value = dotenv.maybeGet(key)?.trim() ?? '';
    return value.isEmpty ? null : value;
  }
}
