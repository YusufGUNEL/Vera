enum ApprovalMode { autoWithinGuardrails, confirmLargeMoves }

class AutonomyPolicy {
  const AutonomyPolicy({
    required this.enabled,
    required this.riskProfile,
    required this.monthlyMoveLimit,
    required this.approvalMode,
  });

  final bool enabled;
  final String riskProfile;
  final double monthlyMoveLimit;
  final ApprovalMode approvalMode;

  AutonomyPolicy copyWith({
    bool? enabled,
    String? riskProfile,
    double? monthlyMoveLimit,
    ApprovalMode? approvalMode,
  }) {
    return AutonomyPolicy(
      enabled: enabled ?? this.enabled,
      riskProfile: riskProfile ?? this.riskProfile,
      monthlyMoveLimit: monthlyMoveLimit ?? this.monthlyMoveLimit,
      approvalMode: approvalMode ?? this.approvalMode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'riskProfile': riskProfile,
      'monthlyMoveLimit': monthlyMoveLimit,
      'approvalMode': approvalMode.name,
    };
  }

  factory AutonomyPolicy.fromMap(Map<String, dynamic> map) {
    return AutonomyPolicy(
      enabled: map['enabled'] as bool? ?? true,
      riskProfile: map['riskProfile'] as String? ?? 'Dengeli',
      monthlyMoveLimit: (map['monthlyMoveLimit'] as num?)?.toDouble() ?? 25000,
      approvalMode: ApprovalMode.values.firstWhere(
        (e) => e.name == map['approvalMode'],
        orElse: () => ApprovalMode.confirmLargeMoves,
      ),
    );
  }
}
