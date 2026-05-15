import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/upcoming_bill.dart';

class UpcomingBillsStrip extends StatelessWidget {
  const UpcomingBillsStrip({
    required this.bills,
    this.onBillTap,
    super.key,
  });

  final List<UpcomingBill> bills;
  final ValueChanged<UpcomingBill>? onBillTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 116,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: bills.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => _BillCard(
          bill: bills[i],
          onTap: onBillTap == null ? null : () => onBillTap!(bills[i]),
        ),
      ),
    );
  }
}

class _BillCard extends StatelessWidget {
  const _BillCard({required this.bill, this.onTap});

  final UpcomingBill bill;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final isUrgent = bill.daysUntilDue <= 3;
    return Material(
      color: t.card,
      borderRadius: BorderRadius.circular(t.vibe.radius - 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(t.vibe.radius - 2),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(t.vibe.radius - 2),
            border: Border.all(
              color: isUrgent ? t.red.withValues(alpha: 0.4) : t.line,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: bill.accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Icon(bill.icon, color: bill.accent, size: 16),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isUrgent
                          ? t.red.withValues(alpha: 0.10)
                          : t.bgSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      l10n.daysLeft(bill.daysUntilDue),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isUrgent ? t.red : t.muted,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                bill.name,
                style: TextStyle(fontSize: 12, color: t.muted),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                fmtTL(bill.amount),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
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
