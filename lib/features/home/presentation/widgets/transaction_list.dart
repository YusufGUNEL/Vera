import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/vera_card.dart';
import '../../data/transaction.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({
    required this.transactions,
    this.onTap,
    this.onAddManual,
    this.onScan,
    this.onImport,
    super.key,
  });

  final List<Txn> transactions;
  final ValueChanged<Txn>? onTap;
  final VoidCallback? onAddManual;
  final VoidCallback? onScan;
  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: _EmptyTransactionsCard(
          onAddManual: onAddManual,
          onScan: onScan,
          onImport: onImport,
        ),
      );
    }
    final groups = _groupTransactions(transactions);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: VeraCard(
        child: Column(
          children: [
            for (var i = 0; i < groups.length; i++) ...[
              if (i != 0) const SizedBox(height: 8),
              _TransactionGroup(
                group: groups[i],
                isFirst: i == 0,
                onTap: onTap,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyTransactionsCard extends StatelessWidget {
  const _EmptyTransactionsCard({
    this.onAddManual,
    this.onScan,
    this.onImport,
  });

  final VoidCallback? onAddManual;
  final VoidCallback? onScan;
  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    return VeraCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: t.uma.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.receipt_long_outlined,
                    color: t.uma, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.noTransactionsTitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: t.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.noTransactionsBody,
                      style: TextStyle(fontSize: 12, color: t.muted, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (onAddManual != null)
                Expanded(
                  child: _EmptyAction(
                    icon: Icons.add,
                    label: l10n.actionManual,
                    onTap: onAddManual!,
                  ),
                ),
              if (onScan != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _EmptyAction(
                    icon: Icons.qr_code_scanner_rounded,
                    label: l10n.scanReceipt,
                    onTap: onScan!,
                  ),
                ),
              ],
              if (onImport != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _EmptyAction(
                    icon: Icons.upload_file_rounded,
                    label: l10n.statementImport,
                    onTap: onImport!,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyAction extends StatelessWidget {
  const _EmptyAction({
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
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: t.brand, size: 18),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: t.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionGroup extends StatelessWidget {
  const _TransactionGroup({
    required this.group,
    required this.isFirst,
    this.onTap,
  });

  final _TxnGroup group;
  final bool isFirst;
  final ValueChanged<Txn>? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final spent = group.transactions
        .where((txn) => !txn.isCredit)
        .fold<double>(0, (sum, txn) => sum + txn.amount.abs());
    final income = group.transactions
        .where((txn) => txn.isCredit)
        .fold<double>(0, (sum, txn) => sum + txn.amount.abs());
    final net = income - spent;

    return Column(
      children: [
        if (!isFirst) Divider(height: 1, color: t.line),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  group.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: t.ink,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Text(
                l10n.itemsCount(group.transactions.length),
                style: TextStyle(fontSize: 12, color: t.muted),
              ),
              const SizedBox(width: 8),
              Text(
                net >= 0 ? '+${fmtTL(net)}' : '-${fmtTL(net.abs())}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: net >= 0 ? t.green : t.ink,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          child: Row(
            children: [
              _SummaryPill(
                label: '${l10n.spent} ${fmtTL(spent)}',
                color: t.ink2,
                background: t.bgSoft,
              ),
              const SizedBox(width: 8),
              _SummaryPill(
                label: '${l10n.incoming} ${fmtTL(income)}',
                color: t.green,
                background: t.green.withValues(alpha: 0.08),
              ),
            ],
          ),
        ),
        for (var i = 0; i < group.transactions.length; i++) ...[
          if (i != 0) Divider(height: 1, color: t.line),
          _TxnTile(
            txn: group.transactions[i],
            onTap: onTap == null ? null : () => onTap!(group.transactions[i]),
          ),
        ],
      ],
    );
  }
}

class _TxnTile extends StatelessWidget {
  const _TxnTile({required this.txn, this.onTap});

  final Txn txn;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: txn.color.withValues(alpha: 0.10),
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
                  '${txn.category} · ${_timeLabel(txn.when)}',
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
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _TxnGroup {
  const _TxnGroup({
    required this.label,
    required this.transactions,
  });

  final String label;
  final List<Txn> transactions;
}

List<_TxnGroup> _groupTransactions(List<Txn> transactions) {
  final ordered = <String, List<Txn>>{};
  for (final txn in transactions) {
    final key = _groupLabel(txn.when);
    ordered.putIfAbsent(key, () => []).add(txn);
  }

  return ordered.entries
      .map((entry) => _TxnGroup(label: entry.key, transactions: entry.value))
      .toList();
}

String _groupLabel(String rawWhen) {
  final normalized = rawWhen.split(',').first.trim();
  return normalized;
}

String _timeLabel(String rawWhen) {
  if (!rawWhen.contains(',')) return rawWhen;
  return rawWhen.split(',').skip(1).join(',').trim();
}
