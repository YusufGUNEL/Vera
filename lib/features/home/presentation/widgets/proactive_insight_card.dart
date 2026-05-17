import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../subscriptions/domain/subscription_status.dart';
import '../../../subscriptions/state/subscriptions_controller.dart';
import '../../../uma_chat/presentation/open_uma.dart';
import '../../state/upcoming_bills_controller.dart';

/// "Vera fark etti" sized proactive card. Selects the strongest signal from
/// the current state and points the user to the right module:
///  - upcoming bill <= 3 days  → /security or /home action
///  - subscription with price increase → /plans
///  - unused subscription → /plans
/// Renders nothing when no signal is strong enough.
class ProactiveInsightCard extends ConsumerWidget {
  const ProactiveInsightCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l10n = context.l10n;
    final subs = ref.watch(subscriptionsControllerProvider).items;
    final bills = ref.watch(upcomingBillsControllerProvider);

    final urgentBill = bills
        .where((b) => b.daysUntilDue <= 3)
        .toList()
      ..sort((a, b) => a.daysUntilDue.compareTo(b.daysUntilDue));

    final priceIncreased = subs
        .where((s) => s.status == SubscriptionStatus.priceIncreased)
        .toList()
      ..sort((a, b) => b.priceDelta.compareTo(a.priceDelta));

    final unused = subs
        .where((s) => s.status == SubscriptionStatus.unused)
        .toList();

    String title;
    String body;
    String cta;
    IconData icon;
    Color accent;
    VoidCallback onTap;

    if (urgentBill.isNotEmpty) {
      final bill = urgentBill.first;
      title = l10n.proactiveBillTitle(bill.name);
      body = l10n.proactiveBillBody(fmtTL(bill.amount), bill.daysUntilDue);
      cta = l10n.proactiveBillCta;
      icon = bill.icon;
      accent = t.red;
      onTap = () => openUma(
            context,
            ref,
            prompt: l10n.proactiveBillPrompt(bill.name),
          );
    } else if (priceIncreased.isNotEmpty) {
      final sub = priceIncreased.first;
      title = l10n.proactivePriceTitle(sub.name);
      body = l10n.proactivePriceBody(fmtTL(sub.priceDelta));
      cta = l10n.proactivePriceCta;
      icon = Icons.trending_up;
      accent = t.gold;
      onTap = () => Navigator.of(context).pushNamed(Routes.subscriptions);
    } else if (unused.isNotEmpty) {
      final sub = unused.first;
      title = l10n.proactiveUnusedTitle(sub.name);
      body = l10n.proactiveUnusedBody(sub.lastUsedLabel);
      cta = l10n.proactiveUnusedCta;
      icon = Icons.subscriptions_outlined;
      accent = t.uma;
      onTap = () => Navigator.of(context).pushNamed(Routes.subscriptions);
    } else {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(t.vibe.radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(t.vibe.radius),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(t.vibe.radius),
              gradient: LinearGradient(
                begin: const Alignment(-1, -1),
                end: const Alignment(1, 1),
                colors: [
                  accent.withValues(alpha: 0.10),
                  t.uma.withValues(alpha: 0.10),
                ],
              ),
              border: Border.all(color: accent.withValues(alpha: 0.24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Icon(icon, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: t.uma,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.proactiveBadge,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: t.ink,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 12,
                    color: t.ink2,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      cta,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 14, color: accent),
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
