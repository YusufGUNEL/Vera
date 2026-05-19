import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/drag_drop_zone.dart';
import '../../../shared/widgets/pill.dart';
import '../../home/data/firebase_import_artifacts_service.dart';
import '../../home/data/imported_transactions_store.dart';
import '../../home/state/home_controller.dart';
import '../domain/parsed_receipt.dart';
import '../state/receipt_controller.dart';

class ReceiptScanSheet extends ConsumerStatefulWidget {
  const ReceiptScanSheet({super.key});

  @override
  ConsumerState<ReceiptScanSheet> createState() => _ReceiptScanSheetState();
}

class _ReceiptScanSheetState extends ConsumerState<ReceiptScanSheet> {
  final _picker = ImagePicker();

  Future<void> _pick(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      final mime = picked.mimeType ?? _guessMime(picked.name);
      if (!mounted) return;
      await ref.read(receiptControllerProvider.notifier).scan(
            bytes: bytes,
            mimeType: mime,
            fileName: picked.name,
          );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  String _guessMime(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final state = ref.watch(receiptControllerProvider);
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                child: SingleChildScrollView(
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
                              color: t.uma,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.document_scanner_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.scanReceiptTitle,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: t.ink,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.scanReceiptSubtitle,
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
                      if (state.status == ReceiptScanStatus.idle)
                        _pickerButtons(t, l10n),
                      if (state.status == ReceiptScanStatus.scanning)
                        _scanningView(t, l10n),
                      if (state.status == ReceiptScanStatus.ready &&
                          state.receipt != null)
                        _resultView(t, l10n, state.receipt!),
                      if (state.status == ReceiptScanStatus.error)
                        _errorView(t, l10n, state.error ?? ''),
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

  Widget _pickerButtons(AppTokens t, AppStrings l10n) {
    return DragDropZone(
      onFileDropped: (bytes, filename) {
        String mimeType = 'application/octet-stream';
        final ext = filename.split('.').last.toLowerCase();
        if (ext == 'pdf') mimeType = 'application/pdf';
        if (ext == 'png') mimeType = 'image/png';
        if (ext == 'jpg' || ext == 'jpeg') mimeType = 'image/jpeg';
        
        ref.read(receiptControllerProvider.notifier).scan(
              bytes: bytes,
              mimeType: mimeType,
              fileName: filename,
            );
      },
      child: Column(
        children: [
        _BigAction(
          icon: Icons.photo_camera_outlined,
          label: l10n.takePhoto,
          color: t.brand,
          onTap: () => _pick(ImageSource.camera),
        ),
        const SizedBox(height: 10),
        _BigAction(
          icon: Icons.photo_library_outlined,
          label: l10n.pickFromGallery,
          color: t.uma,
          onTap: () => _pick(ImageSource.gallery),
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
                  l10n.scanHint,
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

  Widget _scanningView(AppTokens t, AppStrings l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          CircularProgressIndicator(color: t.uma),
          const SizedBox(height: 14),
          Text(
            l10n.scanReading,
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

  Widget _resultView(AppTokens t, AppStrings l10n, ParsedReceipt r) {
    final scanState = ref.watch(receiptControllerProvider);
    final isFallback = r.source == ReceiptSource.fallback;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                r.merchant ?? '—',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: t.ink,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            Pill(
              label: r.source == ReceiptSource.ai
                  ? l10n.parsedByAi
                  : l10n.parsedFallback,
              color: r.source == ReceiptSource.ai ? t.uma : t.muted,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            if (r.category != null) ...[
              Pill(label: r.category!, color: t.brand),
              const SizedBox(width: 6),
            ],
            if (r.date != null)
              Text(
                r.date!,
                style: TextStyle(color: t.muted, fontSize: 12),
              ),
          ],
        ),
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
                    l10n.scanFallbackWarning,
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
        if (r.hasTotal)
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
                    l10n.scanTotalLabel,
                    style: TextStyle(color: t.muted, fontSize: 12),
                  ),
                ),
                Text(
                  fmtTL(r.total!),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: t.ink,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),
        if (r.lines.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: t.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: t.line),
            ),
            child: Column(
              children: [
                for (var i = 0; i < r.lines.length; i++) ...[
                  if (i != 0) Divider(height: 1, color: t.line),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            r.lines[i].name,
                            style: TextStyle(color: t.ink2, fontSize: 13),
                          ),
                        ),
                        Text(
                          fmtTL(r.lines[i].amount),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: t.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                    ref.read(receiptControllerProvider.notifier).reset(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: t.ink2,
                  side: BorderSide(color: t.line),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(l10n.scanAgain),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: isFallback
                    ? null
                    : () async {
                        final txn = r.toTxn(l10n);
                        final messenger = ScaffoldMessenger.of(context);
                        if (txn == null) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(l10n.scanNoTotal),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        await ref
                            .read(homeControllerProvider.notifier)
                            .addImportedTransactions([txn]);
                        final artifacts =
                            ref.read(firebaseImportArtifactsServiceProvider);
                        if (artifacts.isEnabled &&
                            scanState.sourceBytes != null &&
                            scanState.mimeType != null) {
                          try {
                            await artifacts.uploadReceipt(
                              fileName: scanState.fileName ?? 'receipt.jpg',
                              bytes: scanState.sourceBytes!,
                              mimeType: scanState.mimeType!,
                              receipt: r,
                              transactions: [txn],
                            );
                          } catch (_) {
                            // Local import already succeeded; cloud backup is best-effort.
                          }
                        }
                        if (!mounted) return;
                        Navigator.of(context).pop();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(l10n.addedToTransactions),
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
                  isFallback ? l10n.scanFallbackAction : l10n.addToTransactions,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _errorView(AppTokens t, AppStrings l10n, String error) {
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
          onPressed: () => ref.read(receiptControllerProvider.notifier).reset(),
          child: Text(l10n.scanAgain),
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

class _BigAction extends StatelessWidget {
  const _BigAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(t.vibe.radius - 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(t.vibe.radius - 2),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
