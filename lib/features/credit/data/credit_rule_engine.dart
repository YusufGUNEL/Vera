import '../domain/credit_decision.dart';
import '../domain/loan_application.dart';

/// Pure math for the in-app loan affordability calculator. No fake credit
/// score, no fake APR, no "approval" — those exist only at real bureaus.
class CreditRuleEngine {
  const CreditRuleEngine();

  CreditCalculation evaluate(LoanApplication application) {
    final monthlyPayment = _estimatedMonthlyPayment(application);
    final totalCost = monthlyPayment * application.months;
    final paymentLoad = application.monthlyIncome <= 0
        ? 0.0
        : monthlyPayment / application.monthlyIncome;
    return CreditCalculation(
      monthlyPayment: monthlyPayment,
      totalCost: totalCost,
      debtToIncome: application.debtToIncome,
      paymentLoad: paymentLoad,
    );
  }

  double _estimatedMonthlyPayment(LoanApplication application) {
    if (application.amount <= 0 || application.months <= 0) return 0;
    // Rough TR consumer-loan ballpark: ~16% annual cost-of-funds spread over
    // term + ~1% per year of term as a smoothing factor. Real lender quotes
    // will differ; this is for planning only.
    final interestMultiplier = 1.16 + (application.months / 100);
    return (application.amount * interestMultiplier) / application.months;
  }
}
