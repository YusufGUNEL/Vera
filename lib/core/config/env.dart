import 'package:flutter_dotenv/flutter_dotenv.dart';

/// .env degerlerine type-safe erisim.
/// Yeni env degiskeni eklerken: 1) .env.example'a ekle, 2) burada getter olustur.
class Env {
  Env._();

  /// Gemini API key. `null` ise key tanimsiz veya placeholder — caller
  /// fallback'e dusmeli.
  static String? get geminiApiKey {
    final key = dotenv.maybeGet('GEMINI_API_KEY') ?? '';
    if (key.isEmpty || key == 'your_gemini_api_key_here') return null;
    return key;
  }

  static bool get hasGeminiKey => geminiApiKey != null;

  static String get geminiModel =>
      dotenv.maybeGet('GEMINI_MODEL') ?? 'gemini-2.0-flash-exp';

  static String? get homeFeedUrl => dotenv.maybeGet('HOME_FEED_URL');

  static String? get securityFeedUrl => dotenv.maybeGet('SECURITY_FEED_URL');
}
