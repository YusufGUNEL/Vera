import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/bank.dart';

class ConnectedBanks extends StatelessWidget {
  const ConnectedBanks({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 124,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: kBanks.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          if (i == kBanks.length) {
            return _AddBankCard();
          }
          return _BankCard(bank: kBanks[i]);
        },
      ),
    );
  }
}

class _BankCard extends StatelessWidget {
  const _BankCard({required this.bank});

  final Bank bank;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: 168,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(t.vibe.radius - 2),
        border: Border.all(color: t.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: bank.color,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  bank.shortCode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Text(
                bank.last4,
                style: TextStyle(
                  fontSize: 11,
                  color: t.muted,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(bank.name, style: TextStyle(fontSize: 12, color: t.muted)),
          const SizedBox(height: 2),
          Text(
            fmtTL(bank.balance),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: t.ink,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddBankCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: 168,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: t.line,
          width: 1.5,
          style: BorderStyle.solid,
        ),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, color: t.muted, size: 20),
          const SizedBox(height: 6),
          Text('Connect bank',
              style: TextStyle(fontSize: 12, color: t.muted)),
        ],
      ),
    );
  }
}
