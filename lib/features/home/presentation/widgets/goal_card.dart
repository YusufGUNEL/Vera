import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/goal_advisor.dart';
import '../../state/goals_controller.dart';
import '../../state/home_controller.dart';

class GoalCard extends ConsumerWidget {
  const GoalCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l10n = context.l10n;
    final goal = ref.watch(goalsControllerProvider);
    final pct = (goal.progress * 100).round();
    final isEmpty = goal.target <= 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(t.vibe.radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(t.vibe.radius),
          onTap: () => _openEditor(context),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(t.vibe.radius),
              gradient: LinearGradient(
                begin: const Alignment(-1, -1),
                end: const Alignment(1, 1),
                colors: [
                  t.brand.withValues(alpha: 0.10),
                  t.uma.withValues(alpha: 0.14),
                ],
              ),
              border: Border.all(color: t.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: t.uma,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.flag_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.goalEmergencyFund,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: t.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isEmpty
                                ? l10n.goalEmptyPrompt
                                : '${fmtTL(goal.saved)} · ${fmtTL(goal.target)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: t.ink2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isEmpty ? Icons.add : Icons.edit_outlined,
                      size: 16,
                      color: t.muted,
                    ),
                  ],
                ),
                if (isEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    l10n.goalEmptyHint,
                    style: TextStyle(
                      fontSize: 11,
                      color: t.muted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (final m in const [3, 6, 12]) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: t.card,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: t.line),
                          ),
                          child: Text(
                            l10n.goalMonthsOption(m),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: t.ink2,
                            ),
                          ),
                        ),
                        if (m != 12) const SizedBox(width: 8),
                      ],
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: t.uma,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          l10n.goalEmptyCta,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (!isEmpty) ...[
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: goal.progress,
                      backgroundColor: t.bgSoft,
                      valueColor: AlwaysStoppedAnimation(t.green),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: t.green.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          l10n.goalProgress('$pct'),
                          style: TextStyle(
                            color: t.green,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          goal.isReached
                              ? l10n.goalEtaReached
                              : (goal.etaMonths == null
                                  ? l10n.goalRemaining(fmtTL(goal.remaining))
                                  : '${l10n.goalRemaining(fmtTL(goal.remaining))} · ${l10n.goalEtaMonths(goal.etaMonths!)}'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: t.muted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openEditor(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => const GoalEditSheet(),
    );
  }
}

class GoalEditSheet extends ConsumerStatefulWidget {
  const GoalEditSheet({super.key});

  @override
  ConsumerState<GoalEditSheet> createState() => _GoalEditSheetState();
}

class _GoalEditSheetState extends ConsumerState<GoalEditSheet> {
  late final TextEditingController _targetCtrl;
  late final TextEditingController _savedCtrl;
  int _months = 12;
  GoalAdviceResult? _advice;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final goal = ref.read(goalsControllerProvider);
    _targetCtrl =
        TextEditingController(text: goal.target.round().toString());
    _savedCtrl =
        TextEditingController(text: goal.saved.round().toString());
  }

  @override
  void dispose() {
    _targetCtrl.dispose();
    _savedCtrl.dispose();
    super.dispose();
  }

  void _applyPreset(double amount, int targetMonths) {
    setState(() {
      _targetCtrl.text = amount.round().toString();
      _months = targetMonths;
    });
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final target = double.tryParse(_targetCtrl.text.trim()) ?? 0;
    final saved = double.tryParse(_savedCtrl.text.trim()) ?? 0;
    if (target <= 0) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    await ref.read(goalsControllerProvider.notifier).updateGoal(
          target: target,
          saved: saved.clamp(0, double.infinity).toDouble(),
        );
    setState(() => _busy = true);
    final result = await ref.read(goalAdvisorProvider).advise(
          goal: ref.read(goalsControllerProvider),
          transactions: ref.read(homeControllerProvider).transactions,
          l10n: l10n,
          targetMonths: _months,
        );
    if (!mounted) return;
    setState(() {
      _advice = result;
      _busy = false;
    });
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_rounded, color: t.muted),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: l10n.actionBack,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        l10n.goalEditTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: t.ink,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.goalEditFooter,
                  style: TextStyle(fontSize: 12, color: t.muted, height: 1.4),
                ),
                const SizedBox(height: 18),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _PresetChip(
                        label: l10n.goalPresetEmergency('50.000 TL'),
                        onTap: () => _applyPreset(50000, 6),
                      ),
                      const SizedBox(width: 8),
                      _PresetChip(
                        label: l10n.goalPresetVacation('20.000 TL'),
                        onTap: () => _applyPreset(20000, 3),
                      ),
                      const SizedBox(width: 8),
                      _PresetChip(
                        label: l10n.goalPresetCar('150.000 TL'),
                        onTap: () => _applyPreset(150000, 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _NumField(label: l10n.goalEditTarget, controller: _targetCtrl),
                const SizedBox(height: 12),
                _NumField(label: l10n.goalEditSaved, controller: _savedCtrl),
                const SizedBox(height: 12),
                Text(
                  l10n.goalMonthsLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: t.muted,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final m in const [3, 6, 12, 18, 24])
                      InkWell(
                        onTap: () => setState(() => _months = m),
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _months == m
                                ? t.brand.withValues(alpha: 0.14)
                                : t.card,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: _months == m ? t.brand : t.line,
                            ),
                          ),
                          child: Text(
                            l10n.goalMonthsOption(m),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _months == m ? t.brand : t.ink2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                if (_advice != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: t.umaSoft,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: t.uma.withValues(alpha: 0.18)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: t.uma,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.auto_awesome,
                              color: Colors.white, size: 15),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.goalAdviceSummary(
                                  fmtTL(_advice!.monthlyRequired),
                                  _advice!.etaMonths,
                                ),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: t.ink,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _advice!.aiNarrative,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: t.ink2,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    if (_advice != null)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: t.ink,
                            side: BorderSide(color: t.line),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: Text(l10n.close),
                        ),
                      ),
                    if (_advice != null) const SizedBox(width: 10),
                    Expanded(
                      flex: _advice == null ? 1 : 1,
                      child: SizedBox(
                        height: 50,
                        child: FilledButton(
                          onPressed: _busy ? null : _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: t.brand,
                            foregroundColor: t.brandFG,
                          ),
                          child: _busy
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: t.brandFG,
                                  ),
                                )
                              : Text(
                                  _advice == null
                                      ? l10n.goalEditSave
                                      : l10n.goalCalculate,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
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

class _NumField extends StatelessWidget {
  const _NumField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: t.muted,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: false),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(fontSize: 14, color: t.ink),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: t.card,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: t.umaSoft,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: t.uma.withValues(alpha: 0.16)),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, size: 12, color: t.uma),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: t.uma,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
