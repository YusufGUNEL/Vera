import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../security/state/security_controller.dart';
import '../../../subscriptions/domain/subscription_status.dart';
import '../../../subscriptions/state/subscriptions_controller.dart';
import '../../data/upcoming_bill.dart';

class _Notice {
  const _Notice({
    required this.icon,
    required this.title,
    required this.body,
    required this.accent,
    required this.when,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color accent;
  final String when;
}

class NotificationCenterSheet extends ConsumerWidget {
  const NotificationCenterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l10n = context.l10n;
    final security = ref.watch(securityControllerProvider);
    final subs = ref.watch(subscriptionsControllerProvider);

    final notices = <_Notice>[
      for (final check
          in security.checks.where((c) => c.blocked).take(3))
        _Notice(
          icon: Icons.shield_outlined,
          title: check.name,
          body: check.reason ?? l10n.notifBlockedDefault,
          accent: t.red,
          when: check.when,
        ),
      for (final sub
          in subs.items.where((s) => s.status == SubscriptionStatus.priceIncreased).take(3))
        _Notice(
          icon: Icons.trending_up,
          title: l10n.notifPriceIncreaseTitle(sub.name),
          body: l10n.notifPriceIncreaseBody(
              fmtTL(sub.priceDelta), fmtTL(sub.monthlyPrice)),
          accent: t.gold,
          when: sub.renewalLabel,
        ),
      for (final sub in subs.items
          .where((s) => s.status == SubscriptionStatus.unused)
          .take(2))
        _Notice(
          icon: Icons.subscriptions_outlined,
          title: l10n.notifUnusedTitle(sub.name),
          body: l10n.notifUnusedBody(sub.lastUsedLabel),
          accent: t.muted,
          when: sub.renewalLabel,
        ),
      for (final bill in kUpcomingBills.where((b) => b.daysUntilDue <= 5))
        _Notice(
          icon: bill.icon,
          title: l10n.notifBillTitle(bill.name),
          body: l10n.notifBillBody(fmtTL(bill.amount)),
          accent: bill.daysUntilDue <= 3 ? t.red : bill.accent,
          when: l10n.daysLeft(bill.daysUntilDue),
        ),
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: t.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 6),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: t.line,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: t.uma.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.notifications_outlined,
                        color: t.uma, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.notifTitle,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: t.ink,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.notifSubtitle(notices.length),
                          style: TextStyle(fontSize: 12, color: t.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: notices.isEmpty
                  ? _EmptyState()
                  : ListView.separated(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
                      itemCount: notices.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _NoticeTile(notice: notices[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 40, color: t.green),
            const SizedBox(height: 10),
            Text(
              l10n.notifEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: t.muted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoticeTile extends StatelessWidget {
  const _NoticeTile({required this.notice});

  final _Notice notice;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(t.vibe.radius - 2),
        border: Border.all(color: t.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: notice.accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(notice.icon, color: notice.accent, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notice.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: t.ink,
                        ),
                      ),
                    ),
                    Text(
                      notice.when,
                      style: TextStyle(fontSize: 11, color: t.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notice.body,
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
    );
  }
}
