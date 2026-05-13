import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/vera_card.dart';
import '../../data/transaction.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: VeraCard(
        child: Column(
          children: [
            for (var i = 0; i < kTransactions.length; i++) ...[
              if (i != 0) Divider(height: 1, color: t.line),
              _TxnTile(txn: kTransactions[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _TxnTile extends StatelessWidget {
  const _TxnTile({required this.txn});

  final Txn txn;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: txn.color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(txn.icon, color: txn.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    color: t.ink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '${txn.category} · ${txn.when}',
                  style: TextStyle(fontSize: 12, color: t.muted),
                ),
              ],
            ),
          ),
          Text(
            '${txn.isCredit ? '+' : '-'}${fmtTL(txn.amount.abs())}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: txn.isCredit ? t.green : t.ink,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
