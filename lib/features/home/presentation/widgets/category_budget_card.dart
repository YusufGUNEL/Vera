import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/category_summary.dart';
import '../../data/transaction.dart';
import '../../state/category_budget_controller.dart';

/// Home ekraninda son donem harcamalarini kategoriye gore gosterir.
/// Donut + legend + kategori bazli aylik limit + kalan TL ipucu.
class CategoryBudgetCard extends ConsumerWidget {
  const CategoryBudgetCard({
    required this.transactions,
    this.onTap,
    super.key,
  });

  final List<Txn> transactions;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l10n = context.l10n;
    final budgets = ref.watch(categoryBudgetControllerProvider);
    final spends = summarizeSpending(
      transactions,
      otherLabel: l10n.categoryOther,
      otherColor: t.muted,
    );

    if (spends.isEmpty) return const SizedBox.shrink();

    final total = totalSpending(spends);
    final top = spends.first;
    final topShare = (top.amount / total * 100).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(t.vibe.radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(t.vibe.radius),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: BoxDecoration(
              color: t.card,
              borderRadius: BorderRadius.circular(t.vibe.radius),
              border: Border.all(color: t.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.categoryBudgetLabel,
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w700,
                              color: t.muted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            fmtTL(total),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: t.ink,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.categoryBudgetTopHint(
                                top.category, '$topShare'),
                            style: TextStyle(
                              fontSize: 12,
                              color: t.ink2,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _CategoryDonut(
                      spends: spends,
                      total: total,
                      trackColor: t.bgSoft,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(height: 1, color: t.line),
                const SizedBox(height: 12),
                for (var i = 0; i < spends.length; i++) ...[
                  if (i != 0) const SizedBox(height: 10),
                  _CategoryRow(
                    spend: spends[i],
                    share: spends[i].amount / total,
                    limit: budgets[spends[i].category],
                    onTap: () => _openLimitEditor(
                      context,
                      ref,
                      spends[i].category,
                      budgets[spends[i].category],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openLimitEditor(
    BuildContext context,
    WidgetRef ref,
    String category,
    double? currentLimit,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => _CategoryLimitSheet(
        category: category,
        currentLimit: currentLimit,
      ),
    );
  }
}

class _CategoryDonut extends StatelessWidget {
  const _CategoryDonut({
    required this.spends,
    required this.total,
    required this.trackColor,
  });

  final List<CategorySpend> spends;
  final double total;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: 84,
      child: CustomPaint(
        painter: _CategoryDonutPainter(
          spends: spends,
          total: total,
          trackColor: trackColor,
          stroke: 12,
        ),
      ),
    );
  }
}

class _CategoryDonutPainter extends CustomPainter {
  _CategoryDonutPainter({
    required this.spends,
    required this.total,
    required this.trackColor,
    required this.stroke,
  });

  final List<CategorySpend> spends;
  final double total;
  final Color trackColor;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(rect.center, rect.width / 2, track);

    if (total <= 0) return;
    const gap = 0.04;
    var start = -math.pi / 2;
    for (final s in spends) {
      final sweep = (s.amount / total) * (2 * math.pi) - gap;
      if (sweep <= 0) continue;
      final paint = Paint()
        ..color = s.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _CategoryDonutPainter old) =>
      old.spends != spends || old.total != total;
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.spend,
    required this.share,
    required this.limit,
    required this.onTap,
  });

  final CategorySpend spend;
  final double share;
  final double? limit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final pct = (share * 100).round();
    final overLimit = limit != null && spend.amount > limit!;
    final progressColor = overLimit ? t.red : spend.color;
    final progressValue =
        limit == null ? share : (spend.amount / limit!).clamp(0.0, 1.0);
    final remainingLabel = limit == null
        ? l10n.categoryNoLimit
        : (overLimit
            ? l10n.categoryOver(fmtTL(spend.amount - limit!))
            : l10n.categoryRemaining(fmtTL(limit! - spend.amount)));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: spend.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(spend.icon, color: spend.color, size: 14),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          spend.category,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: t.ink,
                          ),
                        ),
                      ),
                      Text(
                        fmtTL(spend.amount),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: t.ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progressValue.toDouble(),
                            backgroundColor: t.bgSoft,
                            valueColor: AlwaysStoppedAnimation(progressColor),
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '%$pct',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: t.muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    remainingLabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: overLimit ? t.red : t.muted,
                      fontWeight: overLimit ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryLimitSheet extends ConsumerStatefulWidget {
  const _CategoryLimitSheet({
    required this.category,
    required this.currentLimit,
  });

  final String category;
  final double? currentLimit;

  @override
  ConsumerState<_CategoryLimitSheet> createState() =>
      _CategoryLimitSheetState();
}

class _CategoryLimitSheetState extends ConsumerState<_CategoryLimitSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.currentLimit?.round().toString() ?? '',
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = double.tryParse(_ctrl.text.trim()) ?? 0;
    await ref
        .read(categoryBudgetControllerProvider.notifier)
        .setLimit(widget.category, value);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _clear() async {
    await ref
        .read(categoryBudgetControllerProvider.notifier)
        .setLimit(widget.category, 0);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final mq = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Container(
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
                const SizedBox(height: 16),
                Text(
                  l10n.categoryLimitEditTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: t.ink,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.categoryLimitEditSubtitle(widget.category),
                  style: TextStyle(fontSize: 12, color: t.muted, height: 1.4),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.categoryLimitField,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: t.muted,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _ctrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  autofocus: true,
                  style: TextStyle(fontSize: 14, color: t.ink),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: t.card,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: t.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: t.line),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: t.brand, width: 1.4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (widget.currentLimit != null) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _clear,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: t.red,
                            side:
                                BorderSide(color: t.red.withValues(alpha: 0.35)),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                          ),
                          child: Text(l10n.categoryLimitClear),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: FilledButton(
                        onPressed: _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: t.brand,
                          foregroundColor: t.brandFG,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        child: Text(l10n.categoryLimitSave),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
