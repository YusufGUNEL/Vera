class PortfolioAllocation {
  const PortfolioAllocation({
    required this.label,
    required this.amount,
    required this.weight,
    required this.paletteKey,
  });

  final String label;
  final double amount;
  final double weight;
  final String paletteKey;

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'amount': amount,
      'weight': weight,
      'paletteKey': paletteKey,
    };
  }

  factory PortfolioAllocation.fromMap(Map<String, dynamic> map) {
    return PortfolioAllocation(
      label: map['label'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      weight: (map['weight'] as num?)?.toDouble() ?? 0,
      paletteKey: map['paletteKey'] as String? ?? 'brand',
    );
  }
}
