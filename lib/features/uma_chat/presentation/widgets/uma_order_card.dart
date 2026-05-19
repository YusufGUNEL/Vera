import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/uma_message.dart';

class UmaOrderCard extends StatelessWidget {
  const UmaOrderCard({
    required this.card,
    this.onForward,
    this.onDismiss,
    super.key,
  });

  final OrderCard card;
  final VoidCallback? onForward;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final isDone = card.status != OrderStatus.review;
    final statusLabel = switch (card.status) {
      OrderStatus.review => 'Banka uygulamasında aç',
      OrderStatus.forwarded => 'Yönlendirildi',
      OrderStatus.dismissed => 'İncelemede tutuldu',
    };

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: t.umaSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.auto_awesome, color: t.uma, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  card.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: t.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _OrderRow(label: 'Tutar', value: fmtTL(card.amount)),
          const SizedBox(height: 8),
          _OrderRow(label: 'Akış', value: '${card.from} → ${card.to}'),
          const SizedBox(height: 8),
          _OrderRow(label: 'Banka', value: card.bankApp),
          if (card.detailLabel != null && card.detailValue != null) ...[
            const SizedBox(height: 8),
            _OrderRow(label: card.detailLabel!, value: card.detailValue!),
          ],
          if (card.note != null && card.note!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              card.note!,
              style: TextStyle(
                fontSize: 12,
                color: t.ink2,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton(
                onPressed: isDone ? null : onForward,
                style: FilledButton.styleFrom(
                  backgroundColor: card.status == OrderStatus.forwarded
                      ? t.green
                      : t.brand,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  statusLabel,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!isDone) ...[
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: onDismiss,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: t.ink2,
                    side: BorderSide(color: t.line),
                  ),
                  child: const Text(
                    'Şimdilik beklet',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class _OrderRow extends StatelessWidget {
  const _OrderRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: t.muted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: t.ink2,
            ),
          ),
        ),
      ],
    );
  }
}
