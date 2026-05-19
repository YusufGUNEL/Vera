import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/pill.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/vera_card.dart';

import '../domain/rebalance_action.dart';
import '../state/wealth_controller.dart';
import '../domain/investment_recommendation.dart';
import '../state/investment_recommendations_provider.dart';
import 'widgets/add_holding_sheet.dart';
import 'widgets/portfolio_donut.dart';

class WealthScreen extends ConsumerWidget {
  const WealthScreen({super.key});

  void _openAddHolding(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => const AddHoldingSheet(),
    );
  }

  void _openHoldingActions(
    BuildContext context,
    WidgetRef ref,
    String label,
  ) {
    final t = context.tokens;
    final l10n = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (sheetCtx) => Container(
        decoration: BoxDecoration(
          color: t.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: t.line,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: t.ink,
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.delete_outline, color: t.red),
                  title: Text(
                    l10n.removeHolding,
                    style: TextStyle(color: t.red, fontWeight: FontWeight.w600),
                  ),
                  onTap: () async {
                    Navigator.of(sheetCtx).pop();
                    await ref
                        .read(wealthControllerProvider.notifier)
                        .removeAllocation(label);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openInsight(BuildContext context, String insight) {
    final t = context.tokens;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          decoration: BoxDecoration(
            color: t.bg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: t.line,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                context.l10n.explainability,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: t.ink,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                insight,
                style: TextStyle(fontSize: 13, color: t.ink2, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openMoreRecommendations(
    BuildContext context,
    List<InvestmentRecommendation> recommendations,
  ) {
    final t = context.tokens;
    final l10n = context.l10n;
    final groups = _groupRecommendations(recommendations);
    final orderedTypes = _recommendationTypeOrder
        .where((type) => groups[type]?.isNotEmpty ?? false)
        .toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (sheetCtx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: t.bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: t.isDark ? t.line : const Color(0xFFD9D4C8),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(sheetCtx).pop(),
                      icon: Icon(Icons.close_rounded, color: t.ink, size: 24),
                    ),
                    Expanded(
                      child: Text(
                        'Akıllı Yatırım Önerileri',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: t.ink,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                  children: [
                    for (final type in orderedTypes) ...[
                      _RecommendationSectionHeader(
                        spec: _recommendationTypeSpec(type, t, l10n),
                      ),
                      const SizedBox(height: 8),
                      for (final item
                          in groups[type] ?? const <InvestmentRecommendation>[])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _RecommendationDetailCard(
                            item: item,
                            spec: _recommendationTypeSpec(type, t, l10n),
                          ),
                        ),
                      const SizedBox(height: 4),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l10n = context.l10n;
    final recommendationsAsync = ref.watch(investmentRecommendationsProvider);
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
        padding: const EdgeInsets.only(top: 8, bottom: 140),
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
                              l10n.portfolio,
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
                            Builder(builder: (_) {
                              final delta = state.todayDelta;
                              final pct = state.total <= 0
                                  ? 0
                                  : (delta / state.total * 100);
                              final color = delta >= 0 ? t.green : t.red;
                              final pctStr = pct.abs().toStringAsFixed(1);
                              return Text(
                                '${fmtSignedTL(delta)} ($pctStr%) ${l10n.today}',
                                style: TextStyle(color: color, fontSize: 13),
                              );
                            }),
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
                              l10n.ytd,
                              style: TextStyle(
                                color: t.muted,
                                fontSize: 10,
                                letterSpacing: 0.4,
                              ),
                            ),
                            Builder(builder: (_) {
                              final ytd = state.ytdPercent;
                              final sign = ytd >= 0 ? '+' : '';
                              return Text(
                                '$sign${ytd.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: ytd >= 0 ? t.green : t.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            }),
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
                        InkWell(
                          onTap: () =>
                              _openHoldingActions(context, ref, p.label),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            child: Row(
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
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        TextStyle(color: t.ink2, fontSize: 13),
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
                          ),
                        ),
                      if (portfolio.isNotEmpty)
                        InkWell(
                          onTap: () => _openAddHolding(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            child: Row(
                              children: [
                                Icon(Icons.add, size: 14, color: t.brand),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.addHoldingTitle,
                                  style: TextStyle(
                                    color: t.brand,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                          color: t.uma,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.lightbulb_outline_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.thisMonthsAiPlan,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: t.ink,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.aiPlanFooter,
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
                  const SizedBox(height: 14),
                  recommendationsAsync.when(
                    data: (items) {
                      final groups = _groupRecommendations(items);
                      final orderedTypes = _recommendationTypeOrder
                          .where((type) => groups[type]?.isNotEmpty ?? false)
                          .toList();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 156,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: orderedTypes.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 10),
                              itemBuilder: (context, idx) {
                                final type = orderedTypes[idx];
                                final spec = _recommendationTypeSpec(type, t, l10n);
                                return _RecommendationTypeCard(
                                  spec: spec,
                                  items: groups[type] ??
                                      const <InvestmentRecommendation>[],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => _openMoreRecommendations(context, items),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: t.line),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(
                                'Daha Fazla Gör',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (err, _) => Center(
                      child: Text(
                        'Öneriler yüklenemedi.',
                        style: TextStyle(color: t.red, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SectionTitle(
            title: l10n.activityFeed,
            actionLabel: state.allocations.isEmpty
                ? '+ ${l10n.addHoldingTitle}'
                : l10n.explainability,
            onAction: state.allocations.isEmpty
                ? () => _openAddHolding(context)
                : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: state.actions.isEmpty
                ? _EmptyWealthCard(
                    hasHoldings: state.allocations.isNotEmpty,
                    onAddHolding: () => _openAddHolding(context),
                  )
                : VeraCard(
                    child: Column(
                      children: [
                        for (var i = 0; i < state.actions.length; i++)
                          _ActivityRow(
                            action: state.actions[i],
                            isFirst: i == 0,
                            onUndo: state.actions[i].undoable &&
                                    !state.actions[i].undone
                                ? () => ref
                                    .read(wealthControllerProvider.notifier)
                                    .undoAction(state.actions[i].id)
                                : null,
                            onDetails: () =>
                                _openInsight(context, state.actions[i].why),
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

const _recommendationTypeOrder = ['equity', 'commodity', 'crypto'];

Map<String, List<InvestmentRecommendation>> _groupRecommendations(
    List<InvestmentRecommendation> items) {
  final grouped = <String, List<InvestmentRecommendation>>{};
  for (final item in items) {
    grouped.putIfAbsent(item.type, () => []).add(item);
  }
  return grouped;
}

_RecommendationTypeSpec _recommendationTypeSpec(
  String type,
  AppTokens t,
  AppStrings l10n,
) {
  return switch (type) {
    'commodity' => _RecommendationTypeSpec(
        label: l10n.recommendationTypeCommodity,
        icon: Icons.blur_circular_rounded,
        color: t.gold,
      ),
    'crypto' => _RecommendationTypeSpec(
        label: l10n.recommendationTypeCrypto,
        icon: Icons.currency_bitcoin_rounded,
        color: t.green,
      ),
    _ => _RecommendationTypeSpec(
        label: l10n.recommendationTypeEquity,
        icon: Icons.trending_up_rounded,
        color: t.brand,
      ),
  };
}

class _RecommendationTypeSpec {
  const _RecommendationTypeSpec({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

class _RecommendationTypeCard extends StatelessWidget {
  const _RecommendationTypeCard({
    required this.spec,
    required this.items,
  });

  final _RecommendationTypeSpec spec;
  final List<InvestmentRecommendation> items;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final preview = items.take(3).toList();
    return Container(
      width: 230,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: spec.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(spec.icon, color: spec.color, size: 14),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  spec.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: t.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < preview.length; i++) ...[
            if (i != 0) const SizedBox(height: 6),
            _RecommendationMiniRow(
              item: preview[i],
              accent: spec.color,
            ),
          ],
        ],
      ),
    );
  }
}

class _RecommendationMiniRow extends StatelessWidget {
  const _RecommendationMiniRow({
    required this.item,
    required this.accent,
  });

  final InvestmentRecommendation item;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          item.symbol,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: t.ink,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: t.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          item.returnRate,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: accent,
          ),
        ),
      ],
    );
  }
}

class _RecommendationSectionHeader extends StatelessWidget {
  const _RecommendationSectionHeader({required this.spec});

  final _RecommendationTypeSpec spec;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: spec.color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(spec.icon, color: spec.color, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          spec.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: t.ink,
          ),
        ),
      ],
    );
  }
}

class _RecommendationDetailCard extends StatelessWidget {
  const _RecommendationDetailCard({
    required this.item,
    required this.spec,
  });

  final InvestmentRecommendation item;
  final _RecommendationTypeSpec spec;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: spec.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(spec.icon, color: spec.color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: t.ink,
                      ),
                    ),
                    Text(
                      item.symbol,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: t.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: spec.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.returnRate,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: spec.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.explanation,
            style: TextStyle(
              fontSize: 12,
              color: t.ink2,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.auto_awesome, color: t.uma, size: 12),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.reason,
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: t.muted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyWealthCard extends StatelessWidget {
  const _EmptyWealthCard({
    required this.hasHoldings,
    required this.onAddHolding,
  });

  final bool hasHoldings;
  final VoidCallback onAddHolding;

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
                child: Icon(Icons.savings_outlined, color: t.uma, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasHoldings
                          ? context.l10n.noWealthActionsTitle
                          : context.l10n.startPortfolioTitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: t.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasHoldings
                          ? context.l10n.noWealthActionsBody
                          : context.l10n.startPortfolioBody,
                      style:
                          TextStyle(fontSize: 12, color: t.muted, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!hasHoldings) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onAddHolding,
                icon: const Icon(Icons.add, size: 16),
                label: Text(context.l10n.addHoldingTitle),
                style: FilledButton.styleFrom(
                  backgroundColor: t.brand,
                  foregroundColor: t.brandFG,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
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
            l10n.wealthTitle,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: t.ink,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.wealthSubtitle,
            style: TextStyle(fontSize: 13, color: t.muted),
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
    required this.onDetails,
  });

  final RebalanceAction action;
  final bool isFirst;
  final VoidCallback? onUndo;
  final VoidCallback onDetails;

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
                      label: action.undone
                          ? context.l10n.wealthActionReversed
                          : 'UMA',
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
                        label: context.l10n.undo,
                        icon: Icons.undo,
                        background: t.bgSoft,
                        color: t.ink2,
                        onTap: onUndo,
                      ),
                      const SizedBox(width: 8),
                    ],
                    _SmallBtn(
                      label: context.l10n.viewDetails,
                      background: Colors.transparent,
                      color: t.brand,
                      bordered: true,
                      onTap: onDetails,
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
