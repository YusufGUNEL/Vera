import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../shared/widgets/pill.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/vera_card.dart';
import '../data/security_check.dart';
import '../state/security_controller.dart';

class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l10n = context.l10n;
    final state = ref.watch(securityControllerProvider);

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () =>
            ref.read(securityControllerProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 130),
          children: [
            _Header(
              lastUpdatedLabel: state.lastUpdatedTime == null
                  ? l10n.firstScanPending
                  : l10n.lastScanAt(state.lastUpdatedTime!),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: t.umaSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: t.uma.withValues(alpha: 0.18)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: t.uma, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.securityVeraSideBanner,
                        style: TextStyle(
                          color: t.ink2,
                          fontSize: 11.5,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: const Alignment(-0.7, -1),
                    end: const Alignment(0.7, 1),
                    colors: t.isDark
                        ? [t.card, const Color(0xFF232631)]
                        : [const Color(0xFFFFFFFF), t.bgSoft],
                  ),
                  borderRadius: BorderRadius.circular(t.vibe.radius),
                  border: Border.all(color: t.line),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: t.green.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Icon(Icons.shield, color: t.green, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.securityAccountSection,
                                style: TextStyle(
                                  color: t.muted,
                                  fontSize: 12,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              Text(
                                state.blockedCount == 0
                                    ? l10n.statusAllClear
                                    : l10n.statusMonitoring,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      state.blockedCount == 0 ? t.green : t.ink,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                state.blockedCount == 0
                                    ? l10n.securityClearBody
                                    : l10n.securityActiveBody(state.blockedCount),
                                style: TextStyle(fontSize: 12, color: t.muted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCell(
                            label: l10n.securityStatBlockedLabel,
                            value: '${state.blockedCount}',
                            sub: l10n.securityStatBlockedSub,
                            color: state.blockedCount == 0 ? t.green : t.red,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatCell(
                            label: l10n.securityStatReviewedLabel,
                            value: '${state.reviewedCount}',
                            sub: l10n.securityStatReviewedSub,
                            color: t.ink,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatCell(
                            label: l10n.securityStatDevicesLabel,
                            value: '${state.trustedDevices}',
                            sub: l10n.securityStatDevicesSub,
                            color: t.ink,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SectionTitle(
              title: l10n.securityRecentActivity,
              actionLabel:
                  state.refreshing ? l10n.securityScanning : l10n.refresh,
              onAction: () =>
                  ref.read(securityControllerProvider.notifier).refresh(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: VeraCard(
                child: Column(
                  children: [
                    for (var i = 0; i < state.checks.length; i++)
                      _CheckTile(
                        check: state.checks[i],
                        isFirst: i == 0,
                        expanded:
                            state.expandedIds.contains(state.checks[i].id),
                        decision: state.decisions[state.checks[i].id] ??
                            ReviewDecision.pending,
                        onToggleExpand: () => ref
                            .read(securityControllerProvider.notifier)
                            .toggleExpanded(state.checks[i].id),
                        onKeepBlocked: () => ref
                            .read(securityControllerProvider.notifier)
                            .setDecision(
                              state.checks[i].id,
                              ReviewDecision.keptBlocked,
                            ),
                        onApprove: () => ref
                            .read(securityControllerProvider.notifier)
                            .setDecision(
                              state.checks[i].id,
                              ReviewDecision.approvedByUser,
                            ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.lastUpdatedLabel});

  final String lastUpdatedLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.securityTitle,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: t.ink,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.securitySubtitle,
            style: TextStyle(fontSize: 13, color: t.muted),
          ),
          const SizedBox(height: 6),
          Text(
            lastUpdatedLabel,
            style: TextStyle(fontSize: 11.5, color: t.muted),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });

  final String label;
  final String value;
  final String sub;
  final Color color;

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
            style: TextStyle(fontSize: 10, color: t.muted, letterSpacing: 0.4),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(sub, style: TextStyle(fontSize: 10, color: t.muted)),
        ],
      ),
    );
  }
}

class _CheckTile extends StatelessWidget {
  const _CheckTile({
    required this.check,
    required this.isFirst,
    required this.expanded,
    required this.decision,
    required this.onToggleExpand,
    required this.onKeepBlocked,
    required this.onApprove,
  });

  final SecurityCheck check;
  final bool isFirst;
  final bool expanded;
  final ReviewDecision decision;
  final VoidCallback onToggleExpand;
  final VoidCallback onKeepBlocked;
  final VoidCallback onApprove;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final state = _tileStateFor(check, decision, t, l10n);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: state.background,
            border: Border(
              top: isFirst ? BorderSide.none : BorderSide(color: t.line),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: state.softColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(state.icon, color: state.color, size: 17),
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
                        Text(
                          check.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: t.ink,
                          ),
                        ),
                        if (state.pillLabel != null)
                          Pill(
                            label: state.pillLabel!,
                            color: state.color,
                            fontSize: 9,
                          ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${check.location} · ${check.when}',
                      style: TextStyle(fontSize: 12, color: t.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (check.reason != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: t.umaSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: t.uma.withValues(alpha: 0.13)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: onToggleExpand,
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: t.uma,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.auto_awesome,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            context.l10n.securityViewReport,
                            style: TextStyle(
                              fontSize: 12,
                              color: t.uma,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        Icon(
                          expanded
                              ? Icons.keyboard_arrow_down
                              : Icons.chevron_right,
                          color: t.uma,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                  if (expanded) ...[
                    const SizedBox(height: 10),
                    Text(
                      check.reason!,
                      style: TextStyle(
                        color: t.ink2,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: t.uma.withValues(alpha: 0.13)),
                        ),
                      ),
                      child: Row(
                        children: [
                          _InfoChip(
                            icon: Icons.location_on_outlined,
                            text: context.l10n.liveAnomalyDetected,
                            color: t.uma,
                          ),
                          const SizedBox(width: 12),
                          _InfoChip(
                            icon: Icons.bolt,
                            text: check.blocked
                                ? context.l10n.highRiskConfidence
                                : context.l10n.reviewedSignal,
                            color: t.uma,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (decision == ReviewDecision.pending)
                      Row(
                        children: [
                          Expanded(
                            child: Material(
                              color: t.brand,
                              borderRadius: BorderRadius.circular(999),
                              child: InkWell(
                                onTap: onKeepBlocked,
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  height: 34,
                                  alignment: Alignment.center,
                                  child: Text(
                                    context.l10n.keepBlocked,
                                    style: TextStyle(
                                      color: t.brandFG,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(999),
                              child: InkWell(
                                onTap: onApprove,
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  height: 34,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: t.line),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    context.l10n.thisWasMe,
                                    style: TextStyle(
                                      color: t.ink2,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: state.softColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          decision == ReviewDecision.keptBlocked
                              ? context.l10n.securityDecisionKept
                              : context.l10n.securityDecisionApproved,
                          style: TextStyle(
                            fontSize: 12,
                            color: t.ink2,
                            height: 1.4,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(
      {required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 5),
        Text(text, style: TextStyle(fontSize: 11, color: t.ink2)),
      ],
    );
  }
}

class _TileState {
  const _TileState({
    required this.icon,
    required this.color,
    required this.softColor,
    required this.background,
    this.pillLabel,
  });

  final IconData icon;
  final Color color;
  final Color softColor;
  final Color background;
  final String? pillLabel;
}

_TileState _tileStateFor(
  SecurityCheck check,
  ReviewDecision decision,
  AppTokens t,
  AppStrings l10n,
) {
  if (decision == ReviewDecision.approvedByUser) {
    return _TileState(
      icon: Icons.verified_user_outlined,
      color: t.green,
      softColor: t.green.withValues(alpha: 0.10),
      background: t.green.withValues(alpha: 0.03),
      pillLabel: l10n.securityPillApproved,
    );
  }

  if (check.blocked) {
    return _TileState(
      icon: Icons.warning_amber_rounded,
      color: t.red,
      softColor: t.red.withValues(alpha: 0.10),
      background: t.red.withValues(alpha: 0.03),
      pillLabel: decision == ReviewDecision.keptBlocked
          ? l10n.securityPillKept
          : l10n.securityPillBlocked,
    );
  }

  return _TileState(
    icon: Icons.check,
    color: t.green,
    softColor: t.green.withValues(alpha: 0.10),
    background: Colors.transparent,
  );
}
