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
}
