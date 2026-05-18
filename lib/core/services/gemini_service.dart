import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../config/env.dart';
import '../firebase/firebase_bootstrap.dart';
import '../firebase/remote_config_service.dart';

/// Gemini requests are proxied through Firebase Functions so the API key stays
/// in Secret Manager instead of shipping inside the client app.
class GeminiService {
  GeminiService._({
    required this.modelName,
    required HttpsCallable? generateTextCallable,
    required HttpsCallable? analyzeImageCallable,
    required HttpsCallable? runAgentCallable,
  })  : _generateTextCallable = generateTextCallable,
        _analyzeImageCallable = analyzeImageCallable,
        _runAgentCallable = runAgentCallable;

  final String modelName;
  final HttpsCallable? _generateTextCallable;
  final HttpsCallable? _analyzeImageCallable;
  final HttpsCallable? _runAgentCallable;

  bool get isAvailable =>
      _generateTextCallable != null &&
      _analyzeImageCallable != null &&
      _runAgentCallable != null;

  factory GeminiService.create(RemoteConfigService rc) {
    if (!FirebaseBootstrap.state.ready || !Env.hasFirebaseCoreConfig) {
      return GeminiService._(
        modelName: rc.geminiModel,
        generateTextCallable: null,
        analyzeImageCallable: null,
        runAgentCallable: null,
      );
    }

    final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
    return GeminiService._(
      modelName: rc.geminiModel,
      generateTextCallable: functions.httpsCallable('geminiGenerateText'),
      analyzeImageCallable: functions.httpsCallable('geminiAnalyzeImage'),
      runAgentCallable: functions.httpsCallable('geminiRunAgent'),
    );
  }

  Future<String> generateText(String prompt) async {
    final callable = _generateTextCallable;
    if (callable == null) throw const MissingGeminiBackendException();
    final result = await callable.call(<String, Object?>{
      'prompt': prompt,
      'model': modelName,
    });
    final data = _asMap(result.data);
    return (data['text'] as String?) ?? '';
  }

  Stream<String> streamText(String prompt) async* {
    yield await generateText(prompt);
  }

  ChatSession startChat({List<Content>? history}) {
    throw UnsupportedError(
      'Stateful chat sessions are handled by the backend proxy.',
    );
  }

  Future<String> analyzeImage({
    required Uint8List imageBytes,
    required String prompt,
    String mimeType = 'image/jpeg',
  }) async {
    final callable = _analyzeImageCallable;
    if (callable == null) throw const MissingGeminiBackendException();
    final result = await callable.call(<String, Object?>{
      'prompt': prompt,
      'mimeType': mimeType,
      'data': base64Encode(imageBytes),
      'model': modelName,
    });
    final data = _asMap(result.data);
    return (data['text'] as String?) ?? '';
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
    if (callable == null) throw const MissingGeminiBackendException();
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
  const AgentResult({required this.text, required this.calls});

  final String text;
  final List<String> calls;
}

class MissingGeminiBackendException implements Exception {
  const MissingGeminiBackendException();

  @override
  String toString() =>
      'Gemini backend hazir degil. Firebase Functions deploy ve secret ayarini kontrol et.';
}

final geminiServiceProvider = Provider<GeminiService>((ref) {
  ref.watch(firebaseBootstrapProvider);
  return GeminiService.create(ref.watch(remoteConfigServiceProvider));
});
