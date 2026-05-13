import 'package:flutter_dotenv/flutter_dotenv.dart';

/// .env degerlerine type-safe erisim.
/// Yeni env degiskeni eklerken: 1) .env.example'a ekle, 2) burada getter olustur.
class Env {
  Env._();

  static String get geminiApiKey {
    final key = dotenv.maybeGet('GEMINI_API_KEY') ?? '';
    if (key.isEmpty || key == 'your_gemini_api_key_here') {
      throw StateError(
        'GEMINI_API_KEY .env dosyasinda tanimli degil. '
        '.env.example dosyasini kopyalayip .env yapip API key ekle.',
      );
    }
    return key;
  }

  static String get geminiModel =>
      dotenv.maybeGet('GEMINI_MODEL') ?? 'gemini-2.0-flash-exp';
}
