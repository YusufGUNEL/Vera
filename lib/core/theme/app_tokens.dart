import 'package:flutter/material.dart';

import 'palette.dart';
import 'vibe.dart';

enum MoodId { light, dark }

/// Tasarimin "V" objesinin Flutter karsiligi.
/// VeraApp her build'de palette + mood + vibe'a gore yeni bir AppTokens insa eder
/// ve InheritedWidget olarak alt agaca aktarir.
class AppTokens {
  const AppTokens({
    required this.palette,
    required this.vibe,
    required this.mood,
    // theme-derived
    required this.bg,
    required this.bgSoft,
    required this.card,
    required this.ink,
    required this.ink2,
    required this.muted,
    required this.line,
    required this.umaSoft,
    required this.pageShellBg,
    // semantic
    required this.green,
    required this.red,
    required this.blue,
    required this.gold,
    required this.accentPop,
  });

  final Palette palette;
  final Vibe vibe;
  final MoodId mood;

  // Surfaces & ink
  final Color bg;
  final Color bgSoft;
  final Color card;
  final Color ink;
  final Color ink2;
  final Color muted;
  final Color line;
  final Color umaSoft;
  final Color pageShellBg;

  // Semantic
  final Color green;
  final Color red;
  final Color blue;
  final Color gold;
  final Color accentPop;

  // Convenience
  Color get brand => palette.brand;
  Color get brandSoft => palette.brandSoft;
  Color get uma => palette.uma;
  Color get brandFG => const Color(0xFFF2EEE4);
  bool get isDark => mood == MoodId.dark;

  /// Uma'nin acik tonu - FAB/avatar gradient'lerinde kullanilir.
  /// Forest amber sabit yerine her palette icin otomatik turetilir.
  Color get umaLight {
    final hsl = HSLColor.fromColor(uma);
    return hsl
        .withLightness((hsl.lightness + 0.18).clamp(0.0, 0.85))
        .withSaturation((hsl.saturation * 0.92).clamp(0.0, 1.0))
        .toColor();
  }

  static AppTokens build({
    required PaletteId paletteId,
    required MoodId mood,
    required VibeId vibeId,
  }) {
    final p = Palette.byId(paletteId);
    final v = Vibe.byId(vibeId);
    final dark = mood == MoodId.dark;

    return AppTokens(
      palette: p,
      vibe: v,
      mood: mood,
      bg: dark ? const Color(0xFF0E1014) : p.bgLight,
      bgSoft: dark ? const Color(0xFF181B22) : p.bgSoftLight,
      card: dark ? const Color(0xFF1A1D24) : const Color(0xFFFFFFFF),
      ink: dark ? const Color(0xFFF2EEE4) : const Color(0xFF15171A),
      ink2: dark ? const Color(0xFFCCC6BA) : const Color(0xFF3A3D42),
      muted: dark ? const Color(0xFF7E796F) : const Color(0xFF8A857C),
      line: dark ? const Color(0xFF262A33) : p.lineLight,
      umaSoft: dark ? p.uma.withValues(alpha: 0.14) : p.umaSoft,
      pageShellBg: dark ? const Color(0xFF3A3933) : const Color(0xFFE8E4DC),
      green: dark ? const Color(0xFF5BCC85) : const Color(0xFF2F8B5C),
      red: dark ? const Color(0xFFE55A4B) : const Color(0xFFC03A2B),
      blue: dark ? const Color(0xFF6A95E0) : const Color(0xFF2D5FB0),
      gold: dark ? const Color(0xFFD6B270) : const Color(0xFFB89254),
      accentPop: const Color(0xFF9CCC65),
    );
  }
}

/// AppTokens'a context'ten erismeyi kolaylastiran InheritedWidget.
class TokensProvider extends InheritedWidget {
  const TokensProvider({
    required this.tokens,
    required super.child,
    super.key,
  });

  final AppTokens tokens;

  static AppTokens of(BuildContext context) {
    final p = context.dependOnInheritedWidgetOfExactType<TokensProvider>();
    assert(p != null, 'TokensProvider not found in widget tree');
    return p!.tokens;
  }

  @override
  bool updateShouldNotify(TokensProvider old) =>
      tokens.palette.id != old.tokens.palette.id ||
      tokens.mood != old.tokens.mood ||
      tokens.vibe.id != old.tokens.vibe.id;
}

/// `context.tokens` shortcut.
extension TokensX on BuildContext {
  AppTokens get tokens => TokensProvider.of(this);
}
