import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/font_weight_helper.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/pill.dart';

class NetWorthCard extends StatelessWidget {
  const NetWorthCard({
    required this.balance,
    required this.monthDelta,
    required this.lastUpdatedLabel,
    required this.refreshing,
    this.onSend,
    this.onRequest,
    this.onTopUp,
    this.onPay,
    super.key,
  });

  final double balance;
  final double monthDelta;
  final String lastUpdatedLabel;
  final bool refreshing;
  final VoidCallback? onSend;
  final VoidCallback? onRequest;
  final VoidCallback? onTopUp;
  final VoidCallback? onPay;

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
                        '${monthDelta >= 0 ? '+' : '-'}${fmtTL(monthDelta.abs())}',
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
                const SizedBox(height: 18),
                Row(
                  children: [
                    _QuickAction(
                      icon: Icons.send_outlined,
                      label: l10n.actionSend,
                      onTap: onSend,
                    ),
                    const SizedBox(width: 8),
                    _QuickAction(
                      icon: Icons.south_west,
                      label: l10n.actionRequest,
                      onTap: onRequest,
                    ),
                    const SizedBox(width: 8),
                    _QuickAction(
                      icon: Icons.add,
                      label: l10n.actionTopUp,
                      onTap: onTopUp,
                    ),
                    const SizedBox(width: 8),
                    _QuickAction(
                      icon: Icons.north_east,
                      label: l10n.actionPay,
                      onTap: onPay,
                    ),
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
  const _QuickAction({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Expanded(
      child: Material(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(t.vibe.radiusSmall + 2),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(t.vibe.radiusSmall + 2),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child: Column(
              children: [
                Icon(icon, color: t.brandFG, size: 18),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: t.brandFG.withValues(alpha: 0.9),
                    fontSize: 11,
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
