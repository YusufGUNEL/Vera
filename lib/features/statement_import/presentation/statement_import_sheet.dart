import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/pill.dart';
import '../../home/data/imported_transactions_store.dart';
import '../../home/state/home_controller.dart';
import '../domain/parsed_statement.dart';
import '../state/statement_controller.dart';

class StatementImportSheet extends ConsumerWidget {
  const StatementImportSheet({super.key});

  Future<void> _pickFile(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg', 'webp'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final picked = result.files.first;
      final bytes = picked.bytes;
      if (bytes == null) return;
      final mime = _mimeForExtension(picked.extension);
      if (!context.mounted) return;
      await ref
          .read(statementControllerProvider.notifier)
          .parse(bytes: bytes, mimeType: mime);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  String _mimeForExtension(String? ext) {
    switch (ext?.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l10n = context.l10n;
    final state = ref.watch(statementControllerProvider);
    final mq = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: t.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: mq.size.height * 0.85),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: t.line,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: t.brand,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.upload_file_outlined,
                          color: t.brandFG,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.statementImportTitle,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: t.ink,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.statementImportSubtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: t.muted,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (state.status == StatementStatus.idle)
                    _picker(context, ref, t, l10n),
                  if (state.status == StatementStatus.parsing)
                    _parsing(t, l10n),
                  if (state.status == StatementStatus.ready &&
                      state.statement != null)
                    _result(context, ref, t, l10n, state.statement!),
                  if (state.status == StatementStatus.error)
                    _error(context, ref, t, l10n, state.error ?? ''),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _picker(
      BuildContext context, WidgetRef ref, AppTokens t, AppStrings l10n) {
    return Column(
      children: [
        Material(
          color: t.brand,
          borderRadius: BorderRadius.circular(t.vibe.radius - 2),
          child: InkWell(
            onTap: () => _pickFile(context, ref),
            borderRadius: BorderRadius.circular(t.vibe.radius - 2),
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  Icon(Icons.attach_file, color: t.brandFG),
                  const SizedBox(width: 12),
                  Text(
                    l10n.pickStatementFile,
                    style: TextStyle(
                      color: t.brandFG,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: t.umaSoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: t.uma.withValues(alpha: 0.16)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_outline, color: t.uma, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.statementImportHint,
                  style: TextStyle(
                    color: t.ink2,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _parsing(AppTokens t, AppStrings l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          CircularProgressIndicator(color: t.brand),
          const SizedBox(height: 14),
          Text(
            l10n.statementParsing,
            style: TextStyle(
              color: t.ink2,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _result(BuildContext context, WidgetRef ref, AppTokens t,
      AppStrings l10n, ParsedStatement s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                s.bank ?? '—',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: t.ink,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            Pill(
              label: s.source == StatementSource.ai
                  ? l10n.parsedByAi
                  : l10n.parsedFallback,
              color: s.source == StatementSource.ai ? t.uma : t.muted,
            ),
          ],
        ),
        if (s.accountLast4 != null || s.period != null) ...[
          const SizedBox(height: 4),
          Text(
            [
              if (s.accountLast4 != null) '••${s.accountLast4}',
              if (s.period != null) s.period!,
            ].join(' · '),
            style: TextStyle(fontSize: 12, color: t.muted),
          ),
        ],
        const SizedBox(height: 14),
        if (s.closingBalance != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t.bgSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.closingBalance,
                    style: TextStyle(color: t.muted, fontSize: 12),
                  ),
                ),
                Text(
                  fmtTL(s.closingBalance!),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: t.ink,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),
        if (s.transactions.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            l10n.detectedTransactions(s.transactions.length),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: t.muted,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: t.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: t.line),
            ),
            child: Column(
              children: [
                for (var i = 0; i < s.transactions.length; i++) ...[
                  if (i != 0) Divider(height: 1, color: t.line),
                  _TxnRow(txn: s.transactions[i]),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () =>
                    ref.read(statementControllerProvider.notifier).reset(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: t.ink2,
                  side: BorderSide(color: t.line),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(l10n.statementImportAgain),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final txns = s.toTxns();
                  if (txns.isEmpty) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(l10n.statementNoTransactions),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  await ref
                      .read(homeControllerProvider.notifier)
                      .addImportedTransactions(txns);
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(l10n.statementImported),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: t.brand,
                  foregroundColor: t.brandFG,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(l10n.importToVera),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _error(BuildContext context, WidgetRef ref, AppTokens t,
      AppStrings l10n, String error) {
    return Column(
      children: [
        Icon(Icons.error_outline, color: t.red, size: 36),
        const SizedBox(height: 10),
        Text(
          error,
          textAlign: TextAlign.center,
          style: TextStyle(color: t.ink2, fontSize: 13),
        ),
        const SizedBox(height: 14),
        OutlinedButton(
          onPressed: () =>
              ref.read(statementControllerProvider.notifier).reset(),
          child: Text(l10n.statementImportAgain),
        ),
      ],
    );
  }
}

class _TxnRow extends StatelessWidget {
  const _TxnRow({required this.txn});

  final ParsedStatementTxn txn;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Text(
              txn.date,
              style: TextStyle(
                color: t.muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.description,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: t.ink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (txn.category != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    txn.category!,
                    style: TextStyle(fontSize: 11, color: t.muted),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${txn.isCredit ? '+' : ''}${fmtTL(txn.amount)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: txn.isCredit ? t.green : t.ink,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
