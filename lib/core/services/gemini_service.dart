import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../config/env.dart';

/// Gemini API ile tek dokunma noktasi.
/// Tum feature'lar buradan gecsin - direkt GenerativeModel insantsiate etmeyin.
///
/// API key tanimsiz ise servis "offline mode"da boot eder; uretim cagrilari
/// [MissingGeminiKeyException] firlatir. Repository katmaninda her cagri
/// try/catch ile fallback'e baglanmalidir (bkz. docs/PROMPTS.md).
class GeminiService {
  GeminiService._(this._model);

  final GenerativeModel? _model;

  bool get isAvailable => _model != null;

  factory GeminiService.create() {
    final apiKey = Env.geminiApiKey;
    if (apiKey == null) {
      return GeminiService._(null);
    }
    final model = GenerativeModel(
      model: Env.geminiModel,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 2048,
      ),
    );
    return GeminiService._(model);
  }

  /// Tek seferlik metin uretimi (tek prompt, tek cevap).
  Future<String> generateText(String prompt) async {
    final model = _model;
    if (model == null) throw const MissingGeminiKeyException();
    final response = await model.generateContent([Content.text(prompt)]);
    return response.text ?? '';
  }

  /// Streaming metin uretimi - chat icin ideal.
  Stream<String> streamText(String prompt) async* {
    final model = _model;
    if (model == null) throw const MissingGeminiKeyException();
    final stream = model.generateContentStream([Content.text(prompt)]);
    await for (final chunk in stream) {
      if (chunk.text != null) yield chunk.text!;
    }
  }

  /// Multi-turn chat baslatir. Konusma gecmisini Gemini saklar.
  ChatSession startChat({List<Content>? history}) {
    final model = _model;
    if (model == null) throw const MissingGeminiKeyException();
    return model.startChat(history: history ?? []);
  }

  /// Multimodal: gorsel + metin.
  Future<String> analyzeImage({
    required Uint8List imageBytes,
    required String prompt,
    String mimeType = 'image/jpeg',
  }) async {
    final model = _model;
    if (model == null) throw const MissingGeminiKeyException();
    final response = await model.generateContent([
      Content.multi([
        TextPart(prompt),
        DataPart(mimeType, imageBytes),
      ]),
    ]);
    return response.text ?? '';
  }
}

class MissingGeminiKeyException implements Exception {
  const MissingGeminiKeyException();

  @override
  String toString() =>
      'GEMINI_API_KEY tanimli degil. .env dosyasina ekleyince Gemini aktiflesir.';
}

/// Riverpod provider - tum feature'lar bunu kullansin.
final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService.create();
});
