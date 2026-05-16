import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kOnboardingDoneKey = 'onboarding.completed';

class OnboardingState {
  const OnboardingState({
    this.loaded = false,
    this.completed = false,
  });

  final bool loaded;
  final bool completed;

  OnboardingState copyWith({bool? loaded, bool? completed}) {
    return OnboardingState(
      loaded: loaded ?? this.loaded,
      completed: completed ?? this.completed,
    );
  }
}

class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController() : super(const OnboardingState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool(_kOnboardingDoneKey) ?? false;
    state = OnboardingState(loaded: true, completed: done);
  }

  Future<void> complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingDoneKey, true);
    state = const OnboardingState(loaded: true, completed: true);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kOnboardingDoneKey);
    state = const OnboardingState(loaded: true, completed: false);
  }
}

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  return OnboardingController();
});
