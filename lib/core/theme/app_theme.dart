import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_tokens.dart';

/// AppTokens'tan Material 3 ThemeData uretir.
/// Genel cizim sistemi widget'larda direkt `context.tokens` ile yapilir;
/// ThemeData sadece Material widget'larin (Switch, default text vs) base'i.
class AppTheme {
  AppTheme._();

  static ThemeData fromTokens(AppTokens t) {
    final base = t.isDark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: t.ink,
      displayColor: t.ink,
    );

    final colorScheme =
        (t.isDark ? const ColorScheme.dark() : const ColorScheme.light())
            .copyWith(
      primary: t.brand,
      onPrimary: t.brandFG,
      secondary: t.uma,
      onSecondary: t.brandFG,
      surface: t.card,
      onSurface: t.ink,
      error: t.red,
      onError: t.brandFG,
    );

    return base.copyWith(
      scaffoldBackgroundColor: t.bg,
      colorScheme: colorScheme,
      textTheme: textTheme,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: t.bg,
        foregroundColor: t.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
      iconTheme: IconThemeData(color: t.ink),
      dividerTheme: DividerThemeData(color: t.line, thickness: 1, space: 1),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: t.uma,
        selectionColor: t.uma.withValues(alpha: 0.30),
        selectionHandleColor: t.uma,
      ),
    );
  }
}
