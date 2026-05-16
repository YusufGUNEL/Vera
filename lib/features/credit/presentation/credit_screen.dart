import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/font_weight_helper.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/pill.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/vera_card.dart';
import '../domain/credit_decision.dart';
import '../domain/offer_option.dart';
import '../domain/risk_factor.dart';
import '../state/credit_controller.dart';
import 'widgets/credit_gauge.dart';

class CreditScreen extends ConsumerWidget {
  const CreditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l10n = context.l10n;
    final state = ref.watch(creditControllerProvider);
    final application = state.application;
    final decision = state.decision;

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
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(
                          l10n.creditHealthScore,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: t.ink,
                          ),
                        ),
                      ),
                      Pill(
                        label: _scoreTrendLabel(decision.score),
                        color: _statusColor(decision.status, t),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: CreditGauge(
                      score: decision.score,
                      bandLabel: decision.bandLabel,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (final s in ['300', '500', '700', '850'])
                          Text(
                            s,
                            style: TextStyle(
                              fontSize: 11,
                              color: t.muted,
                              letterSpacing: 0.3,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _StatChip(
                          label: l10n.creditStatIncome,
                          value: fmtTL(application.monthlyIncome),
                          color: t.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatChip(
                          label: l10n.creditStatDti,
                          value: '${(application.debtToIncome * 100).round()}%',
                          color: application.debtToIncome <= 0.25
                              ? t.green
                              : t.ink2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatChip(
                          label: l10n.creditStatTerm,
                          value: l10n.creditTermMo(application.months),
                          color: t.ink2,
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
            child: Material(
              color: t.brand,
              borderRadius: BorderRadius.circular(t.vibe.radius - 2),
              child: InkWell(
                onTap: () => _openSimulation(context),
                borderRadius: BorderRadius.circular(t.vibe.radius - 2),
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: t.brand.withValues(alpha: 0.22),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.creditRunSimulation,
                        style: TextStyle(
                          color: t.brandFG,
                          fontSize: 15,
                          fontWeight: fwFromInt(t.vibe.headWeight),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.tune, color: t.brandFG, size: 17),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SectionTitle(title: l10n.creditCurrentDecision),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: VeraCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _statusColor(decision.status, t)
                              .withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          _statusIcon(decision.status),
                          color: _statusColor(decision.status, t),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.creditPersonalLoan(
                                  fmtTL(decision.recommendedAmount)),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: t.ink,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              l10n.creditMonthsApr(
                                decision.recommendedMonths,
                                decision.apr.toStringAsFixed(2),
                              ),
                              style: TextStyle(color: t.muted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Pill(
                        label: _statusLabel(decision.status),
                        color: _statusColor(decision.status, t),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: t.umaSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: t.uma,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 13,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.creditUmaInsight,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: t.uma,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                decision.insight,
                                style: TextStyle(
                                  color: t.ink2,
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      decision.summary,
                      style: TextStyle(
                        fontSize: 13,
                        color: t.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      for (final factor in decision.riskFactors)
                        _RiskFactorRow(factor: factor),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SectionTitle(title: l10n.creditEligibleProducts),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (var i = 0; i < decision.offers.length; i++) ...[
                  _ProductRow(offer: decision.offers[i]),
                  if (i != decision.offers.length - 1)
                    const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openSimulation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _LoanSimulationSheet(),
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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.creditTitle,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: t.ink,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.creditSubtitle,
            style: TextStyle(fontSize: 13, color: t.muted),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
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
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskFactorRow extends StatelessWidget {
  const _RiskFactorRow({required this.factor});

  final RiskFactor factor;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final color = switch (factor.impact) {
      RiskImpact.positive => t.green,
      RiskImpact.caution => t.gold,
      RiskImpact.negative => t.red,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  factor.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: t.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  factor.detail,
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

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.offer});

  final OfferOption offer;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return VeraCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: t.bgSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.credit_card_outlined, color: t.brand, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: t.ink,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  offer.rateLabel,
                  style: TextStyle(color: t.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          Pill(label: offer.tag, color: t.brand),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: t.muted, size: 18),
        ],
      ),
    );
  }
}

class _LoanSimulationSheet extends ConsumerWidget {
  const _LoanSimulationSheet();

  @override
  Widget build(BuildContext context, WidgetRef localRef) {
    final t = context.tokens;
    final l10n = context.l10n;
    final state = localRef.watch(creditControllerProvider);
    final current = state.application;
    final decision = state.decision;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: t.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: SingleChildScrollView(
              child: Column(
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
                    l10n.creditLoanSimulation,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: t.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.creditLoanSimulationSubtitle,
                    style: TextStyle(fontSize: 13, color: t.muted),
                  ),
                  const SizedBox(height: 18),
                  _SliderField(
                    label: l10n.creditFieldLoanAmount,
                    valueLabel: fmtTL(current.amount),
                    min: 20000,
                    max: 250000,
                    value: current.amount,
                    onChanged: (value) => localRef
                        .read(creditControllerProvider.notifier)
                        .setAmount(value),
                  ),
                  _SliderField(
                    label: l10n.creditFieldTerm,
                    valueLabel: l10n.creditTermMonths(current.months),
                    min: 12,
                    max: 48,
                    divisions: 6,
                    value: current.months.toDouble(),
                    onChanged: (value) => localRef
                        .read(creditControllerProvider.notifier)
                        .setMonths((value / 6).round() * 6),
                  ),
                  _SliderField(
                    label: l10n.creditFieldIncome,
                    valueLabel: fmtTL(current.monthlyIncome),
                    min: 20000,
                    max: 80000,
                    value: current.monthlyIncome,
                    onChanged: (value) => localRef
                        .read(creditControllerProvider.notifier)
                        .setIncome(value),
                  ),
                  _SliderField(
                    label: l10n.creditFieldDebt,
                    valueLabel: fmtTL(current.monthlyDebt),
                    min: 0,
                    max: 30000,
                    value: current.monthlyDebt,
                    onChanged: (value) => localRef
                        .read(creditControllerProvider.notifier)
                        .setDebt(value),
                  ),
                  const SizedBox(height: 12),
                  VeraCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                decision.summary,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: t.ink,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'APR ${decision.apr.toStringAsFixed(2)}% · Score ${decision.score}',
                                style: TextStyle(fontSize: 12, color: t.muted),
                              ),
                            ],
                          ),
                        ),
                        Pill(
                          label: _statusLabel(decision.status),
                          color: _statusColor(decision.status, t),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
      padding: const EdgeInsets.only(bottom: 14),
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

Color _statusColor(CreditDecisionStatus status, AppTokens t) {
  return switch (status) {
    CreditDecisionStatus.approved => t.green,
    CreditDecisionStatus.review => t.gold,
    CreditDecisionStatus.declined => t.red,
  };
}

IconData _statusIcon(CreditDecisionStatus status) {
  return switch (status) {
    CreditDecisionStatus.approved => Icons.check,
    CreditDecisionStatus.review => Icons.manage_search_outlined,
    CreditDecisionStatus.declined => Icons.close,
  };
}

String _statusLabel(CreditDecisionStatus status) {
  return switch (status) {
    CreditDecisionStatus.approved => 'APPROVED',
    CreditDecisionStatus.review => 'REVIEW',
    CreditDecisionStatus.declined => 'DECLINED',
  };
}

String _scoreTrendLabel(int score) {
  if (score >= 760) return '+24 pts';
  if (score >= 690) return '+8 pts';
  if (score >= 620) return 'Watch closely';
  return 'Needs work';
}
