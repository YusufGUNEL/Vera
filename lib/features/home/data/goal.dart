class FinancialGoal {
  const FinancialGoal({
    required this.target,
    required this.saved,
    required this.monthlyContribution,
  });

  final double target;
  final double saved;
  final double monthlyContribution;

  double get progress =>
      target <= 0 ? 0 : (saved / target).clamp(0.0, 1.0).toDouble();

  double get remaining => (target - saved).clamp(0, double.infinity).toDouble();

  bool get isReached => saved >= target;

  /// Naive ETA assuming current monthly_contribution; returns null when target
  /// is already reached or there is no positive contribution to extrapolate.
  int? get etaMonths {
    if (isReached) return 0;
    if (monthlyContribution <= 0) return null;
    return (remaining / monthlyContribution).ceil();
  }

  FinancialGoal copyWith({
    double? target,
    double? saved,
    double? monthlyContribution,
  }) {
    return FinancialGoal(
      target: target ?? this.target,
      saved: saved ?? this.saved,
      monthlyContribution: monthlyContribution ?? this.monthlyContribution,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'target': target,
      'saved': saved,
      'monthlyContribution': monthlyContribution,
    };
  }

  factory FinancialGoal.fromMap(Map<String, dynamic> map) {
    return FinancialGoal(
      target: (map['target'] as num?)?.toDouble() ?? 50000,
      saved: (map['saved'] as num?)?.toDouble() ?? 38000,
      monthlyContribution:
          (map['monthlyContribution'] as num?)?.toDouble() ?? 2500,
    );
  }

  static const seed = FinancialGoal(
    target: 50000,
    saved: 38000,
    monthlyContribution: 2500,
  );
}
