import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/state/auth_controller.dart';

enum AiTone { concise, coach, proactive }

class ProfileState {
  const ProfileState({
    this.notificationsEnabled = true,
    this.faceIdEnabled = true,
    this.fraudAlertsEnabled = true,
    this.aiTone = AiTone.coach,
  });

  final bool notificationsEnabled;
  final bool faceIdEnabled;
  final bool fraudAlertsEnabled;
  final AiTone aiTone;

  ProfileState copyWith({
    bool? notificationsEnabled,
    bool? faceIdEnabled,
    bool? fraudAlertsEnabled,
    AiTone? aiTone,
  }) {
    return ProfileState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      faceIdEnabled: faceIdEnabled ?? this.faceIdEnabled,
      fraudAlertsEnabled: fraudAlertsEnabled ?? this.fraudAlertsEnabled,
      aiTone: aiTone ?? this.aiTone,
    );
  }
}

const _kNotificationsKey = 'profile.notifications';
const _kFaceIdKey = 'profile.face_id';
const _kFraudAlertsKey = 'profile.fraud_alerts';
const _kAiToneKey = 'profile.ai_tone';

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController() : super(const ProfileState()) {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    state = ProfileState(
      notificationsEnabled: prefs.getBool(_kNotificationsKey) ?? true,
      faceIdEnabled: prefs.getBool(_kFaceIdKey) ?? true,
      fraudAlertsEnabled: prefs.getBool(_kFraudAlertsKey) ?? true,
      aiTone: _toneByName(prefs.getString(_kAiToneKey)),
    );
  }

  Future<void> setNotifications(bool value) async {
    state = state.copyWith(notificationsEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotificationsKey, value);
  }

  Future<void> setFaceId(bool value) async {
    state = state.copyWith(faceIdEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kFaceIdKey, value);
  }

  Future<void> setFraudAlerts(bool value) async {
    state = state.copyWith(fraudAlertsEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kFraudAlertsKey, value);
  }

  Future<void> setAiTone(AiTone tone) async {
    state = state.copyWith(aiTone: tone);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAiToneKey, tone.name);
  }
}

AiTone _toneByName(String? name) {
  for (final tone in AiTone.values) {
    if (tone.name == name) return tone;
  }
  return AiTone.coach;
}

final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>((ref) {
  ref.watch(authControllerProvider);
  return ProfileController();
});
