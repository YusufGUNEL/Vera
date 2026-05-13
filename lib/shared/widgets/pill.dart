import 'package:flutter/material.dart';

class Pill extends StatelessWidget {
  const Pill({
    required this.label,
    required this.color,
    this.background,
    this.fontSize = 11,
    super.key,
  });

  final String label;
  final Color color;
  final Color? background;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background ?? color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
