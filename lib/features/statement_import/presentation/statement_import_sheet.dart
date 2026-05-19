import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/drag_drop_zone.dart';
import '../../../shared/widgets/pill.dart';
import '../../home/data/firebase_import_artifacts_service.dart';
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
      await ref.read(statementControllerProvider.notifier).parse(
            bytes: bytes,
            mimeType: mime,
            fileName: picked.name,
          );
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
    final responsive = context.responsive;

    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: responsive.sheetMaxWidth,
            maxHeight: mq.size.height * responsive.modalHeightFactor,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: t.bg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
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
                          IconButton(
                            icon: Icon(Icons.close_rounded, color: t.muted),
                            onPressed: () => Navigator.of(context).pop(),
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
        ),
      ),
    );
  }

  Widget _picker(
      BuildContext context, WidgetRef ref, AppTokens t, AppStrings l10n) {
    return DragDropZone(
      onFileDropped: (bytes, filename) {
        String mimeType = 'application/octet-stream';
        final ext = filename.split('.').last.toLowerCase();
        if (ext == 'pdf') mimeType = 'application/pdf';
        if (ext == 'png') mimeType = 'image/png';
        if (ext == 'jpg' || ext == 'jpeg') mimeType = 'image/jpeg';
        
        ref.read(statementControllerProvider.notifier).parse(
              bytes: bytes,
              mimeType: mimeType,
              fileName: filename,
            );
      },
      child: Column(
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
                  Expanded(
                    child: Text(
                      l10n.pickStatementFile,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: t.brandFG,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
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
            color: t.bgSoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: t.line),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: t.muted, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.statementImportHint,
                  style: TextStyle(
                    color: t.muted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          ),
        ],
      ),
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
    final importState = ref.watch(statementControllerProvider);
    final isFallback = s.source == StatementSource.fallback;
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
        if (isFallback) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: t.gold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: t.gold.withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: t.gold, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.statementFallbackWarning,
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
          const SizedBox(height: 10),
          _FallbackGuidanceCard(
            title: l10n.importFallbackNextTitle,
            body: l10n.importFallbackNextBody,
            primaryLabel: l10n.importFallbackManualEntry,
            secondaryLabel: l10n.importFallbackAskUma,
          ),
          const SizedBox(height: 14),
        ],
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
                onPressed: isFallback
                    ? null
                    : () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final txns = s.toTxns(l10n);
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
                        final artifacts =
                            ref.read(firebaseImportArtifactsServiceProvider);
                        if (artifacts.isEnabled &&
                            importState.sourceBytes != null &&
                            importState.mimeType != null) {
                          try {
                            await artifacts.uploadStatement(
                              fileName: importState.fileName ?? 'statement.pdf',
                              bytes: importState.sourceBytes!,
                              mimeType: importState.mimeType!,
                              statement: s,
                              transactions: txns,
                            );
                          } catch (_) {
                            // Local import already succeeded; cloud backup is best-effort.
                          }
                        }
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
                child: Text(
                  isFallback ? l10n.statementFallbackAction : l10n.importToVera,
                ),
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
        Icon(Icons.warning_amber_rounded, color: t.gold, size: 36),
        const SizedBox(height: 10),
        Text(
          l10n.statementFallbackWarning,
          textAlign: TextAlign.center,
          style: TextStyle(color: t.ink2, fontSize: 13, height: 1.4),
        ),
        if (kDebugMode && error.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: t.muted, fontSize: 11),
          ),
        ],
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

class _FallbackGuidanceCard extends StatelessWidget {
  const _FallbackGuidanceCard({
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.secondaryLabel,
  });

  final String title;
  final String body;
  final String primaryLabel;
  final String secondaryLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.bgSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: t.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(
              color: t.ink2,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FallbackChip(
                label: primaryLabel,
                icon: Icons.edit_outlined,
              ),
              _FallbackChip(
                label: secondaryLabel,
                icon: Icons.auto_awesome,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FallbackChip extends StatelessWidget {
  const _FallbackChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: t.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: t.uma),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: t.ink2,
            ),
          ),
        ],
      ),
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
            fmtSignedTL(
              txn.isCredit ? txn.amount : -txn.amount,
              showPlus: txn.isCredit,
            ),
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
