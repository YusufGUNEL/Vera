import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/pill.dart';
import '../../domain/uma_message.dart';

class UmaOrderCard extends StatelessWidget {
  const UmaOrderCard({
    required this.card,
    required this.onForward,
    required this.onDismiss,
    super.key,
  });

  final OrderCard card;
  final VoidCallback onForward;
  final VoidCallback onDismiss;

  Future<void> _launchAndForward(BuildContext context) async {
    final scheme = _schemeFor(card.bankApp);
    if (scheme != null) {
      final uri = Uri.parse(scheme);
      try {
        final ok = await canLaunchUrl(uri);
        if (ok) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (_) {
        // sessizce sin: snackbar zaten gosterilecek
      }
    }
    onForward();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.forwardedToBank(card.bankApp)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final spec = _specFor(card.type, t);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.card,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: spec.softColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(spec.icon, color: spec.color, size: 15),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  card.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: t.ink,
                  ),
                ),
              ),
              switch (card.status) {
                OrderStatus.forwarded =>
                  Pill(label: card.bankApp.toUpperCase(), color: t.green),
                OrderStatus.dismissed =>
                  Pill(label: context.l10n.orderPillDismissed, color: t.muted),
                OrderStatus.review =>
                  Pill(label: context.l10n.orderPillReady, color: t.uma),
              },
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: t.line),
                bottom: BorderSide(color: t.line),
              ),
            ),
            child: Column(
              children: [
                _Row(k: l10n.orderFrom, v: card.from),
                _Row(k: l10n.orderTo, v: card.to),
                if (card.detailLabel != null && card.detailValue != null)
                  _Row(k: card.detailLabel!, v: card.detailValue!),
                _Row(k: l10n.orderAmount, v: fmtTL(card.amount), bold: true),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (card.status == OrderStatus.review) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: t.umaSoft,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: t.uma.withValues(alpha: 0.16)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lock_outline, color: t.uma, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.umaForwardNote,
                      style: TextStyle(
                        color: t.ink2,
                        fontSize: 11.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDismiss,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: t.line),
                      foregroundColor: t.ink2,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.keep),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => _launchAndForward(context),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: Text(
                      l10n.openBankApp(card.bankApp),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: t.brand,
                      foregroundColor: t.brandFG,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(t.vibe.radiusSmall),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (card.status == OrderStatus.forwarded)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(Icons.visibility_outlined, size: 14, color: t.green),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l10n.forwardedToBank(card.bankApp),
                      style: TextStyle(
                        fontSize: 12,
                        color: t.muted,
                      ),
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

class _Row extends StatelessWidget {
  const _Row({required this.k, required this.v, this.bold = false});

  final String k;
  final String v;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: TextStyle(color: t.muted, fontSize: 13)),
          Flexible(
            child: Text(
              v,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: t.ink,
                fontSize: 13,
                fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: bold ? -0.3 : 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionSpec {
  const _ActionSpec({
    required this.icon,
    required this.color,
    required this.softColor,
  });

  final IconData icon;
  final Color color;
  final Color softColor;
}

_ActionSpec _specFor(UmaActionType type, AppTokens t) {
  return switch (type) {
    UmaActionType.buyGold => _ActionSpec(
        icon: Icons.savings_outlined,
        color: t.gold,
        softColor: t.gold.withValues(alpha: 0.13),
      ),
    UmaActionType.payCreditCard => _ActionSpec(
        icon: Icons.credit_card_outlined,
        color: t.brand,
        softColor: t.brand.withValues(alpha: 0.12),
      ),
    UmaActionType.moveToSavings => _ActionSpec(
        icon: Icons.account_balance_wallet_outlined,
        color: t.green,
        softColor: t.green.withValues(alpha: 0.12),
      ),
  };
}

String? _schemeFor(String bank) {
  final lower = bank.toLowerCase();
  // Bilinen TR banka deep-link semalari. Cogu yalnizca telefonda kuruluyken
  // calisir; aksi halde canLaunchUrl false doner ve UI snackbar gosterir.
  if (lower.contains('garanti')) return 'garantibbva://';
  if (lower.contains('akbank')) return 'akbankmobile://';
  if (lower.contains('yapı') || lower.contains('yapi')) {
    return 'yapikrediorg://';
  }
  if (lower.contains('iş ban') || lower.contains('isban')) {
    return 'isbankisweb://';
  }
  if (lower.contains('ziraat')) return 'ziraatbankasi://';
  if (lower.contains('denizbank')) return 'denizbankmobil://';
  return null;
}
