import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/pill.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/vera_card.dart';
import '../domain/subscription_alert.dart';
import '../domain/subscription_item.dart';
import '../domain/subscription_status.dart';
import '../state/subscriptions_controller.dart';

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final state = ref.watch(subscriptionsControllerProvider);

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SUBSCRIPTION INTELLIGENCE',
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
                    '${state.attentionCount} plans need attention this cycle',
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
            title: 'Detected plans',
            actionLabel: '${state.visibleItems.length} visible',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final filter in SubscriptionFilter.values)
                  _FilterChip(
                    label: _filterLabel(filter),
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
            child: VeraCard(
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plans',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: t.ink,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Catch silent money leaks before they stack up.',
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
                      label: item.status.label,
                      color: spec.color,
                      background: spec.softColor,
                      fontSize: 9,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.vendor} · ${item.category}',
                  style: TextStyle(fontSize: 12, color: t.muted),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child:
                          _MetaItem(label: 'Renewal', value: item.renewalLabel),
                    ),
                    Expanded(
                      child: _MetaItem(
                          label: 'Activity', value: item.lastUsedLabel),
                    ),
                  ],
                ),
                if (item.priceDelta > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Up by ${fmtTL(item.priceDelta)} vs last cycle',
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    _ActionChip(
                      label: item.canFreeze ? 'Freeze plan' : 'Review plan',
                      foreground: t.brand,
                      background: t.brandSoft.withValues(alpha: 0.16),
                    ),
                    const SizedBox(width: 8),
                    _ActionChip(
                      label: 'Ask Uma',
                      foreground: t.uma,
                      background: t.umaSoft,
                    ),
                  ],
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

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
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

String _filterLabel(SubscriptionFilter filter) {
  return switch (filter) {
    SubscriptionFilter.all => 'All',
    SubscriptionFilter.attention => 'Needs attention',
    SubscriptionFilter.unused => 'Unused',
    SubscriptionFilter.priceChanges => 'Price changes',
  };
}
