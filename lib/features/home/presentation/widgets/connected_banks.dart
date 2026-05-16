import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/bank.dart';

class ConnectedBanks extends StatelessWidget {
  const ConnectedBanks({
    required this.banks,
    this.onBankTap,
    this.onBankLongPress,
    this.onAddBankTap,
    super.key,
  });

  final List<Bank> banks;
  final ValueChanged<Bank>? onBankTap;
  final ValueChanged<Bank>? onBankLongPress;
  final VoidCallback? onAddBankTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 124,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: banks.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          if (i == banks.length) {
            return _AddBankCard(onTap: onAddBankTap);
          }
          final bank = banks[i];
          return _BankCard(
            bank: bank,
            onTap: onBankTap == null ? null : () => onBankTap!(bank),
            onLongPress: onBankLongPress == null
                ? null
                : () => onBankLongPress!(bank),
          );
        },
      ),
    );
  }
}

class _BankCard extends StatelessWidget {
  const _BankCard({required this.bank, this.onTap, this.onLongPress});

  final Bank bank;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: t.card,
      borderRadius: BorderRadius.circular(t.vibe.radius - 2),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(t.vibe.radius - 2),
        child: Container(
          width: 168,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
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
        ),
      ),
    );
  }
}

class _AddBankCard extends StatelessWidget {
  const _AddBankCard({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
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
              Text(
                l10n.connectBank,
                style: TextStyle(fontSize: 12, color: t.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
