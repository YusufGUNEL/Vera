import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/upcoming_bill.dart';

class UpcomingBillsStrip extends StatelessWidget {
  const UpcomingBillsStrip({
    required this.bills,
    this.onBillTap,
    this.onAddTap,
    super.key,
  });

  final List<UpcomingBill> bills;
  final ValueChanged<UpcomingBill>? onBillTap;
  final VoidCallback? onAddTap;

  @override
  Widget build(BuildContext context) {
    if (bills.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _EmptyAddCard(onTap: onAddTap),
      );
    }
    return SizedBox(
      height: 116,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: bills.length + (onAddTap == null ? 0 : 1),
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          if (i == bills.length) {
            return _AddCard(onTap: onAddTap!);
          }
          return _BillCard(
            bill: bills[i],
            onTap: onBillTap == null ? null : () => onBillTap!(bills[i]),
          );
        },
      ),
    );
  }
}

class _BillCard extends StatelessWidget {
  const _BillCard({required this.bill, this.onTap});

  final UpcomingBill bill;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final isUrgent = bill.daysUntilDue <= 3;
    return Material(
      color: t.card,
      borderRadius: BorderRadius.circular(t.vibe.radius - 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(t.vibe.radius - 2),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(t.vibe.radius - 2),
            border: Border.all(
              color: isUrgent ? t.red.withValues(alpha: 0.4) : t.line,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: bill.accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Icon(bill.icon, color: bill.accent, size: 16),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isUrgent
                          ? t.red.withValues(alpha: 0.10)
                          : t.bgSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      l10n.daysLeft(bill.daysUntilDue),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isUrgent ? t.red : t.muted,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                bill.name,
                style: TextStyle(fontSize: 12, color: t.muted),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                fmtTL(bill.amount),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: t.ink,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddCard extends StatelessWidget {
  const _AddCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(t.vibe.radius - 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(t.vibe.radius - 2),
        child: DottedBorderBox(
          color: t.brand,
          radius: t.vibe.radius - 2,
          child: Container(
            width: 160,
            padding: const EdgeInsets.all(14),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: t.brand, size: 22),
                const SizedBox(height: 6),
                Text(
                  'Fatura ekle',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: t.brand,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyAddCard extends StatelessWidget {
  const _EmptyAddCard({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(t.vibe.radius - 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(t.vibe.radius - 2),
        child: DottedBorderBox(
          color: t.muted,
          radius: t.vibe.radius - 2,
          child: Container(
            height: 96,
            padding: const EdgeInsets.all(14),
            alignment: Alignment.center,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: t.brand.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.event_outlined, color: t.brand, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Henüz takip edilen fatura yok',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: t.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ödeme tarihinden 1 gün önce Vera sana hatırlatır.',
                        style: TextStyle(fontSize: 11, color: t.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.add, color: t.brand, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Lightweight dashed border container — avoids an external dependency.
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({
    required this.child,
    required this.color,
    required this.radius,
    super.key,
  });

  final Widget child;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedBorderPainter(color: color, radius: radius),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  _DottedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.6, 0.6, size.width - 1.2, size.height - 1.2),
      Radius.circular(radius),
    );
    final dashPath = Path();
    final source = Path()..addRRect(rrect);
    const dash = 4.0;
    const gap = 3.0;
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dash;
        dashPath.addPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          Offset.zero,
        );
        distance = next + gap;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DottedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
