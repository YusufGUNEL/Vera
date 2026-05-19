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
    // Standard amortization formula M = P*i*(1+i)^n / ((1+i)^n - 1).
    // The annual rate is a planning ballpark — TR consumer loans currently
    // sit in roughly the 40–55% APR band; Gemini fills in real per-bank
    // quotes elsewhere.
    const annualRate = 0.45;
    final monthlyRate = annualRate / 12.0;
    final n = application.months;
    final growth = _pow(1 + monthlyRate, n);
    return application.amount * monthlyRate * growth / (growth - 1);
  }

  double _pow(double base, int exp) {
    var result = 1.0;
    for (var i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }
}
