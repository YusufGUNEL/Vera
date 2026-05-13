import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_tokens.dart';
import 'palette.dart';
import 'vibe.dart';

class TweaksState {
  const TweaksState({
    this.paletteId = PaletteId.plum,
    this.mood = MoodId.light,
    this.vibeId = VibeId.standard,
  });

  final PaletteId paletteId;
  final MoodId mood;
  final VibeId vibeId;

  TweaksState copyWith({PaletteId? paletteId, MoodId? mood, VibeId? vibeId}) {
    return TweaksState(
      paletteId: paletteId ?? this.paletteId,
      mood: mood ?? this.mood,
      vibeId: vibeId ?? this.vibeId,
    );
  }

  AppTokens build() => AppTokens.build(
        paletteId: paletteId,
        mood: mood,
        vibeId: vibeId,
      );
}

const _kPaletteKey = 'tweak.palette';
const _kMoodKey = 'tweak.mood';
const _kVibeKey = 'tweak.vibe';

class TweaksController extends StateNotifier<TweaksState> {
  TweaksController() : super(const TweaksState()) {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    state = TweaksState(
      paletteId: _enumByName(
          PaletteId.values, prefs.getString(_kPaletteKey), PaletteId.plum),
      mood: _enumByName(MoodId.values, prefs.getString(_kMoodKey), MoodId.light),
      vibeId:
          _enumByName(VibeId.values, prefs.getString(_kVibeKey), VibeId.standard),
    );
  }

  Future<void> setPalette(PaletteId id) async {
    state = state.copyWith(paletteId: id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPaletteKey, id.name);
  }

  Future<void> setMood(MoodId mood) async {
    state = state.copyWith(mood: mood);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kMoodKey, mood.name);
  }

  Future<void> setVibe(VibeId id) async {
    state = state.copyWith(vibeId: id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kVibeKey, id.name);
  }
}

T _enumByName<T extends Enum>(List<T> values, String? name, T fallback) {
  if (name == null) return fallback;
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}

final tweaksControllerProvider =
    StateNotifierProvider<TweaksController, TweaksState>(
  (ref) => TweaksController(),
);

final tokensProvider = Provider<AppTokens>((ref) {
  return ref.watch(tweaksControllerProvider).build();
});
