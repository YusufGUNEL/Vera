import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/state/auth_controller.dart';
import '../data/profile_repository.dart';
import '../domain/profile_state.dart';

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController(this._repository) : super(const ProfileState()) {
    _restore();
  }

  final ProfileRepository _repository;

  Future<void> _restore() async {
    state = await _repository.load();
  }

  Future<void> _save(ProfileState nextState) async {
    state = nextState;
    await _repository.save(nextState);
  }

  Future<void> setNotifications(bool value) async {
    await _save(state.copyWith(notificationsEnabled: value));
  }

  Future<void> setFaceId(bool value) async {
    await _save(state.copyWith(faceIdEnabled: value));
  }

  Future<void> setFraudAlerts(bool value) async {
    await _save(state.copyWith(fraudAlertsEnabled: value));
  }

  Future<void> setDailyBriefing(bool value) async {
    await _save(state.copyWith(dailyBriefingEnabled: value));
  }

  Future<void> setAiTone(AiTone tone) async {
    await _save(state.copyWith(aiTone: tone));
  }

  Future<void> setDataSyncMode(DataSyncMode mode) async {
    await _save(state.copyWith(dataSyncMode: mode));
  }

  Future<void> setAutoApproveLimit(int limit) async {
    await _save(state.copyWith(autoApproveLimit: limit));
  }
}

final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>((ref) {
  ref.watch(authControllerProvider);
  return ProfileController(ref.watch(profileRepositoryProvider));
});
