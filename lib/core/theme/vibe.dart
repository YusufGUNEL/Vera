enum VibeId { calm, standard, bold }

/// Vibe - tasarima ritim/karakter veren olculer.
/// Calm = yumusak, Standard = modern banking, Bold = sert/geometrik.
class Vibe {
  const Vibe({
    required this.id,
    required this.radius,
    required this.radiusSmall,
    required this.cardPadding,
    required this.headWeight,
    required this.heroSize,
    required this.heroLetterSpacing,
    required this.sectionWeight,
  });

  final VibeId id;
  final double radius;
  final double radiusSmall;
  final double cardPadding;
  final int headWeight;
  final double heroSize;
  final double heroLetterSpacing;
  final int sectionWeight;

  static const calm = Vibe(
    id: VibeId.calm,
    radius: 24,
    radiusSmall: 16,
    cardPadding: 22,
    headWeight: 500,
    heroSize: 36,
    heroLetterSpacing: -1.0,
    sectionWeight: 500,
  );

  static const standard = Vibe(
    id: VibeId.standard,
    radius: 18,
    radiusSmall: 12,
    cardPadding: 20,
    headWeight: 600,
    heroSize: 38,
    heroLetterSpacing: -1.2,
    sectionWeight: 600,
  );

  static const bold = Vibe(
    id: VibeId.bold,
    radius: 10,
    radiusSmall: 8,
    cardPadding: 18,
    headWeight: 700,
    heroSize: 46,
    heroLetterSpacing: -1.6,
    sectionWeight: 700,
  );

  static const all = [calm, standard, bold];

  static Vibe byId(VibeId id) => all.firstWhere((v) => v.id == id);
}
