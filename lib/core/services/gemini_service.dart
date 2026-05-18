import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../config/env.dart';
import '../firebase/remote_config_service.dart';

/// Gemini API ile tek dokunma noktasi.
/// Tum feature'lar buradan gecsin - direkt GenerativeModel insantsiate etmeyin.
///
/// API key tanimsiz ise servis "offline mode"da boot eder; uretim cagrilari
/// [MissingGeminiKeyException] firlatir. Repository katmaninda her cagri
/// try/catch ile fallback'e baglanmalidir (bkz. docs/PROMPTS.md).
class GeminiService {
  GeminiService._({this.apiKey, this.modelName, GenerativeModel? model})
      : _model = model;

  final String? apiKey;
  final String? modelName;
  final GenerativeModel? _model;

  bool get isAvailable => _model != null;

  factory GeminiService.create(RemoteConfigService rc) {
    final apiKey = Env.geminiApiKey;
    if (apiKey == null) {
      return GeminiService._();
    }
    final model = GenerativeModel(
      model: rc.geminiModel,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 2048,
      ),
    );
    return GeminiService._(apiKey: apiKey, modelName: rc.geminiModel, model: model);
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

  /// Function-calling loop. Builds a fresh model with [tools] attached, runs
  /// up to [maxIterations] turns, executes each function call via [onCall],
  /// and returns the model's final text reply together with the list of tool
  /// names that were actually invoked.
  ///
  /// If [maxIterations] is exhausted before the model returns plain text,
  /// the last partial text (or an empty string) is returned with the recorded
  /// calls — the caller can still surface what happened.
  Future<AgentResult> runAgent({
    required String prompt,
    required List<Tool> tools,
    required Future<Map<String, Object?>> Function(
      String name,
      Map<String, Object?> args,
    ) onCall,
    int maxIterations = 3,
  }) async {
    final key = apiKey;
    final name = modelName;
    if (key == null || name == null) {
      throw const MissingGeminiKeyException();
    }
    final agent = GenerativeModel(
      model: name,
      apiKey: key,
      tools: tools,
      generationConfig: GenerationConfig(
        temperature: 0.3,
        maxOutputTokens: 1024,
      ),
    );
    final history = <Content>[Content.text(prompt)];
    final calls = <String>[];
    String text = '';

    for (var i = 0; i < maxIterations; i++) {
      final response = await agent.generateContent(history);
      final fnCalls = response.functionCalls.toList();
      if (fnCalls.isEmpty) {
        text = response.text ?? '';
        break;
      }

      final candidate = response.candidates.first;
      history.add(candidate.content);

      final responses = <FunctionResponse>[];
      for (final fc in fnCalls) {
        calls.add(fc.name);
        Map<String, Object?> result;
        try {
          result = await onCall(fc.name, fc.args);
        } catch (e) {
          result = {'error': e.toString()};
        }
        responses.add(FunctionResponse(fc.name, result));
      }
      history.add(Content.functionResponses(responses));
    }

    return AgentResult(text: text, calls: calls);
  }
}

class AgentResult {
  const AgentResult({required this.text, required this.calls});

  /// Final natural-language reply from the model.
  final String text;

  /// Ordered list of tool names invoked during the loop. Caller uses this to
  /// decide which UI confirmation to surface.
  final List<String> calls;
}

class MissingGeminiKeyException implements Exception {
  const MissingGeminiKeyException();

  @override
  String toString() =>
      'GEMINI_API_KEY tanimli degil. .env dosyasina ekleyince Gemini aktiflesir.';
}

/// Riverpod provider - tum feature'lar bunu kullansin.
final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService.create(ref.watch(remoteConfigServiceProvider));
});
