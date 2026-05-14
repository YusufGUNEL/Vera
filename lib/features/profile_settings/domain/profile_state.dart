enum AiTone { concise, coach, proactive }

enum DataSyncMode { live, balanced, saver }

class ProfileState {
  const ProfileState({
    this.notificationsEnabled = true,
    this.faceIdEnabled = true,
    this.fraudAlertsEnabled = true,
    this.dailyBriefingEnabled = true,
    this.aiTone = AiTone.coach,
    this.dataSyncMode = DataSyncMode.live,
    this.autoApproveLimit = 2500,
  });

  final bool notificationsEnabled;
  final bool faceIdEnabled;
  final bool fraudAlertsEnabled;
  final bool dailyBriefingEnabled;
  final AiTone aiTone;
  final DataSyncMode dataSyncMode;
  final int autoApproveLimit;

  ProfileState copyWith({
    bool? notificationsEnabled,
    bool? faceIdEnabled,
    bool? fraudAlertsEnabled,
    bool? dailyBriefingEnabled,
    AiTone? aiTone,
    DataSyncMode? dataSyncMode,
    int? autoApproveLimit,
  }) {
    return ProfileState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      faceIdEnabled: faceIdEnabled ?? this.faceIdEnabled,
      fraudAlertsEnabled: fraudAlertsEnabled ?? this.fraudAlertsEnabled,
      dailyBriefingEnabled: dailyBriefingEnabled ?? this.dailyBriefingEnabled,
      aiTone: aiTone ?? this.aiTone,
      dataSyncMode: dataSyncMode ?? this.dataSyncMode,
      autoApproveLimit: autoApproveLimit ?? this.autoApproveLimit,
    );
  }
}
