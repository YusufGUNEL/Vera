import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/font_weight_helper.dart';
import '../../../shared/widgets/pill.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/vera_card.dart';
import 'widgets/credit_gauge.dart';

class CreditScreen extends StatelessWidget {
  const CreditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 130),
        children: [
          _Header(),
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
                        child: Text('Credit Health Score',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: t.ink)),
                      ),
                      Pill(label: '+24 pts', color: t.green),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Center(child: CreditGauge(score: 782)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (final s in ['300', '500', '700', '850'])
                          Text(s,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: t.muted,
                                  letterSpacing: 0.3)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                          child: _StatChip(
                              label: 'PAYMENT', value: '100%', color: t.green)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _StatChip(
                              label: 'UTILIZATION',
                              value: '12%',
                              color: t.green)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _StatChip(
                              label: 'HISTORY', value: '8 yrs', color: t.ink2)),
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
                onTap: () {},
                borderRadius: BorderRadius.circular(t.vibe.radius - 2),
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: t.brand.withOpacity(0.22),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Request a loan',
                          style: TextStyle(
                            color: t.brandFG,
                            fontSize: 15,
                            fontWeight: fwFromInt(t.vibe.headWeight),
                            letterSpacing: -0.2,
                          )),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: t.brandFG, size: 17),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SectionTitle(title: 'Recent application'),
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
                          color: t.green.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.check, color: t.green, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Personal loan · ₺150.000',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: t.ink,
                                )),
                            const SizedBox(height: 1),
                            Text('36 months · 2.18% APR',
                                style:
                                    TextStyle(color: t.muted, fontSize: 12)),
                          ],
                        ),
                      ),
                      Pill(label: 'APPROVED', color: t.green),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
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
                          child: const Icon(Icons.auto_awesome,
                              color: Colors.white, size: 13),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('UMA INSIGHT',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: t.uma,
                                    letterSpacing: 0.4,
                                  )),
                              const SizedBox(height: 3),
                              Text.rich(
                                TextSpan(
                                  style: TextStyle(
                                      color: t.ink2,
                                      fontSize: 13,
                                      height: 1.5),
                                  children: const [
                                    TextSpan(text: 'Approved in '),
                                    TextSpan(
                                        text: '4 seconds',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700)),
                                    TextSpan(
                                        text:
                                            '. Your stable income from Aksoy Yazılım and low debt ratio qualifies you for the best rate available.'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: t.brand,
                          borderRadius: BorderRadius.circular(999),
                          child: InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              height: 38,
                              alignment: Alignment.center,
                              child: Text('Accept offer',
                                  style: TextStyle(
                                      color: t.brandFG,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Material(
                          color: t.bgSoft,
                          borderRadius: BorderRadius.circular(999),
                          child: InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              height: 38,
                              alignment: Alignment.center,
                              child: Text('Adjust terms',
                                  style: TextStyle(
                                      color: t.ink2,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
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
          const SectionTitle(title: 'Eligible products'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: const [
                _ProductRow(name: 'Mortgage refinance', rate: 'from 1.84%', tag: 'Pre-qualified'),
                SizedBox(height: 10),
                _ProductRow(name: 'Auto loan', rate: 'from 2.05%', tag: 'Pre-qualified'),
                SizedBox(height: 10),
                _ProductRow(name: 'Credit limit increase', rate: '+₺25.000', tag: 'Instant'),
              ],
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Credit',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: t.ink,
                  letterSpacing: -0.8)),
          const SizedBox(height: 2),
          Text('Borrowing built around your real income.',
              style: TextStyle(fontSize: 13, color: t.muted)),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value, required this.color});
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
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: t.muted, letterSpacing: 0.4)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.name, required this.rate, required this.tag});
  final String name;
  final String rate;
  final String tag;

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
                Text(name,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: t.ink)),
                const SizedBox(height: 1),
                Text(rate,
                    style: TextStyle(color: t.muted, fontSize: 12)),
              ],
            ),
          ),
          Pill(label: tag, color: t.brand),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: t.muted, size: 18),
        ],
      ),
    );
  }
}
