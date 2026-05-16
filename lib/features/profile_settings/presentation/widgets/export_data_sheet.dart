import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../home/state/goals_controller.dart';
import '../../../home/state/home_controller.dart';
import '../../../subscriptions/state/subscriptions_controller.dart';

/// Builds a JSON snapshot of the user's local Vera state (transactions, banks,
/// goal, subscriptions) and shows it in a copyable sheet. Nothing leaves the
/// device unless the user copies and pastes it elsewhere themselves.
class ExportDataSheet extends ConsumerWidget {
  const ExportDataSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l10n = context.l10n;
    final home = ref.watch(homeControllerProvider);
    final goal = ref.watch(goalsControllerProvider);
    final subs = ref.watch(subscriptionsControllerProvider);

    final payload = {
      'exportedAt': DateTime.now().toIso8601String(),
      'banks': [for (final b in home.banks) b.toMap()],
      'transactions': [for (final tx in home.transactions) tx.toMap()],
      'goal': goal.toMap(),
      'subscriptions': [
        for (final s in subs.items)
          {
            'id': s.id,
            'name': s.name,
            'vendor': s.vendor,
            'category': s.category,
            'monthlyPrice': s.monthlyPrice,
            'previousPrice': s.previousPrice,
            'status': s.status.name,
          },
      ],
    };
    final encoded = const JsonEncoder.withIndent('  ').convert(payload);

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.95,
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
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.exportTitle,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: t.ink,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.exportSubtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: t.muted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: t.bgSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: t.line),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollCtrl,
                    child: SelectableText(
                      encoded,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: t.ink2,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: encoded));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.exportCopied),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_outlined, size: 16),
                  label: Text(l10n.exportCopy),
                  style: FilledButton.styleFrom(
                    backgroundColor: t.brand,
                    foregroundColor: t.brandFG,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
