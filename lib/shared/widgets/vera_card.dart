import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

/// Tasarimdaki Card primitivi. Sade, theme-aware, vibe.radius'a uyar.
class VeraCard extends StatelessWidget {
  const VeraCard({
    required this.child,
    this.padding,
    this.onTap,
    this.background,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background ?? t.card,
        borderRadius: BorderRadius.circular(t.vibe.radius),
        border: Border.all(color: t.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(t.isDark ? 0.3 : 0.02),
            offset: const Offset(0, 1),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(t.vibe.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(t.vibe.radius),
        child: card,
      ),
    );
  }
}
