import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/pill.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/toggle_switch.dart';
import '../../../shared/widgets/vera_card.dart';
import '../state/wealth_controller.dart';
import 'widgets/portfolio_donut.dart';

class WealthScreen extends ConsumerWidget {
  const WealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final autonomous = ref.watch(autonomousWealthProvider);

    final portfolio = [
      DonutSlice(value: 48, color: t.brand, label: 'Stocks', amount: 167400),
      DonutSlice(value: 27, color: t.gold, label: 'Gold', amount: 94200),
      DonutSlice(
          value: 16,
          color: t.isDark ? const Color(0xFF7B98AA) : const Color(0xFF5B7A8C),
          label: 'Cash',
          amount: 55800),
      DonutSlice(value: 9, color: t.uma, label: 'Crypto', amount: 31400),
    ];
    final total = portfolio.fold<double>(0, (s, p) => s + p.amount);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 130),
        children: [
          _Header(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: VeraCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('PORTFOLIO',
                                style: TextStyle(
                                    color: t.muted,
                                    fontSize: 12,
                                    letterSpacing: 0.4,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 2),
                            Text(
                              fmtTL(total),
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: t.ink,
                                letterSpacing: -0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text('+₺4.820 (1.4%) today',
                                style: TextStyle(color: t.green, fontSize: 13)),
                          ],
                        ),
                      ),
                      PortfolioDonut(
                        slices: portfolio,
                        trackColor: t.bgSoft,
                        center: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('YTD',
                                style: TextStyle(
                                    color: t.muted,
                                    fontSize: 10,
                                    letterSpacing: 0.4)),
                            Text('+18.2%',
                                style: TextStyle(
                                    color: t.green,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 4,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 10,
                    children: [
                      for (final p in portfolio)
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                  color: p.color,
                                  borderRadius: BorderRadius.circular(2)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(p.label,
                                    style: TextStyle(
                                        color: t.ink2, fontSize: 13))),
                            Text('${p.value.toInt()}%',
                                style: TextStyle(
                                    color: t.muted,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: VeraCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: autonomous ? t.uma : t.bgSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.auto_awesome,
                        color: autonomous ? Colors.white : t.muted, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text('Autonomous Wealth',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: t.ink,
                                      letterSpacing: -0.2)),
                            ),
                            ToggleSwitch(
                              on: autonomous,
                              onChanged: (v) => ref
                                  .read(autonomousWealthProvider.notifier)
                                  .state = v,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          autonomous
                              ? 'Uma is actively rebalancing your portfolio toward your goals.'
                              : 'Turn on to let Uma manage trades within your guardrails.',
                          style: TextStyle(
                              color: t.muted, fontSize: 12, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SectionTitle(title: 'Activity feed', actionLabel: 'Filter'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: VeraCard(
              child: Column(
                children: [
                  _ActivityRow(
                    icon: Icons.savings_outlined,
                    color: t.gold,
                    title: 'Moved ₺2.000 to Gold',
                    sub: 'Today, 11:42 · Tax-advantaged rebalance',
                    showUndo: true,
                    isFirst: true,
                  ),
                  _ActivityRow(
                    icon: Icons.trending_up,
                    color: t.brand,
                    title: 'Bought THYAO ₺5.000',
                    sub: 'Yesterday · DCA scheduled buy',
                    showUndo: false,
                    isFirst: false,
                  ),
                  _ActivityRow(
                    icon: Icons.account_balance_wallet_outlined,
                    color: t.blue,
                    title: 'Topped up Cash reserve',
                    sub: 'May 10 · From idle Akbank balance',
                    showUndo: false,
                    isFirst: false,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Wealth',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: t.ink,
                  letterSpacing: -0.8)),
          const SizedBox(height: 2),
          Text('Your money, working autonomously.',
              style: TextStyle(fontSize: 13, color: t.muted)),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.sub,
    required this.showUndo,
    required this.isFirst,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String sub;
  final bool showUndo;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border(
          top: isFirst ? BorderSide.none : BorderSide(color: t.line),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Pill(label: 'UMA', color: t.uma, fontSize: 9),
                    Text(title,
                        style: TextStyle(
                            fontSize: 14,
                            color: t.ink,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(sub,
                    style: TextStyle(color: t.muted, fontSize: 12, height: 1.4)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (showUndo) ...[
                      _SmallBtn(
                        label: 'Undo',
                        icon: Icons.undo,
                        background: t.bgSoft,
                        color: t.ink2,
                      ),
                      const SizedBox(width: 8),
                    ],
                    _SmallBtn(
                      label: 'View details',
                      background: Colors.transparent,
                      color: t.brand,
                      bordered: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallBtn extends StatelessWidget {
  const _SmallBtn({
    required this.label,
    required this.background,
    required this.color,
    this.icon,
    this.bordered = false,
  });

  final String label;
  final Color background;
  final Color color;
  final IconData? icon;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        border: bordered ? Border.all(color: t.line) : null,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
          ],
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
