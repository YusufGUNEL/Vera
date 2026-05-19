import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../shared/widgets/pill.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/vera_card.dart';
import '../../profile_settings/presentation/profile_settings_sheet.dart';
import '../data/security_check.dart';
import '../state/security_controller.dart';

/// Advisory spending-insights hub — Vera does not block banks or cards.
class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(securityControllerProvider);
    final openCount = state.openInsightCount;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () =>
            ref.read(securityControllerProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 140),
          children: [
            _Header(
              lastUpdatedLabel: state.lastUpdatedTime == null
                  ? l10n.firstScanPending
                  : l10n.lastScanAt(state.lastUpdatedTime!),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _ScopeBanner(text: l10n.securityVeraSideBanner),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: _RadarSummaryCard(
                openCount: openCount,
                reviewedCount: state.reviewedCount,
                patternsMonitored: state.patternsMonitored,
              ),
            ),
            SectionTitle(
              title: l10n.securityInsightsSection,
              actionLabel:
                  state.refreshing ? l10n.securityScanning : l10n.refresh,
              onAction: () =>
                  ref.read(securityControllerProvider.notifier).refresh(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: state.checks.isEmpty
                  ? _EmptyInsightsCard()
                  : VeraCard(
                      child: Column(
                        children: [
                          for (var i = 0; i < state.checks.length; i++)
                            _InsightTile(
                              check: state.checks[i],
                              isFirst: i == 0,
                              expanded: state.expandedIds
                                  .contains(state.checks[i].id),
                              decision: state.decisions[state.checks[i].id] ??
                                  ReviewDecision.pending,
                              onToggleExpand: () => ref
                                  .read(securityControllerProvider.notifier)
                                  .toggleExpanded(state.checks[i].id),
                              onKeepWatching: () => ref
                                  .read(securityControllerProvider.notifier)
                                  .setDecision(
                                    state.checks[i].id,
                                    ReviewDecision.keptBlocked,
                                  ),
                              onMarkNormal: () => ref
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
            SectionTitle(title: l10n.securityTipsSection),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                children: [
                  _ProtectionTip(
                    icon: Icons.account_balance_outlined,
                    title: l10n.securityTipBankTitle,
                    body: l10n.securityTipBankBody,
                  ),
                  const SizedBox(height: 10),
                  _ProtectionTip(
                    icon: Icons.fingerprint,
                    title: l10n.securityTipPinTitle,
                    body: l10n.securityTipPinBody,
                    onTap: () => _openProfile(context),
                    actionLabel: l10n.profileAndSettings,
                  ),
                  const SizedBox(height: 10),
                  _ProtectionTip(
                    icon: Icons.upload_file_outlined,
                    title: l10n.securityTipAlertsTitle,
                    body: l10n.securityTipAlertsBody,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openProfile(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => const ProfileSettingsSheet(),
    );
  }
}

class _ScopeBanner extends StatelessWidget {
  const _ScopeBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.umaSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.uma.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: t.uma, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: t.ink2,
                fontSize: 12.5,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarSummaryCard extends StatelessWidget {
  const _RadarSummaryCard({
    required this.openCount,
    required this.reviewedCount,
    required this.patternsMonitored,
  });

  final int openCount;
  final int reviewedCount;
  final int patternsMonitored;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final hasOpen = openCount > 0;

    return Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: (hasOpen ? t.gold : t.green).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(
                  hasOpen ? Icons.radar : Icons.verified_user_outlined,
                  color: hasOpen ? t.gold : t.green,
                  size: 28,
                ),
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
                        fontSize: 11,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasOpen
                          ? l10n.securityActiveBody(openCount)
                          : l10n.statusAllClear,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: hasOpen ? t.ink : t.green,
                        letterSpacing: -0.3,
                        height: 1.25,
                      ),
                    ),
                    if (!hasOpen) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.securityClearBody,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: t.muted,
                          height: 1.35,
                        ),
                      ),
                    ],
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
                  value: '$openCount',
                  sub: l10n.securityStatBlockedSub,
                  color: hasOpen ? t.gold : t.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCell(
                  label: l10n.securityStatReviewedLabel,
                  value: '$reviewedCount',
                  sub: l10n.securityStatReviewedSub,
                  color: t.ink,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCell(
                  label: l10n.securityStatDevicesLabel,
                  value: '$patternsMonitored',
                  sub: l10n.securityStatDevicesSub,
                  color: t.uma,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyInsightsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    return VeraCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: t.umaSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.insights_outlined, color: t.uma, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.securityEmptyTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: t.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.securityEmptyBody,
                  style: TextStyle(
                    fontSize: 12,
                    color: t.muted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
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
          const SizedBox(height: 4),
          Text(
            l10n.securitySubtitle,
            style: TextStyle(fontSize: 13, color: t.muted, height: 1.35),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: t.bgSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 9, color: t.muted, letterSpacing: 0.3),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, color: t.muted),
          ),
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({
    required this.check,
    required this.isFirst,
    required this.expanded,
    required this.decision,
    required this.onToggleExpand,
    required this.onKeepWatching,
    required this.onMarkNormal,
  });

  final SecurityCheck check;
  final bool isFirst;
  final bool expanded;
  final ReviewDecision decision;
  final VoidCallback onToggleExpand;
  final VoidCallback onKeepWatching;
  final VoidCallback onMarkNormal;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final spec = _insightVisual(check, decision, t, l10n);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: spec.background,
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
                  color: spec.softColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(spec.icon, color: spec.color, size: 17),
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
                            fontWeight: FontWeight.w600,
                            color: t.ink,
                          ),
                        ),
                        if (spec.pillLabel != null)
                          Pill(
                            label: spec.pillLabel!,
                            color: spec.color,
                            fontSize: 9,
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${check.location} · ${check.when}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: t.bgSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: t.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: onToggleExpand,
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 16, color: t.uma),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.securityViewReport,
                            style: TextStyle(
                              fontSize: 12,
                              color: t.uma,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Icon(
                          expanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: t.muted,
                          size: 20,
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
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetaChip(
                          icon: Icons.dataset_outlined,
                          label: l10n.liveAnomalyDetected,
                          color: t.uma,
                        ),
                        _MetaChip(
                          icon: Icons.flag_outlined,
                          label: check.blocked
                              ? l10n.highRiskConfidence
                              : l10n.reviewedSignal,
                          color: check.blocked ? t.gold : t.muted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (decision == ReviewDecision.pending)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FilledButton(
                            onPressed: onMarkNormal,
                            style: FilledButton.styleFrom(
                              backgroundColor: t.brand,
                              foregroundColor: t.brandFG,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              l10n.thisWasMe,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: onKeepWatching,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: t.ink2,
                              side: BorderSide(color: t.line),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              l10n.keepBlocked,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: spec.softColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          decision == ReviewDecision.keptBlocked
                              ? l10n.securityDecisionKept
                              : l10n.securityDecisionApproved,
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: t.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: t.ink2),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProtectionTip extends StatelessWidget {
  const _ProtectionTip({
    required this.icon,
    required this.title,
    required this.body,
    this.onTap,
    this.actionLabel,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback? onTap;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: t.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: t.line),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: t.brand.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: t.brand, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: t.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: TextStyle(
                        fontSize: 12,
                        color: t.muted,
                        height: 1.4,
                      ),
                    ),
                    if (onTap != null && actionLabel != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        actionLabel!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: t.uma,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right, color: t.muted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightVisual {
  const _InsightVisual({
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

_InsightVisual _insightVisual(
  SecurityCheck check,
  ReviewDecision decision,
  AppTokens t,
  AppStrings l10n,
) {
  if (decision == ReviewDecision.approvedByUser) {
    return _InsightVisual(
      icon: Icons.check_circle_outline,
      color: t.green,
      softColor: t.green.withValues(alpha: 0.1),
      background: t.green.withValues(alpha: 0.03),
      pillLabel: l10n.securityPillApproved,
    );
  }

  if (decision == ReviewDecision.keptBlocked) {
    return _InsightVisual(
      icon: Icons.visibility_outlined,
      color: t.uma,
      softColor: t.umaSoft,
      background: t.umaSoft.withValues(alpha: 0.35),
      pillLabel: l10n.securityPillKept,
    );
  }

  if (check.blocked) {
    return _InsightVisual(
      icon: Icons.priority_high_rounded,
      color: t.gold,
      softColor: t.gold.withValues(alpha: 0.14),
      background: t.gold.withValues(alpha: 0.05),
      pillLabel: l10n.securityPillBlocked,
    );
  }

  return _InsightVisual(
    icon: Icons.insights_outlined,
    color: t.uma,
    softColor: t.umaSoft,
    background: Colors.transparent,
  );
}
