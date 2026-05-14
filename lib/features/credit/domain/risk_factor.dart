enum RiskImpact { positive, caution, negative }

class RiskFactor {
  const RiskFactor({
    required this.title,
    required this.detail,
    required this.impact,
  });

  final String title;
  final String detail;
  final RiskImpact impact;
}
