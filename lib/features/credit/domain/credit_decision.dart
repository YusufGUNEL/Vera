import 'offer_option.dart';
import 'risk_factor.dart';

enum CreditDecisionStatus { approved, review, declined }

class CreditDecision {
  const CreditDecision({
    required this.status,
    required this.score,
    required this.apr,
    required this.summary,
    required this.insight,
    required this.riskFactors,
    required this.offers,
    required this.recommendedAmount,
    required this.recommendedMonths,
    required this.decisionTimeSeconds,
  });

  final CreditDecisionStatus status;
  final int score;
  final double apr;
  final String summary;
  final String insight;
  final List<RiskFactor> riskFactors;
  final List<OfferOption> offers;
  final double recommendedAmount;
  final int recommendedMonths;
  final int decisionTimeSeconds;

  /// Internal band code; UI maps it to a localized label via AppStrings.
  String get bandCode {
    if (score >= 760) return 'excellent';
    if (score >= 690) return 'strong';
    if (score >= 620) return 'fair';
    return 'watch';
  }

  String get bandLabel {
    switch (bandCode) {
      case 'excellent':
        return 'EXCELLENT';
      case 'strong':
        return 'STRONG';
      case 'fair':
        return 'FAIR';
      default:
        return 'WATCH';
    }
  }
}
