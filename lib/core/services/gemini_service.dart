import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../config/env.dart';
import '../firebase/firebase_bootstrap.dart';
import '../firebase/remote_config_service.dart';

/// Gemini requests prefer the Firebase Functions proxy (key in Secret Manager).
/// When the proxy is unreachable but a GEMINI_API_KEY is shipped in .env, we
/// fall back to a direct google_generative_ai client so PDF/image parsing
/// keeps working on-device.
class GeminiService {
  GeminiService._({
    required this.modelName,
    required HttpsCallable? generateTextCallable,
    required HttpsCallable? analyzeImageCallable,
    required HttpsCallable? runAgentCallable,
    required String? directApiKey,
  })  : _generateTextCallable = generateTextCallable,
        _analyzeImageCallable = analyzeImageCallable,
        _runAgentCallable = runAgentCallable,
        _directApiKey = directApiKey;

  final String modelName;
  final HttpsCallable? _generateTextCallable;
  final HttpsCallable? _analyzeImageCallable;
  final HttpsCallable? _runAgentCallable;
  final String? _directApiKey;

  bool get _hasProxy =>
      _generateTextCallable != null &&
      _analyzeImageCallable != null &&
      _runAgentCallable != null;

  bool get _hasDirect => _directApiKey != null && _directApiKey.isNotEmpty;

  bool get isAvailable => _hasProxy || _hasDirect;

  factory GeminiService.create(RemoteConfigService rc) {
    final directKey = Env.geminiApiKey;
    final functionsReady =
        FirebaseBootstrap.state.ready && Env.hasFirebaseCoreConfig;
    // .env override wins over Remote Config so a busted RC default can't
    // strand us on a deprecated model name.
    final model = Env.geminiModel.isNotEmpty
        ? Env.geminiModel
        : rc.geminiModel;

    if (!functionsReady) {
      return GeminiService._(
        modelName: model,
        generateTextCallable: null,
        analyzeImageCallable: null,
        runAgentCallable: null,
        directApiKey: directKey,
      );
    }

    final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
    return GeminiService._(
      modelName: model,
      generateTextCallable: functions.httpsCallable('geminiGenerateText'),
      analyzeImageCallable: functions.httpsCallable('geminiAnalyzeImage'),
      runAgentCallable: functions.httpsCallable('geminiRunAgent'),
      directApiKey: directKey,
    );
  }

  GenerativeModel _directModel() {
    return GenerativeModel(model: modelName, apiKey: _directApiKey!);
  }

  Future<String> generateText(String prompt) async {
    final callable = _generateTextCallable;
    if (callable != null) {
      try {
        final result = await callable.call(<String, Object?>{
          'prompt': prompt,
          'model': modelName,
        });
        final data = _asMap(result.data);
        return (data['text'] as String?) ?? '';
      } catch (e) {
        if (!_hasDirect) rethrow;
      }
    }
    if (!_hasDirect) throw const MissingGeminiBackendException();
    final response = await _directModel().generateContent([Content.text(prompt)]);
    return response.text ?? '';
  }

  Stream<String> streamText(String prompt) async* {
    yield await generateText(prompt);
  }

  ChatSession startChat({List<Content>? history}) {
    if (_hasDirect) {
      return _directModel().startChat(history: history);
    }
    throw UnsupportedError(
      'Stateful chat sessions require a direct API key.',
    );
  }

  Future<String> analyzeImage({
    required Uint8List imageBytes,
    required String prompt,
    String mimeType = 'image/jpeg',
  }) async {
    final callable = _analyzeImageCallable;
    if (callable != null) {
      try {
        final result = await callable.call(<String, Object?>{
          'prompt': prompt,
          'mimeType': mimeType,
          'data': base64Encode(imageBytes),
          'model': modelName,
        });
        final data = _asMap(result.data);
        return (data['text'] as String?) ?? '';
      } catch (e) {
        if (!_hasDirect) rethrow;
      }
    }
    if (!_hasDirect) throw const MissingGeminiBackendException();
    // Direct API path: try a sequence of models with exponential-backoff
    // retries on transient 503/UNAVAILABLE. Each model gets up to 3 attempts.
    // Less-throttled / older-stable models come first so we route around the
    // hot 'gemini-2.0-flash' pool when Google is shedding load.
    final parts = [
      Content.multi([
        TextPart(prompt),
        DataPart(mimeType, imageBytes),
      ]),
    ];
    // 2.5-flash leads (free-tier 2.0-* models are usually quota-exhausted),
    // then fall through to lite / 2.0 variants as a last resort.
    final fallbackChain = <String>[modelName];
    for (final alt in const [
      'gemini-2.5-flash',
      'gemini-flash-latest',
      'gemini-2.5-flash-lite',
      'gemini-2.0-flash-001',
      'gemini-2.0-flash',
      'gemini-2.0-flash-lite',
    ]) {
      if (!fallbackChain.contains(alt)) fallbackChain.add(alt);
    }

    Object? lastError;
    for (final model in fallbackChain) {
      // Up to 2 attempts per model. 429/quota is treated as 'this model is
      // exhausted for now' — jump to the next model immediately. Only retry
      // the same model for true transient 503/overloaded.
      var attempts = 2;
      while (attempts-- > 0) {
        try {
          final m = GenerativeModel(model: model, apiKey: _directApiKey!);
          final response = await m.generateContent(parts);
          return response.text ?? '';
        } catch (e) {
          lastError = e;
          final msg = e.toString();
          final quotaExhausted = msg.contains('exceeded your current quota') ||
              msg.contains('RESOURCE_EXHAUSTED') ||
              msg.contains('429');
          final overloaded = msg.contains('503') ||
              msg.contains('UNAVAILABLE') ||
              msg.contains('overloaded') ||
              msg.contains('high demand');
          if (quotaExhausted) {
            // Don't retry same model — its quota window is closed. Try next.
            break;
          }
          if (!overloaded) {
            throw Exception(lastError);
          }
          if (attempts > 0) {
            await Future.delayed(const Duration(milliseconds: 1500));
          }
        }
      }
    }
    throw GeminiBusyException(lastError?.toString() ?? 'overloaded');
  }

  Future<AgentResult> runAgent({
    required String prompt,
    required List<Tool> tools,
    required Future<Map<String, Object?>> Function(
      String name,
      Map<String, Object?> args,
    ) onCall,
    int maxIterations = 3,
  }) async {
    final callable = _runAgentCallable;
    if (callable != null) {
      try {
        final result = await callable.call(<String, Object?>{
          'prompt': prompt,
          'tools': tools.map((tool) => tool.toJson()).toList(),
          'model': modelName,
          'maxIterations': maxIterations,
        });
        final data = _asMap(result.data);
        final callEntries = (data['calls'] as List?) ?? const [];
        final calls = <String>[];

        for (final entry in callEntries) {
          final call = _asMap(entry);
          final name = (call['name'] as String?)?.trim();
          if (name == null || name.isEmpty) continue;
          calls.add(name);
          final args = _asMap(call['args']);
          await onCall(name, args);
        }

        return AgentResult(
          text: ((data['text'] as String?) ?? '').trim(),
          calls: calls,
        );
      } catch (e) {
        if (!_hasDirect) rethrow;
      }
    }
    if (!_hasDirect) throw const MissingGeminiBackendException();

    final model = GenerativeModel(
      model: modelName,
      apiKey: _directApiKey!,
      tools: tools,
    );
    final calls = <String>[];
    final chat = model.startChat();
    var response = await chat.sendMessage(Content.text(prompt));
    var iterations = 0;
    while (response.functionCalls.isNotEmpty && iterations < maxIterations) {
      final replies = <Content>[];
      for (final functionCall in response.functionCalls) {
        calls.add(functionCall.name);
        final result = await onCall(functionCall.name, functionCall.args);
        replies.add(
          Content.functionResponse(functionCall.name, result),
        );
      }
      response = await chat.sendMessage(
        replies.length == 1
            ? replies.single
            : Content.multi(
                replies.expand((c) => c.parts).toList(),
              ),
      );
      iterations++;
    }
    return AgentResult(
      text: (response.text ?? '').trim(),
      calls: calls,
      payload: const <String, Object?>{},
    );
  }

  Map<String, Object?> _asMap(Object? value) {
    if (value is Map) {
      return value.map(
        (key, mapValue) => MapEntry(key.toString(), mapValue as Object?),
      );
    }
    return const <String, Object?>{};
  }
}

class AgentResult {
  const AgentResult({
    required this.text,
    required this.calls,
    this.payload = const <String, Object?>{},
  });

  final String text;
  final List<String> calls;
  final Map<String, Object?> payload;
}

class MissingGeminiBackendException implements Exception {
  const MissingGeminiBackendException();

  @override
  String toString() =>
      'Gemini backend hazir degil. Firebase Functions deploy ve secret ayarini kontrol et.';
}

/// Thrown when every model + retry in the chain returns a transient
/// 503/overloaded OR a 429/quota-exhausted response. Callers should treat
/// this as "try again later" rather than a hard failure.
class GeminiBusyException implements Exception {
  const GeminiBusyException(this.upstream);
  final String upstream;

  @override
  String toString() =>
      'Gemini şu an yoğun veya kota dolu. Birkaç dakika sonra tekrar dene ya da işlemleri manuel ekle.';
}

final geminiServiceProvider = Provider<GeminiService>((ref) {
  ref.watch(firebaseBootstrapProvider);
  return GeminiService.create(ref.watch(remoteConfigServiceProvider));
});
