import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../shared/widgets/pill.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/vera_card.dart';
import '../data/security_check.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _expanded = true;

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
                          color: t.green.withOpacity(0.10),
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
                            Text('ACCOUNT SECURITY',
                                style: TextStyle(
                                    color: t.muted,
                                    fontSize: 12,
                                    letterSpacing: 0.4)),
                            Text('Secure',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: t.green,
                                    letterSpacing: -0.3)),
                            const SizedBox(height: 1),
                            Text('Fraud Radar active · last scan 30s ago',
                                style: TextStyle(
                                    fontSize: 12, color: t.muted)),
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
                              label: 'BLOCKED',
                              value: '1',
                              sub: 'today',
                              color: t.red)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _StatCell(
                              label: 'REVIEWED',
                              value: '147',
                              sub: 'this week',
                              color: t.ink)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _StatCell(
                              label: 'DEVICES',
                              value: '3',
                              sub: 'trusted',
                              color: t.ink)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SectionTitle(title: 'Recent activity', actionLabel: 'Filter'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: VeraCard(
              child: Column(
                children: [
                  for (var i = 0; i < kSecurityChecks.length; i++)
                    _CheckTile(
                      check: kSecurityChecks[i],
                      isFirst: i == 0,
                      expanded: _expanded,
                      onToggleExpand: () =>
                          setState(() => _expanded = !_expanded),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Security',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: t.ink,
                  letterSpacing: -0.8)),
          const SizedBox(height: 2),
          Text('Fraud Radar — always on, always learning.',
              style: TextStyle(fontSize: 13, color: t.muted)),
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
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: t.muted, letterSpacing: 0.4)),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600, color: color)),
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
    required this.onToggleExpand,
  });

  final SecurityCheck check;
  final bool isFirst;
  final bool expanded;
  final VoidCallback onToggleExpand;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final blocked = check.blocked;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: blocked ? t.red.withOpacity(0.03) : Colors.transparent,
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
                  color: (blocked ? t.red : t.green).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  blocked ? Icons.warning_amber_rounded : Icons.check,
                  color: blocked ? t.red : t.green,
                  size: 17,
                ),
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
                        Text(check.name,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: t.ink)),
                        if (blocked)
                          Pill(label: 'BLOCKED BY AI', color: t.red, fontSize: 9),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text('${check.location} · ${check.when}',
                        style: TextStyle(fontSize: 12, color: t.muted)),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (blocked && check.reason != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: t.umaSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: t.uma.withOpacity(0.13)),
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
                          child: const Icon(Icons.auto_awesome,
                              size: 12, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('VIEW UMA REPORT',
                              style: TextStyle(
                                fontSize: 12,
                                color: t.uma,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              )),
                        ),
                        Icon(
                            expanded
                                ? Icons.keyboard_arrow_down
                                : Icons.chevron_right,
                            color: t.uma,
                            size: 16),
                      ],
                    ),
                  ),
                  if (expanded) ...[
                    const SizedBox(height: 10),
                    Text(check.reason!,
                        style: TextStyle(
                          color: t.ink2,
                          fontSize: 13,
                          height: 1.5,
                        )),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: t.uma.withOpacity(0.13)),
                        ),
                      ),
                      child: Row(
                        children: [
                          _InfoChip(
                              icon: Icons.location_on_outlined,
                              text: 'Lagos, NG (anomaly)',
                              color: t.uma),
                          const SizedBox(width: 12),
                          _InfoChip(
                              icon: Icons.bolt,
                              text: '96% fraud confidence',
                              color: t.uma),
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
                                height: 34,
                                alignment: Alignment.center,
                                child: Text('Keep blocked',
                                    style: TextStyle(
                                        color: t.brandFG,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
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
                              onTap: () {},
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                height: 34,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(color: t.line),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text('This was me',
                                    style: TextStyle(
                                        color: t.ink2,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500)),
                              ),
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
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text, required this.color});
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
