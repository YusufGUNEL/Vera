import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../localization/app_locale.dart';
import '../localization/locale_controller.dart';

enum VoiceStatus {
  /// Engine not initialized or unavailable on this device.
  unavailable,

  /// Engine ready, waiting for the user to start.
  idle,

  /// Currently recording / streaming audio.
  listening,

  /// Microphone permission was denied — user must enable it in OS settings.
  permissionDenied,
}

class VoiceState {
  const VoiceState({
    required this.status,
    this.partialText = '',
  });

  final VoiceStatus status;

  /// Live transcription while listening; cleared on stop / on next start.
  final String partialText;

  VoiceState copyWith({VoiceStatus? status, String? partialText}) {
    return VoiceState(
      status: status ?? this.status,
      partialText: partialText ?? this.partialText,
    );
  }
}

/// Wraps the `speech_to_text` engine so the UI can start/stop listening and
/// receive a final transcript via [onFinalResult].
///
/// Designed for Uma chat: tap mic → listen → on final phrase / silence,
/// emit the recognized text once and return to [VoiceStatus.idle].
class VoiceInputController extends StateNotifier<VoiceState> {
  VoiceInputController(this._ref)
      : super(const VoiceState(status: VoiceStatus.idle));

  final Ref _ref;
  final SpeechToText _engine = SpeechToText();
  bool _engineReady = false;
  void Function(String text)? _pendingOnFinal;

  Future<bool> _ensureReady() async {
    if (_engineReady) return true;
    try {
      final ok = await _engine.initialize(
        onError: (e) {
          state = state.copyWith(status: VoiceStatus.idle, partialText: '');
        },
        onStatus: (status) {
          if (status == SpeechToText.notListeningStatus &&
              state.status == VoiceStatus.listening) {
            state = state.copyWith(status: VoiceStatus.idle);
          }
        },
      );
      _engineReady = ok;
      if (!ok) {
        state = state.copyWith(status: VoiceStatus.unavailable);
      }
      return ok;
    } catch (_) {
      state = state.copyWith(status: VoiceStatus.unavailable);
      return false;
    }
  }

  /// Starts listening. [onFinalResult] fires once when the engine returns a
  /// final phrase (or the user stops). Re-entrant calls are ignored.
  Future<void> start({required void Function(String text) onFinalResult}) async {
    if (state.status == VoiceStatus.listening) return;

    final ready = await _ensureReady();
    if (!ready) return;

    if (!await _engine.hasPermission) {
      state = state.copyWith(status: VoiceStatus.permissionDenied);
      return;
    }

    _pendingOnFinal = onFinalResult;
    state = const VoiceState(status: VoiceStatus.listening, partialText: '');

    try {
      await _engine.listen(
        localeId: _bestLocaleId(),
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.confirmation,
        ),
        onResult: _handleResult,
      );
    } catch (_) {
      state = const VoiceState(status: VoiceStatus.idle);
      _pendingOnFinal = null;
    }
  }

  /// Stops listening early. If a partial transcript exists, treats it as final.
  Future<void> stop() async {
    if (state.status != VoiceStatus.listening) return;
    final partial = state.partialText;
    try {
      await _engine.stop();
    } catch (_) {/* swallow — state cleanup below */}
    final cb = _pendingOnFinal;
    _pendingOnFinal = null;
    state = const VoiceState(status: VoiceStatus.idle);
    if (partial.trim().isNotEmpty) {
      cb?.call(partial.trim());
    }
  }

  void _handleResult(SpeechRecognitionResult result) {
    state = state.copyWith(partialText: result.recognizedWords);
    if (result.finalResult) {
      final cb = _pendingOnFinal;
      _pendingOnFinal = null;
      final words = result.recognizedWords.trim();
      state = const VoiceState(status: VoiceStatus.idle);
      if (words.isNotEmpty) cb?.call(words);
    }
  }

  /// Maps the user's UI locale to a BCP-47 STT locale identifier the engine
  /// can use. Falls back to system default if unsupported.
  String? _bestLocaleId() {
    final locale = _ref.read(localeControllerProvider);
    return switch (locale) {
      AppLocale.tr => 'tr_TR',
      AppLocale.en => 'en_US',
      AppLocale.de => 'de_DE',
      AppLocale.ar => 'ar_SA',
      AppLocale.ru => 'ru_RU',
      AppLocale.zh => 'zh_CN',
    };
  }

  @override
  void dispose() {
    if (state.status == VoiceStatus.listening) {
      _engine.stop();
    }
    super.dispose();
  }
}

final voiceInputControllerProvider =
    StateNotifierProvider<VoiceInputController, VoiceState>((ref) {
  return VoiceInputController(ref);
});
