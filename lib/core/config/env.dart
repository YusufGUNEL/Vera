import 'package:flutter_dotenv/flutter_dotenv.dart';

/// .env degerlerine type-safe erisim.
/// Yeni env degiskeni eklerken: 1) .env.example'a ekle, 2) burada getter olustur.
class Env {
  Env._();

  static EnvLoadState _state = const EnvLoadState();

  static EnvLoadState get state => _state;

  static bool get isLoaded => _state.loaded;

  static Future<EnvLoadState> load({String fileName = '.env'}) async {
    try {
      await dotenv.load(fileName: fileName, isOptional: true);
      final hasEntries = dotenv.isInitialized && dotenv.env.isNotEmpty;
      _state = EnvLoadState(
        loaded: true,
        source: hasEntries ? fileName : 'optional-empty',
        warning: hasEntries ? null : 'No .env values were loaded.',
      );
    } catch (error) {
      _state = EnvLoadState(
        loaded: false,
        source: fileName,
        warning: '$error',
      );
    }
    return _state;
  }

  static String get geminiModel =>
      _maybeGet('GEMINI_MODEL') ?? 'gemini-2.5-flash';

  static String? get geminiApiKey => _clean('GEMINI_API_KEY');

  static String? get homeFeedUrl => _maybeGet('HOME_FEED_URL');

  static String? get securityFeedUrl => _maybeGet('SECURITY_FEED_URL');

  static bool get hasGeminiApiKey => _clean('GEMINI_API_KEY') != null;

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

  static String get debugSummary {
    final sections = <String>[
      'loaded=$isLoaded',
      'source=${_state.source ?? 'none'}',
      'firebaseCore=$hasFirebaseCoreConfig',
      'geminiKey=$hasGeminiApiKey',
    ];
    if (_state.warning != null && _state.warning!.isNotEmpty) {
      sections.add('warning=${_state.warning}');
    }
    return sections.join(' ');
  }

  static String? _clean(String key) {
    final value = _maybeGet(key)?.trim() ?? '';
    return value.isEmpty ? null : value;
  }

  static String? _maybeGet(String key) {
    if (!dotenv.isInitialized) return null;
    try {
      return dotenv.maybeGet(key);
    } catch (_) {
      return null;
    }
  }
}

class EnvLoadState {
  const EnvLoadState({
    this.loaded = false,
    this.source,
    this.warning,
  });

  final bool loaded;
  final String? source;
  final String? warning;
}
