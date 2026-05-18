/// Result of the in-app loan affordability calculator.
///
/// Pure math: monthly payment is an approximation, debt-to-income and the
/// payment load are derived from user inputs. No bureau score, no fake APR,
/// no "approval" verdict — that data only exists at real lenders.
class CreditCalculation {
  const CreditCalculation({
    required this.monthlyPayment,
    required this.totalCost,
    required this.debtToIncome,
    required this.paymentLoad,
  });

  /// Approximate monthly installment (TL).
  final double monthlyPayment;

  /// Total amount paid over the loan term (TL).
  final double totalCost;

  /// Current debt obligations divided by monthly income (0..1).
  final double debtToIncome;

  /// Estimated installment divided by monthly income (0..1).
  final double paymentLoad;
}
