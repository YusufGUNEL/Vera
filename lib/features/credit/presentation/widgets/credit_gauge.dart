import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';

class CreditGauge extends StatelessWidget {
  const CreditGauge({
    required this.score,
    this.min = 300,
    this.max = 850,
    this.size = 200,
    super.key,
  });

  final int score;
  final int min;
  final int max;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SizedBox(
      width: size,
      height: size / 2 + 30,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          CustomPaint(
            size: Size(size, size / 2 + 30),
            painter: _GaugePainter(
              score: score,
              min: min,
              max: max,
              greenColor: t.green,
              ink: t.ink,
            ),
          ),
          Positioned(
            top: 10,
            child: Column(
              children: [
                Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    color: t.ink,
                    letterSpacing: -1.2,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text('EXCELLENT',
                    style: TextStyle(
                      fontSize: 11,
                      color: t.muted,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.score,
    required this.min,
    required this.max,
    required this.greenColor,
    required this.ink,
  });

  final int score;
  final int min;
  final int max;
  final Color greenColor;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 12;
    const r = 78.0;
    const stroke = 14.0;

    final segments = [
      [math.pi, math.pi * 0.75, const Color(0xFFC03A2B)],
      [math.pi * 0.75 - 0.02, math.pi * 0.5, const Color(0xFFE08B2C)],
      [math.pi * 0.5 - 0.02, math.pi * 0.25, const Color(0xFFB89254)],
      [math.pi * 0.25 - 0.02, 0.0, greenColor],
    ];

    for (final s in segments) {
      final a0 = s[0] as double;
      final a1 = s[1] as double;
      final color = s[2] as Color;
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;
      // We're going clockwise from a0 toward a1, but a0 > a1 in our pi->0 walk.
      // Convert to canvas coordinates: angle 0 = right, pi = left.
      // Canvas drawArc uses startAngle measured from 3 o'clock, sweeping clockwise.
      // Our coordinate uses 0 at right (3 o'clock) and pi at left (9 o'clock).
      // To draw from a0 down to a1 (a0 > a1), we go counterclockwise visually.
      // In canvas, "above" the center is negative Y so startAngle = -a0 (degrees CCW positive).
      final startAngle = -a0;
      final sweep = a0 - a1;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        startAngle,
        sweep,
        false,
        paint,
      );
    }

    // Needle
    final t = (score - min) / (max - min);
    final ang = math.pi - t * math.pi; // pi -> 0
    final needlePaint = Paint()
      ..color = ink
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final nx = cx + (r - 10) * math.cos(ang);
    final ny = cy - (r - 10) * math.sin(ang);
    canvas.drawLine(Offset(cx, cy), Offset(nx, ny), needlePaint);
    canvas.drawCircle(Offset(cx, cy), 6, Paint()..color = ink);
    canvas.drawCircle(Offset(cx, cy), 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.score != score || old.greenColor != greenColor || old.ink != ink;
}
