enum UmaIntentType {
  showSubscriptions,
  analyzeSpending,
  explainWealth,
  checkLoanEligibility,
  explainSecurityAlert,
  unknown,
}

class UmaIntent {
  const UmaIntent({
    required this.type,
    required this.originalText,
  });

  final UmaIntentType type;
  final String originalText;
}
