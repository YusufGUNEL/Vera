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
}
