import '../domain/credit_decision.dart';
import '../domain/loan_application.dart';
import '../domain/offer_option.dart';
import '../domain/risk_factor.dart';

class CreditRuleEngine {
  const CreditRuleEngine();

  CreditDecision evaluate(LoanApplication application) {
    final dti = application.debtToIncome;
    final monthlyPayment = _estimatedMonthlyPayment(application);
    final paymentLoad = application.monthlyIncome == 0
        ? 1.0
        : monthlyPayment / application.monthlyIncome;

    var score = 600;
    score +=
        ((application.monthlyIncome - 20000) / 1500).round().clamp(-40, 90);
    score -= (dti * 170).round();
    score -= (paymentLoad * 140).round();
    score += application.months >= 24 ? 18 : 5;
    score = score.clamp(420, 820);

    final riskFactors = <RiskFactor>[
      RiskFactor(
        title: 'Income stability',
        detail: application.monthlyIncome >= 45000
            ? 'Your verified monthly income supports a larger repayment envelope.'
            : 'Income covers the request, but leaves less room for an aggressive offer.',
        impact: application.monthlyIncome >= 45000
            ? RiskImpact.positive
            : RiskImpact.caution,
      ),
      RiskFactor(
        title: 'Debt load',
        detail: dti <= 0.2
            ? 'Existing obligations stay well below the healthy debt-to-income threshold.'
            : dti <= 0.35
                ? 'Current monthly debt is manageable, but it tightens the available offer.'
                : 'Current monthly debt is high for this request and increases repayment risk.',
        impact: dti <= 0.2
            ? RiskImpact.positive
            : dti <= 0.35
                ? RiskImpact.caution
                : RiskImpact.negative,
      ),
      RiskFactor(
        title: 'Requested monthly burden',
        detail: paymentLoad <= 0.18
            ? 'The projected installment fits comfortably inside your income profile.'
            : paymentLoad <= 0.28
                ? 'The projected installment is acceptable, but not best-in-class.'
                : 'The projected installment would take too much of your monthly cash flow.',
        impact: paymentLoad <= 0.18
            ? RiskImpact.positive
            : paymentLoad <= 0.28
                ? RiskImpact.caution
                : RiskImpact.negative,
      ),
    ];

    if (score >= 740 && dti <= 0.28 && paymentLoad <= 0.24) {
      return CreditDecision(
        status: CreditDecisionStatus.approved,
        score: score,
        apr: 2.08,
        summary: 'Approved for the best available rate',
        insight:
            'Approved quickly because your income profile is strong, existing debt is light, and the projected installment stays inside a healthy range.',
        riskFactors: riskFactors,
        offers: const [
          OfferOption(
              name: 'Personal loan',
              rateLabel: 'from 2.08% APR',
              tag: 'Best rate'),
          OfferOption(
              name: 'Auto loan',
              rateLabel: 'from 2.21% APR',
              tag: 'Pre-qualified'),
          OfferOption(
              name: 'Credit limit increase',
              rateLabel: 'up to TL 35.000',
              tag: 'Instant'),
        ],
        recommendedAmount: application.amount,
        recommendedMonths: application.months,
        decisionTimeSeconds: 4,
      );
    }

    if (score >= 650 && dti <= 0.4 && paymentLoad <= 0.33) {
      final adjustedAmount = application.amount * 0.8;
      final adjustedMonths = application.months < 24 ? 24 : application.months;
      return CreditDecision(
        status: CreditDecisionStatus.review,
        score: score,
        apr: 2.56,
        summary: 'Conditionally eligible with safer terms',
        insight:
            'You are close to approval, but the current request stretches your monthly cash flow. Lowering the amount or extending the term would improve the offer quality.',
        riskFactors: riskFactors,
        offers: [
          OfferOption(
            name: 'Adjusted personal loan',
            rateLabel: 'TL ${adjustedAmount.round()} · $adjustedMonths mo',
            tag: 'Safer fit',
          ),
          const OfferOption(
              name: 'Auto loan', rateLabel: 'from 2.34% APR', tag: 'Review'),
          const OfferOption(
              name: 'Secured credit line',
              rateLabel: 'from 1.98% APR',
              tag: 'Alternative'),
        ],
        recommendedAmount: adjustedAmount,
        recommendedMonths: adjustedMonths,
        decisionTimeSeconds: 6,
      );
    }

    return CreditDecision(
      status: CreditDecisionStatus.declined,
      score: score,
      apr: 3.04,
      summary: 'Request declined for now',
      insight:
          'The requested payment would place too much pressure on your monthly income given current debt obligations. Reducing the loan size or improving debt ratio would meaningfully improve approval odds.',
      riskFactors: riskFactors,
      offers: const [
        OfferOption(
            name: 'Starter cash reserve plan',
            rateLabel: 'Build 3 months buffer',
            tag: 'Recommended'),
        OfferOption(
            name: 'Debt consolidation review',
            rateLabel: 'Reduce monthly burden',
            tag: 'Coaching'),
        OfferOption(
            name: 'Small-ticket credit line',
            rateLabel: 'up to TL 20.000',
            tag: 'Alternative'),
      ],
      recommendedAmount: application.amount * 0.55,
      recommendedMonths: application.months < 24 ? 24 : application.months,
      decisionTimeSeconds: 7,
    );
  }

  double _estimatedMonthlyPayment(LoanApplication application) {
    final interestMultiplier = 1.16 + (application.months / 100);
    return (application.amount * interestMultiplier) / application.months;
  }
}
