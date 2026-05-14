import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/pill.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/toggle_switch.dart';
import '../../../shared/widgets/vera_card.dart';
import '../domain/autonomy_policy.dart';
import '../domain/rebalance_action.dart';
import '../state/wealth_controller.dart';
import 'widgets/portfolio_donut.dart';

class WealthScreen extends ConsumerWidget {
  const WealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final state = ref.watch(wealthControllerProvider);
    final portfolio = [
      for (final allocation in state.allocations)
        DonutSlice(
          value: allocation.weight,
          color: _allocationColor(allocation.paletteKey, t),
          label: allocation.label,
          amount: allocation.amount,
        ),
    ];

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 130),
        children: [
          const _Header(),
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
                            Text(
                              'PORTFOLIO',
                              style: TextStyle(
                                color: t.muted,
                                fontSize: 12,
                                letterSpacing: 0.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              fmtTL(state.total),
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: t.ink,
                                letterSpacing: -0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '+TL 4.820 (1.4%) today',
                              style: TextStyle(color: t.green, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      PortfolioDonut(
                        slices: portfolio,
                        trackColor: t.bgSoft,
                        center: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'YTD',
                              style: TextStyle(
                                color: t.muted,
                                fontSize: 10,
                                letterSpacing: 0.4,
                              ),
                            ),
                            Text(
                              '+18.2%',
                              style: TextStyle(
                                color: t.green,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                p.label,
                                style: TextStyle(color: t.ink2, fontSize: 13),
                              ),
                            ),
                            Text(
                              '${p.value.toInt()}%',
                              style: TextStyle(
                                color: t.muted,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: state.policy.enabled ? t.uma : t.bgSoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.auto_awesome,
                          color: state.policy.enabled ? Colors.white : t.muted,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Autonomous Wealth',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: t.ink,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                                ToggleSwitch(
                                  on: state.policy.enabled,
                                  onChanged: (v) => ref
                                      .read(wealthControllerProvider.notifier)
                                      .setAutonomous(v),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.policy.enabled
                                  ? 'Uma can rebalance within your guardrails and will ask for confirmation on larger moves.'
                                  : 'Automation is paused. Vera is still watching drift and will wait for your decision.',
                              style: TextStyle(
                                color: t.muted,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _PolicyChip(
                          label: 'PROFILE',
                          value: state.policy.riskProfile,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _PolicyChip(
                          label: 'MOVE LIMIT',
                          value: fmtTL(state.policy.monthlyMoveLimit),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _PolicyChip(
                          label: 'APPROVAL',
                          value: _approvalLabel(state.policy.approvalMode),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: t.umaSoft,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: t.uma.withValues(alpha: 0.16)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: t.uma,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            state.insight,
                            style: TextStyle(
                              color: t.ink2,
                              fontSize: 13,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SectionTitle(
              title: 'Activity feed', actionLabel: 'Explainability'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: VeraCard(
              child: Column(
                children: [
                  for (var i = 0; i < state.actions.length; i++)
                    _ActivityRow(
                      action: state.actions[i],
                      isFirst: i == 0,
                      onUndo:
                          state.actions[i].undoable && !state.actions[i].undone
                              ? () => ref
                                  .read(wealthControllerProvider.notifier)
                                  .undoAction(state.actions[i].id)
                              : null,
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
  const _Header();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wealth',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: t.ink,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Your money, working autonomously.',
            style: TextStyle(fontSize: 13, color: t.muted),
          ),
        ],
      ),
    );
  }
}

class _PolicyChip extends StatelessWidget {
  const _PolicyChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: t.bgSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: t.muted,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: t.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.action,
    required this.isFirst,
    required this.onUndo,
  });

  final RebalanceAction action;
  final bool isFirst;
  final VoidCallback? onUndo;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final visual = _visualFor(action.type);
    final color = _allocationColor(visual.colorKey, t);

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
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(visual.icon, color: color, size: 18),
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
                    Pill(
                      label: action.undone ? 'REVERSED' : 'UMA',
                      color: action.undone ? t.muted : t.uma,
                      fontSize: 9,
                    ),
                    Text(
                      action.title,
                      style: TextStyle(
                        fontSize: 14,
                        color: t.ink,
                        fontWeight: FontWeight.w500,
                        decoration:
                            action.undone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${action.when} · ${action.detail}',
                  style: TextStyle(color: t.muted, fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: t.bgSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    action.why,
                    style: TextStyle(
                      color: t.ink2,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (onUndo != null) ...[
                      _SmallBtn(
                        label: 'Undo',
                        icon: Icons.undo,
                        background: t.bgSoft,
                        color: t.ink2,
                        onTap: onUndo,
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
    this.onTap,
  });

  final String label;
  final Color background;
  final Color color;
  final IconData? icon;
  final bool bordered;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
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
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _approvalLabel(ApprovalMode mode) {
  return switch (mode) {
    ApprovalMode.autoWithinGuardrails => 'Auto',
    ApprovalMode.confirmLargeMoves => 'Hybrid',
  };
}

WealthActionVisual _visualFor(WealthActionType type) {
  return switch (type) {
    WealthActionType.rebalance => const WealthActionVisual(
        icon: Icons.savings_outlined,
        colorKey: 'gold',
      ),
    WealthActionType.buyEquity => const WealthActionVisual(
        icon: Icons.trending_up,
        colorKey: 'brand',
      ),
    WealthActionType.topUpCash => const WealthActionVisual(
        icon: Icons.account_balance_wallet_outlined,
        colorKey: 'blue',
      ),
    WealthActionType.protection => const WealthActionVisual(
        icon: Icons.shield_outlined,
        colorKey: 'green',
      ),
  };
}

Color _allocationColor(String key, AppTokens t) {
  return switch (key) {
    'brand' => t.brand,
    'gold' => t.gold,
    'uma' => t.uma,
    'green' => t.green,
    'blue' => t.blue,
    'blueSoft' => t.isDark ? const Color(0xFF7B98AA) : const Color(0xFF5B7A8C),
    _ => t.brand,
  };
}
