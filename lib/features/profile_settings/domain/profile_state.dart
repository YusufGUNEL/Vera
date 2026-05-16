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

  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'faceIdEnabled': faceIdEnabled,
      'fraudAlertsEnabled': fraudAlertsEnabled,
      'dailyBriefingEnabled': dailyBriefingEnabled,
      'aiTone': aiTone.name,
      'dataSyncMode': dataSyncMode.name,
      'autoApproveLimit': autoApproveLimit,
    };
  }

  factory ProfileState.fromMap(Map<String, dynamic> map) {
    return ProfileState(
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      faceIdEnabled: map['faceIdEnabled'] as bool? ?? true,
      fraudAlertsEnabled: map['fraudAlertsEnabled'] as bool? ?? true,
      dailyBriefingEnabled: map['dailyBriefingEnabled'] as bool? ?? true,
      aiTone: _toneByName(map['aiTone'] as String?),
      dataSyncMode: _syncModeByName(map['dataSyncMode'] as String?),
      autoApproveLimit: (map['autoApproveLimit'] as num?)?.toInt() ?? 2500,
    );
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
