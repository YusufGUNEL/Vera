import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/pill.dart';
import '../../domain/uma_message.dart';

class UmaOrderCard extends StatelessWidget {
  const UmaOrderCard({
    required this.card,
    required this.onConfirm,
    required this.onCancel,
    super.key,
  });

  final OrderCard card;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.card,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 4)),
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
                  color: t.gold.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.savings_outlined, color: t.gold, size: 15),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Buy ${card.grams}g of Gold',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: t.ink,
                    )),
              ),
              switch (card.status) {
                OrderStatus.confirmed => Pill(label: 'CONFIRMED', color: t.green),
                OrderStatus.cancelled => Pill(label: 'CANCELLED', color: t.muted),
                OrderStatus.review => Pill(label: 'REVIEW', color: t.uma),
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
                _Row(k: 'From', v: card.from),
                _Row(k: 'To', v: card.to),
                _Row(k: 'Rate', v: '${fmtTL(card.ratePerGram)}/g'),
                _Row(k: 'Amount', v: fmtTL(card.amount), bold: true),
              ],
            ),
          ),
          if (card.status == OrderStatus.review) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: t.line),
                      foregroundColor: t.ink2,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: t.brand,
                      foregroundColor: t.brandFG,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(t.vibe.radiusSmall),
                      ),
                    ),
                    child: const Text('Confirm',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
          if (card.status == OrderStatus.confirmed)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'Receipt sent to your email.',
                style: TextStyle(fontSize: 12, color: t.muted),
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
          Text(v,
              style: TextStyle(
                color: t.ink,
                fontSize: 13,
                fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: bold ? -0.3 : 0,
              )),
        ],
      ),
    );
  }
}
