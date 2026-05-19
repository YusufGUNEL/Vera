class UmaMemoryProfile {
  const UmaMemoryProfile({
    this.spendingSensitivity = 'balanced',
    this.riskTone = 'calm',
    this.savingsMotivation = 'safety',
    this.favoriteActionType = 'insight',
    this.lastProductSurface = 'uma_chat',
    this.helpfulFeedbackCount = 0,
    this.notHelpfulFeedbackCount = 0,
  });

  final String spendingSensitivity;
  final String riskTone;
  final String savingsMotivation;
  final String favoriteActionType;
  final String lastProductSurface;
  final int helpfulFeedbackCount;
  final int notHelpfulFeedbackCount;

  UmaMemoryProfile copyWith({
    String? spendingSensitivity,
    String? riskTone,
    String? savingsMotivation,
    String? favoriteActionType,
    String? lastProductSurface,
    int? helpfulFeedbackCount,
    int? notHelpfulFeedbackCount,
  }) {
    return UmaMemoryProfile(
      spendingSensitivity: spendingSensitivity ?? this.spendingSensitivity,
      riskTone: riskTone ?? this.riskTone,
      savingsMotivation: savingsMotivation ?? this.savingsMotivation,
      favoriteActionType: favoriteActionType ?? this.favoriteActionType,
      lastProductSurface: lastProductSurface ?? this.lastProductSurface,
      helpfulFeedbackCount: helpfulFeedbackCount ?? this.helpfulFeedbackCount,
      notHelpfulFeedbackCount:
          notHelpfulFeedbackCount ?? this.notHelpfulFeedbackCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'spendingSensitivity': spendingSensitivity,
      'riskTone': riskTone,
      'savingsMotivation': savingsMotivation,
      'favoriteActionType': favoriteActionType,
      'lastProductSurface': lastProductSurface,
      'helpfulFeedbackCount': helpfulFeedbackCount,
      'notHelpfulFeedbackCount': notHelpfulFeedbackCount,
    };
  }

  factory UmaMemoryProfile.fromMap(Map<String, dynamic> map) {
    return UmaMemoryProfile(
      spendingSensitivity: map['spendingSensitivity'] as String? ?? 'balanced',
      riskTone: map['riskTone'] as String? ?? 'calm',
      savingsMotivation: map['savingsMotivation'] as String? ?? 'safety',
      favoriteActionType: map['favoriteActionType'] as String? ?? 'insight',
      lastProductSurface: map['lastProductSurface'] as String? ?? 'uma_chat',
      helpfulFeedbackCount: (map['helpfulFeedbackCount'] as num?)?.toInt() ?? 0,
      notHelpfulFeedbackCount:
          (map['notHelpfulFeedbackCount'] as num?)?.toInt() ?? 0,
    );
  }

  static const empty = UmaMemoryProfile();
}

class UmaConversationSummary {
  const UmaConversationSummary({
    this.recentTopics = const [],
    this.lastUpdatedAt,
  });

  final List<String> recentTopics;
  final DateTime? lastUpdatedAt;

  UmaConversationSummary copyWith({
    List<String>? recentTopics,
    DateTime? lastUpdatedAt,
  }) {
    return UmaConversationSummary(
      recentTopics: recentTopics ?? this.recentTopics,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recentTopics': recentTopics,
      'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
    };
  }

  factory UmaConversationSummary.fromMap(Map<String, dynamic> map) {
    return UmaConversationSummary(
      recentTopics:
          (map['recentTopics'] as List?)?.whereType<String>().toList() ?? const [],
      lastUpdatedAt: DateTime.tryParse(map['lastUpdatedAt'] as String? ?? ''),
    );
  }

  static const empty = UmaConversationSummary();
}
