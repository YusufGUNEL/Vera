import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/font_weight_helper.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/pill.dart';
import '../../data/net_worth_history_store.dart';

class NetWorthCard extends StatelessWidget {
  const NetWorthCard({
    required this.balance,
    required this.monthDelta,
    required this.lastUpdatedLabel,
    required this.refreshing,
    this.history = const [],
    super.key,
  });

  final double balance;
  final double monthDelta;
  final String lastUpdatedLabel;
  final bool refreshing;
  final List<NetWorthPoint> history;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(t.vibe.radius + 4),
          gradient: LinearGradient(
            begin: const Alignment(-0.7, -1),
            end: const Alignment(0.7, 1),
            colors: [t.brandSoft, t.brand],
            stops: const [0, 0.7],
          ),
          boxShadow: [
            BoxShadow(
              color: t.brand.withValues(alpha: 0.22),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: t.uma.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 30,
              bottom: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.totalNetWorth,
                      style: TextStyle(
                        color: t.brandFG.withValues(alpha: 0.7),
                        fontSize: 11,
                        letterSpacing: 0.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Pill(
                      label: refreshing ? l10n.syncing : l10n.liveFeed,
                      color: t.brandFG,
                      background: Colors.white.withValues(alpha: 0.10),
                      fontSize: 10,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  fmtTL(balance),
                  style: TextStyle(
                    color: t.brandFG,
                    fontSize: t.vibe.heroSize,
                    fontWeight: fwFromInt(t.vibe.headWeight),
                    letterSpacing: t.vibe.heroLetterSpacing,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                if (monthDelta != 0)
                  Row(
                    children: [
                      Icon(
                        monthDelta >= 0
                            ? Icons.trending_up
                            : Icons.trending_down,
                        color: monthDelta >= 0 ? t.accentPop : t.red,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        fmtSignedTL(monthDelta),
                        style: TextStyle(
                          color: monthDelta >= 0 ? t.accentPop : t.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.thisMonth,
                        style: TextStyle(
                          color: t.brandFG.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                Text(
                  lastUpdatedLabel,
                  style: TextStyle(
                    color: t.brandFG.withValues(alpha: 0.76),
                    fontSize: 11.5,
                  ),
                ),
                if (history.length >= 2) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 36,
                    child: _SparklinePainter.fromHistory(
                      history: history,
                      stroke: t.brandFG,
                      fill: t.brandFG.withValues(alpha: 0.18),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SparklinePainter extends StatelessWidget {
  const _SparklinePainter({
    required this.values,
    required this.stroke,
    required this.fill,
  });

  factory _SparklinePainter.fromHistory({
    required List<NetWorthPoint> history,
    required Color stroke,
    required Color fill,
  }) {
    return _SparklinePainter(
      values: history.map((p) => p.amount).toList(),
      stroke: stroke,
      fill: fill,
    );
  }

  final List<double> values;
  final Color stroke;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparklineCanvas(values: values, stroke: stroke, fill: fill),
      size: const Size.fromHeight(36),
    );
  }
}

class _SparklineCanvas extends CustomPainter {
  _SparklineCanvas({
    required this.values,
    required this.stroke,
    required this.fill,
  });

  final List<double> values;
  final Color stroke;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final minV = values.reduce((a, b) => a < b ? a : b);
    final range = (maxV - minV).abs();
    final span = range < 1 ? 1 : range;

    final stepX = size.width / (values.length - 1);
    final path = Path();
    final area = Path();
    for (var i = 0; i < values.length; i++) {
      final x = stepX * i;
      final norm = (values[i] - minV) / span;
      final y = size.height - (norm * size.height);
      if (i == 0) {
        path.moveTo(x, y);
        area.moveTo(x, size.height);
        area.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        area.lineTo(x, y);
      }
    }
    area.lineTo(size.width, size.height);
    area.close();

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = fill;
    canvas.drawPath(area, fillPaint);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklineCanvas old) {
    return old.values != values || old.stroke != stroke || old.fill != fill;
  }
}
