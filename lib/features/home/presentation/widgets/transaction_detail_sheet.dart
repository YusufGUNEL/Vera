import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../uma_chat/presentation/open_uma.dart';
import '../../data/transaction.dart';

class TransactionDetailSheet extends ConsumerWidget {
  const TransactionDetailSheet({required this.txn, super.key});

  final Txn txn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l10n = context.l10n;
    final amountColor = txn.isCredit ? t.green : t.ink;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24, top: 8),
        decoration: BoxDecoration(
          color: t.bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
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
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: txn.color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Icon(txn.icon, color: txn.color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            txn.name,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: t.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            txn.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: t.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      fmtSignedTL(
                        txn.isCredit ? txn.amount.abs() : -txn.amount.abs(),
                      ),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: amountColor,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Row(label: l10n.txnDetailWhen, value: txn.when),
                const SizedBox(height: 10),
                _Row(label: l10n.txnDetailCategory, value: txn.category),
                const SizedBox(height: 10),
                _Row(
                  label: l10n.txnDetailDirection,
                  value: txn.isCredit
                      ? l10n.txnDetailIncoming
                      : l10n.txnDetailOutgoing,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: t.ink2,
                          side: BorderSide(color: t.line),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(l10n.close),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          openUma(
                            context,
                            ref,
                            prompt: l10n.txnDetailAskPrompt(
                              txn.name,
                              fmtTL(txn.amount.abs()),
                            ),
                          );
                        },
                        icon: const Icon(Icons.auto_awesome, size: 16),
                        label: Text(l10n.askUma),
                        style: FilledButton.styleFrom(
                          backgroundColor: t.uma,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
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

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: t.muted,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: t.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
