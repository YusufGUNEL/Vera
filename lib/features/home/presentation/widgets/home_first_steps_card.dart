import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/vera_card.dart';

class HomeFirstStepsCard extends StatelessWidget {
  const HomeFirstStepsCard({
    this.onImport,
    this.onScan,
    this.onAddBank,
    super.key,
  });

  final VoidCallback? onImport;
  final VoidCallback? onScan;
  final VoidCallback? onAddBank;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: VeraCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: t.brand.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.auto_awesome, color: t.brand, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.homeFirstStepsTitle,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: t.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.homeFirstStepsBody,
                        style: TextStyle(
                          fontSize: 12,
                          color: t.ink2,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                if (onImport != null)
                  Expanded(
                    child: _HomeFirstStepAction(
                      icon: Icons.upload_file_rounded,
                      label: l10n.statementImport,
                      onTap: onImport!,
                    ),
                  ),
                if (onScan != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _HomeFirstStepAction(
                      icon: Icons.qr_code_scanner_rounded,
                      label: l10n.scanReceipt,
                      onTap: onScan!,
                    ),
                  ),
                ],
                if (onAddBank != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _HomeFirstStepAction(
                      icon: Icons.account_balance_outlined,
                      label: l10n.connectBank,
                      onTap: onAddBank!,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.homeFirstStepsHint,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: t.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeFirstStepAction extends StatelessWidget {
  const _HomeFirstStepAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Material(
      color: t.bgSoft,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: t.brand, size: 18),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: t.ink,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
