import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/pill.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/vera_card.dart';
import '../../receipt_scan/presentation/receipt_scan_sheet.dart';
import '../../statement_import/presentation/statement_import_sheet.dart';
import '../domain/subscription_alert.dart';
import '../domain/subscription_item.dart';
import '../domain/subscription_status.dart';
import '../state/subscriptions_controller.dart';

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l10n = context.l10n;
    final state = ref.watch(subscriptionsControllerProvider);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 140),
        children: [
          const _Header(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: VeraCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.subscriptionIntelligence,
                    style: TextStyle(
                      color: t.muted,
                      fontSize: 12,
                      letterSpacing: 0.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fmtTL(state.monthlyTotal),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: t.ink,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    l10n.subscriptionsAttentionCount(state.attentionCount),
                    style: TextStyle(color: t.red, fontSize: 13),
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
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: t.uma,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 16,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              children: [
                for (final alert in state.alerts) ...[
                  _AlertCard(alert: alert),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          SectionTitle(
            title: l10n.detectedPlans,
            actionLabel: '${state.visibleItems.length} ${l10n.itemsVisible}',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final filter in SubscriptionFilter.values)
                  _FilterChip(
                    label: _filterLabel(filter, l10n),
                    selected: state.filter == filter,
                    onTap: () => ref
                        .read(subscriptionsControllerProvider.notifier)
                        .setFilter(filter),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: state.visibleItems.isEmpty
                ? _EmptyPlansCard(showImportCTA: state.items.isEmpty)
                : VeraCard(
                    child: Column(
                      children: [
                        for (var i = 0; i < state.visibleItems.length; i++)
                          _SubscriptionTile(
                            item: state.visibleItems[i],
                            isFirst: i == 0,
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
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.plansTitle,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: t.ink,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.plansSubtitle,
            style: TextStyle(fontSize: 13, color: t.muted),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert});

  final SubscriptionAlert alert;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return VeraCard(
      padding: const EdgeInsets.all(16),
      background: t.bgSoft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: t.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.message,
                  style: TextStyle(
                    fontSize: 12,
                    color: t.muted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                alert.metricLabel,
                style: TextStyle(
                  color: t.muted,
                  fontSize: 10,
                  letterSpacing: 0.4,
                ),
              ),
              Text(
                alert.metricValue,
                style: TextStyle(
                  color: t.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: selected ? t.brand : t.card,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? t.brand : t.line),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? t.brandFG : t.ink2,
            ),
          ),
        ),
      ),
    );
  }
}

class _SubscriptionTile extends StatelessWidget {
  const _SubscriptionTile({
    required this.item,
    required this.isFirst,
  });

  final SubscriptionItem item;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final spec = _statusSpec(item.status, t);

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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: spec.softColor,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(item.icon, color: spec.color, size: 20),
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
                      item.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: t.ink,
                      ),
                    ),
                    Pill(
                      label: _statusLabel(item.status, l10n),
                      color: spec.color,
                      background: spec.softColor,
                      fontSize: 9,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.vendor} · ${_categoryLabel(item.category, l10n)}',
                  style: TextStyle(fontSize: 12, color: t.muted),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _MetaItem(
                          label: context.l10n.subsRenewalLabel,
                          value: item.renewalLabel),
                    ),
                    Expanded(
                      child: _MetaItem(
                          label: context.l10n.subsActivityLabel,
                          value: item.lastUsedLabel),
                    ),
                  ],
                ),
                if (item.priceDelta > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.notifPriceIncreaseBody(
                        fmtTL(item.priceDelta), fmtTL(item.monthlyPrice)),
                    style: TextStyle(
                      fontSize: 12,
                      color: t.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  item.recommendation,
                  style: TextStyle(
                    fontSize: 12,
                    color: t.ink2,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            fmtTL(item.monthlyPrice),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: t.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: t.muted,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: t.ink2,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StatusSpec {
  const _StatusSpec({
    required this.color,
    required this.softColor,
  });

  final Color color;
  final Color softColor;
}

_StatusSpec _statusSpec(SubscriptionStatus status, AppTokens t) {
  return switch (status) {
    SubscriptionStatus.healthy => _StatusSpec(
        color: t.green,
        softColor: t.green.withValues(alpha: 0.12),
      ),
    SubscriptionStatus.priceIncreased => _StatusSpec(
        color: t.red,
        softColor: t.red.withValues(alpha: 0.10),
      ),
    SubscriptionStatus.unused => _StatusSpec(
        color: t.gold,
        softColor: t.gold.withValues(alpha: 0.14),
      ),
    SubscriptionStatus.renewalSoon => _StatusSpec(
        color: t.blue,
        softColor: t.blue.withValues(alpha: 0.10),
      ),
  };
}

class _EmptyPlansCard extends StatelessWidget {
  const _EmptyPlansCard({required this.showImportCTA});
  final bool showImportCTA;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return VeraCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: t.uma.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.subscriptions_outlined,
                    color: t.uma, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      showImportCTA
                          ? context.l10n.noSubscriptionsDetectedTitle
                          : context.l10n.noSubscriptionsForFilterTitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: t.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      showImportCTA
                          ? context.l10n.noSubscriptionsDetectedBody
                          : context.l10n.noSubscriptionsForFilterBody,
                      style: TextStyle(fontSize: 12, color: t.muted, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showImportCTA) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openStatement(context),
                    icon: const Icon(Icons.upload_file_rounded, size: 16),
                    label: Text(context.l10n.statementImport),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: t.brand,
                      side: BorderSide(color: t.brand.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _openScan(context),
                    icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
                    label: Text(context.l10n.scanReceipt),
                    style: FilledButton.styleFrom(
                      backgroundColor: t.brand,
                      foregroundColor: t.brandFG,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _openStatement(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => const StatementImportSheet(),
    );
  }

  void _openScan(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => const ReceiptScanSheet(),
    );
  }
}

String _filterLabel(SubscriptionFilter filter, AppStrings l10n) {
  return switch (filter) {
    SubscriptionFilter.all => l10n.filterAll,
    SubscriptionFilter.attention => l10n.filterAttention,
    SubscriptionFilter.unused => l10n.filterUnused,
    SubscriptionFilter.priceChanges => l10n.filterPriceChanges,
  };
}

String _statusLabel(SubscriptionStatus status, AppStrings l10n) {
  return switch (status) {
    SubscriptionStatus.healthy => l10n.subsStatusActive,
    SubscriptionStatus.priceIncreased => l10n.subsStatusPriceUp,
    SubscriptionStatus.unused => l10n.subsStatusUnused,
    SubscriptionStatus.renewalSoon => l10n.subsStatusRenewsSoon,
  };
}

String _categoryLabel(String category, AppStrings l10n) {
  final normalized = category.trim().toLowerCase();
  return switch (normalized) {
    'entertainment' || 'eglence' => l10n.categoryEntertainment,
    'music' || 'muzik' => l10n.categoryMusic,
    'video' => l10n.categoryVideo,
    'storage' || 'depolama' => l10n.categoryStorage,
    'developer' || 'gelistirici' => l10n.categoryDeveloper,
    'ai' => l10n.categoryAi,
    'subscription' || 'abonelik' => l10n.categorySubscription,
    'other' || 'diger' => l10n.categoryOther,
    _ => category,
  };
}
