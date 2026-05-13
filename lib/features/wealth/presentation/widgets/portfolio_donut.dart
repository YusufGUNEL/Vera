import 'dart:math' as math;

import 'package:flutter/material.dart';

class DonutSlice {
  const DonutSlice({required this.value, required this.color, required this.label, required this.amount});
  final double value;
  final Color color;
  final String label;
  final double amount;
}

class PortfolioDonut extends StatelessWidget {
  const PortfolioDonut({
    required this.slices,
    required this.trackColor,
    this.size = 120,
    this.stroke = 18,
    this.center,
    super.key,
  });

  final List<DonutSlice> slices;
  final Color trackColor;
  final double size;
  final double stroke;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _DonutPainter(
              slices: slices,
              trackColor: trackColor,
              stroke: stroke,
            ),
          ),
          if (center != null) center!,
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.slices,
    required this.trackColor,
    required this.stroke,
  });

  final List<DonutSlice> slices;
  final Color trackColor;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(rect.center, rect.width / 2, track);

    final total = slices.fold<double>(0, (s, x) => s + x.value);
    if (total <= 0) return;

    const gap = 0.04; // small visual gap between slices (radians)
    var start = -math.pi / 2;
    for (final s in slices) {
      final sweep = (s.value / total) * (2 * math.pi) - gap;
      if (sweep <= 0) continue;
      final paint = Paint()
        ..color = s.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.slices != slices || old.trackColor != trackColor || old.stroke != stroke;
}
