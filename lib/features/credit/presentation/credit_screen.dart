import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/vera_card.dart';
import '../state/credit_controller.dart';

class CreditScreen extends ConsumerWidget {
  const CreditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l10n = context.l10n;
    final state = ref.watch(creditControllerProvider);
    final app = state.application;
    final calc = state.calculation;

    final dtiAfter = app.monthlyIncome <= 0
        ? 0.0
        : (app.monthlyDebt + calc.monthlyPayment) / app.monthlyIncome;
    final loadColor = calc.paymentLoad <= 0.28
        ? t.green
        : calc.paymentLoad <= 0.40
            ? t.gold
            : t.red;
    final dtiAfterColor = dtiAfter <= 0.35
        ? t.green
        : dtiAfter <= 0.50
            ? t.gold
            : t.red;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 130),
        children: [
          _Header(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: VeraCard(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 18, color: t.uma),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.creditScoreDisclaimer,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: t.ink2,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: VeraCard(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.creditLoanSimulation,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: t.ink,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.creditLoanSimulationSubtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: t.muted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SliderField(
                    label: l10n.creditFieldLoanAmount,
                    valueLabel: fmtTL(app.amount),
                    min: 5000,
                    max: 500000,
                    value: app.amount,
                    onChanged: (v) => ref
                        .read(creditControllerProvider.notifier)
                        .setAmount(v),
                  ),
                  _SliderField(
                    label: l10n.creditFieldTerm,
                    valueLabel: l10n.creditTermMonths(app.months),
                    min: 6,
                    max: 60,
                    divisions: 9,
                    value: app.months.toDouble(),
                    onChanged: (v) => ref
                        .read(creditControllerProvider.notifier)
                        .setMonths((v / 6).round() * 6),
                  ),
                  _SliderField(
                    label: l10n.creditFieldIncome,
                    valueLabel: fmtTL(app.monthlyIncome),
                    min: 5000,
                    max: 200000,
                    value: app.monthlyIncome,
                    onChanged: (v) => ref
                        .read(creditControllerProvider.notifier)
                        .setIncome(v),
                  ),
                  _SliderField(
                    label: l10n.creditFieldDebt,
                    valueLabel: fmtTL(app.monthlyDebt),
                    min: 0,
                    max: 80000,
                    value: app.monthlyDebt,
                    onChanged: (v) => ref
                        .read(creditControllerProvider.notifier)
                        .setDebt(v),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: VeraCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.creditResultMonthlyPayment,
                    style: TextStyle(
                      fontSize: 11,
                      color: t.muted,
                      letterSpacing: 0.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fmtTL(calc.monthlyPayment),
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: t.ink,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _ResultRow(
                    label: l10n.creditResultTotalCost,
                    value: fmtTL(calc.totalCost),
                  ),
                  const SizedBox(height: 8),
                  _ResultRow(
                    label: l10n.creditResultPaymentLoad,
                    value:
                        '${(calc.paymentLoad * 100).toStringAsFixed(0)}%',
                    valueColor: loadColor,
                  ),
                  const SizedBox(height: 8),
                  _ResultRow(
                    label: l10n.creditResultDtiAfter,
                    value: '${(dtiAfter * 100).toStringAsFixed(0)}%',
                    valueColor: dtiAfterColor,
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: t.bgSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.creditResultGuidance,
                      style: TextStyle(
                        fontSize: 12,
                        color: t.ink2,
                        height: 1.45,
                      ),
                    ),
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
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go(Routes.home),
            icon: Icon(Icons.arrow_back, color: t.ink, size: 24),
            tooltip: l10n.bankActionsCancel,
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.creditTitle,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: t.ink,
                    letterSpacing: -0.6,
                  ),
                ),
                Text(
                  l10n.creditSubtitle,
                  style: TextStyle(fontSize: 12.5, color: t.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: t.muted),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor ?? t.ink,
          ),
        ),
      ],
    );
  }
}

class _SliderField extends StatelessWidget {
  const _SliderField({
    required this.label,
    required this.valueLabel,
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
    this.divisions,
  });

  final String label;
  final String valueLabel;
  final double min;
  final double max;
  final double value;
  final ValueChanged<double> onChanged;
  final int? divisions;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: t.ink,
                  ),
                ),
              ),
              Text(
                valueLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: t.brand,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
