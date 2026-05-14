class LoanApplication {
  const LoanApplication({
    required this.amount,
    required this.months,
    required this.monthlyIncome,
    required this.monthlyDebt,
  });

  final double amount;
  final int months;
  final double monthlyIncome;
  final double monthlyDebt;

  double get debtToIncome =>
      monthlyIncome == 0 ? 0 : monthlyDebt / monthlyIncome;

  LoanApplication copyWith({
    double? amount,
    int? months,
    double? monthlyIncome,
    double? monthlyDebt,
  }) {
    return LoanApplication(
      amount: amount ?? this.amount,
      months: months ?? this.months,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyDebt: monthlyDebt ?? this.monthlyDebt,
    );
  }
}
