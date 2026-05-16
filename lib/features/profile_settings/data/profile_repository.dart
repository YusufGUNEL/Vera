import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/state/auth_controller.dart';
import 'firebase_profile_service.dart';
import '../domain/profile_state.dart';

const _kNotificationsKey = 'profile.notifications';
const _kFaceIdKey = 'profile.face_id';
const _kFraudAlertsKey = 'profile.fraud_alerts';
const _kAiToneKey = 'profile.ai_tone';
const _kDailyBriefingKey = 'profile.daily_briefing';
const _kDataSyncModeKey = 'profile.data_sync_mode';
const _kAutoApproveLimitKey = 'profile.auto_approve_limit';

class ProfileRepository {
  ProfileRepository(this._firebaseService);

  final FirebaseProfileService _firebaseService;

  Future<ProfileState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final local = ProfileState(
      notificationsEnabled: prefs.getBool(_kNotificationsKey) ?? true,
      faceIdEnabled: prefs.getBool(_kFaceIdKey) ?? true,
      fraudAlertsEnabled: prefs.getBool(_kFraudAlertsKey) ?? true,
      dailyBriefingEnabled: prefs.getBool(_kDailyBriefingKey) ?? true,
      aiTone: aiToneByName(prefs.getString(_kAiToneKey)),
      dataSyncMode: dataSyncModeByName(prefs.getString(_kDataSyncModeKey)),
      autoApproveLimit: prefs.getInt(_kAutoApproveLimitKey) ?? 2500,
    );

    if (!_firebaseService.isEnabled) return local;

    final remote = await _firebaseService.loadSettings();
    if (remote == null) return local;
    await _saveLocal(remote);
    return remote;
  }

  Future<void> save(ProfileState state) async {
    await _saveLocal(state);
    if (_firebaseService.isEnabled) {
      await _firebaseService.saveSettings(state);
    }
  }

  Future<void> _saveLocal(ProfileState state) async {
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

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  ref.watch(authControllerProvider);
  return ProfileRepository(ref.watch(firebaseProfileServiceProvider));
});
