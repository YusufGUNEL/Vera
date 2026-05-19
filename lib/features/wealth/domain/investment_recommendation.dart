class InvestmentRecommendation {
  final String title;
  final String symbol;
  final String type; // 'equity' | 'commodity' | 'crypto'
  final String trend;
  final String returnRate;
  final String explanation;
  final String reason;

  const InvestmentRecommendation({
    required this.title,
    required this.symbol,
    required this.type,
    required this.trend,
    required this.returnRate,
    required this.explanation,
    required this.reason,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'symbol': symbol,
      'type': type,
      'trend': trend,
      'returnRate': returnRate,
      'explanation': explanation,
      'reason': reason,
    };
  }

  factory InvestmentRecommendation.fromMap(Map<String, dynamic> map) {
    return InvestmentRecommendation(
      title: map['title'] ?? '',
      symbol: map['symbol'] ?? '',
      type: map['type'] ?? '',
      trend: map['trend'] ?? '',
      returnRate: map['returnRate'] ?? '',
      explanation: map['explanation'] ?? '',
      reason: map['reason'] ?? '',
    );
  }
}
