import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/profile_state.dart';

const _kNotificationsKey = 'profile.notifications';
const _kFaceIdKey = 'profile.face_id';
const _kFraudAlertsKey = 'profile.fraud_alerts';
const _kAiToneKey = 'profile.ai_tone';
const _kDailyBriefingKey = 'profile.daily_briefing';
const _kDataSyncModeKey = 'profile.data_sync_mode';
const _kAutoApproveLimitKey = 'profile.auto_approve_limit';

class ProfileRepository {
  Future<ProfileState> load() async {
    final prefs = await SharedPreferences.getInstance();
    return ProfileState(
      notificationsEnabled: prefs.getBool(_kNotificationsKey) ?? true,
      faceIdEnabled: prefs.getBool(_kFaceIdKey) ?? true,
      fraudAlertsEnabled: prefs.getBool(_kFraudAlertsKey) ?? true,
      dailyBriefingEnabled: prefs.getBool(_kDailyBriefingKey) ?? true,
      aiTone: _toneByName(prefs.getString(_kAiToneKey)),
      dataSyncMode: _syncModeByName(prefs.getString(_kDataSyncModeKey)),
      autoApproveLimit: prefs.getInt(_kAutoApproveLimitKey) ?? 2500,
    );
  }

  Future<void> save(ProfileState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotificationsKey, state.notificationsEnabled);
    await prefs.setBool(_kFaceIdKey, state.faceIdEnabled);
    await prefs.setBool(_kFraudAlertsKey, state.fraudAlertsEnabled);
    await prefs.setBool(_kDailyBriefingKey, state.dailyBriefingEnabled);
    await prefs.setString(_kAiToneKey, state.aiTone.name);
    await prefs.setString(_kDataSyncModeKey, state.dataSyncMode.name);
    await prefs.setInt(_kAutoApproveLimitKey, state.autoApproveLimit);
  }
}

AiTone _toneByName(String? name) {
  for (final tone in AiTone.values) {
    if (tone.name == name) return tone;
  }
  return AiTone.coach;
}

DataSyncMode _syncModeByName(String? name) {
  for (final mode in DataSyncMode.values) {
    if (mode.name == name) return mode;
  }
  return DataSyncMode.live;
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});
