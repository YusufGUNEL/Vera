import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';

/// Generic read-only info sheet used by profile account tiles
/// (Personal info / Email / Security / Storage / Help).
class AccountInfoSheet extends StatelessWidget {
  const AccountInfoSheet({
    required this.title,
    required this.icon,
    required this.sections,
    this.ctaLabel,
    this.onCta,
    super.key,
  });

  final String title;
  final IconData icon;
  final List<AccountInfoSection> sections;
  final String? ctaLabel;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final mq = MediaQuery.of(context);
    return Container(
      decoration: BoxDecoration(
        color: t.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: mq.size.height * 0.78),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: t.brand.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Icon(icon, color: t.brand, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
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
                const SizedBox(height: 18),
                for (var i = 0; i < sections.length; i++) ...[
                  if (i != 0) const SizedBox(height: 14),
                  _SectionBody(section: sections[i]),
                ],
                if (ctaLabel != null && onCta != null) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: onCta,
                      style: FilledButton.styleFrom(
                        backgroundColor: t.brand,
                        foregroundColor: t.brandFG,
                      ),
                      child: Text(
                        ctaLabel!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
}

class AccountInfoSection {
  const AccountInfoSection({
    required this.label,
    required this.body,
  });

  final String label;
  final String body;
}

class _SectionBody extends StatelessWidget {
  const _SectionBody({required this.section});

  final AccountInfoSection section;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: t.muted,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            section.body,
            style: TextStyle(
              fontSize: 13.5,
              color: t.ink2,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
