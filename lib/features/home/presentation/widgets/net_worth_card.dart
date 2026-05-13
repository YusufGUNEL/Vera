import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/font_weight_helper.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/pill.dart';

class NetWorthCard extends StatelessWidget {
  const NetWorthCard({required this.balance, super.key});

  final double balance;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
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
              color: t.brand.withOpacity(0.22),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: t.uma.withOpacity(0.12),
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
                  color: Colors.white.withOpacity(0.04),
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
                      'TOTAL NET WORTH',
                      style: TextStyle(
                        color: t.brandFG.withOpacity(0.7),
                        fontSize: 11,
                        letterSpacing: 0.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Pill(
                      label: '4 BANKS · LIVE',
                      color: t.brandFG,
                      background: Colors.white.withOpacity(0.10),
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
                Row(
                  children: [
                    Icon(Icons.trending_up, color: t.accentPop, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      '+₺12.480',
                      style: TextStyle(
                        color: t.accentPop,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'this month',
                      style: TextStyle(
                        color: t.brandFG.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: const [
                    _QuickAction(icon: Icons.send_outlined, label: 'Send'),
                    SizedBox(width: 8),
                    _QuickAction(
                        icon: Icons.south_west, label: 'Request'),
                    SizedBox(width: 8),
                    _QuickAction(icon: Icons.add, label: 'Top up'),
                    SizedBox(width: 8),
                    _QuickAction(
                        icon: Icons.north_east, label: 'Pay'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(t.vibe.radiusSmall + 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: t.brandFG, size: 18),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: t.brandFG.withOpacity(0.9),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
