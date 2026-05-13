import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../config/env.dart';

/// Gemini API ile tek dokunma noktasi.
/// Tum feature'lar buradan gecsin - direkt GenerativeModel insantsiate etmeyin.
class GeminiService {
  GeminiService._(this._model);

  final GenerativeModel _model;

  factory GeminiService.create() {
    final model = GenerativeModel(
      model: Env.geminiModel,
      apiKey: Env.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 2048,
      ),
    );
    return GeminiService._(model);
  }

  /// Tek seferlik metin uretimi (tek prompt, tek cevap).
  Future<String> generateText(String prompt) async {
    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? '';
  }

  /// Streaming metin uretimi - chat icin ideal.
  Stream<String> streamText(String prompt) async* {
    final stream = _model.generateContentStream([Content.text(prompt)]);
    await for (final chunk in stream) {
      if (chunk.text != null) yield chunk.text!;
    }
  }

  /// Multi-turn chat baslatir. Konusma gecmisini Gemini saklar.
  ChatSession startChat({List<Content>? history}) {
    return _model.startChat(history: history ?? []);
  }

  /// Multimodal: gorsel + metin.
  Future<String> analyzeImage({
    required Uint8List imageBytes,
    required String prompt,
    String mimeType = 'image/jpeg',
  }) async {
    final response = await _model.generateContent([
      Content.multi([
        TextPart(prompt),
        DataPart(mimeType, imageBytes),
      ]),
    ]);
    return response.text ?? '';
  }
}

/// Riverpod provider - tum feature'lar bunu kullansin.
final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService.create();
});
