import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_locale.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/palette.dart';
import '../../../core/theme/tweaks_controller.dart';
import '../../receipt_scan/presentation/receipt_scan_sheet.dart';
import '../../statement_import/presentation/statement_import_sheet.dart';
import '../state/onboarding_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;

  Future<void> _finish() async {
    await ref.read(onboardingControllerProvider.notifier).complete();
    if (!mounted) return;
    context.go(Routes.home);
  }

  void _next() {
    if (_step < 2) {
      setState(() => _step += 1);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step -= 1);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (_step > 0)
                    TextButton.icon(
                      onPressed: _back,
                      icon: Icon(Icons.chevron_left, color: t.muted, size: 20),
                      label: Text(
                        l10n.onbBack,
                        style: TextStyle(color: t.muted, fontSize: 13),
                      ),
                    ),
                  const Spacer(),
                  _StepBadge(
                    current: _step + 1,
                    total: 3,
                  ),
                  if (_step < 2) ...[
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: _finish,
                      child: Text(
                        l10n.onbSkip,
                        style: TextStyle(color: t.muted, fontSize: 13),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: i <= _step
                              ? t.uma
                              : t.uma.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    if (i != 2) const SizedBox(width: 6),
                  ],
                ],
              ),
              const SizedBox(height: 28),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _stepWidget(_step),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _next,
                  style: FilledButton.styleFrom(
                    backgroundColor: t.brand,
                    foregroundColor: t.brandFG,
                  ),
                  child: Text(
                    _step == 2 ? l10n.onbStart : l10n.onbContinue,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (_step == 2) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _finish,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: t.ink2,
                      side: BorderSide(color: t.line),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(l10n.onbContinueWithoutImport),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepWidget(int step) {
    switch (step) {
      case 0:
        return const _LanguageStep(key: ValueKey('lang'));
      case 1:
        return const _ThemeStep(key: ValueKey('theme'));
      default:
        return const _ImportStep(key: ValueKey('import'));
    }
  }
}

class _LanguageStep extends ConsumerWidget {
  const _LanguageStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l10n = context.l10n;
    final current = ref.watch(localeControllerProvider);
    final ctrl = ref.read(localeControllerProvider.notifier);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onbStep1Title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: t.ink,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onbStep1Subtitle,
            style: TextStyle(fontSize: 14, color: t.muted, height: 1.45),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final locale in AppLocale.values)
                _Chip(
                  label: '${locale.short}  ${locale.label}',
                  selected: current == locale,
                  onTap: () => ctrl.setLocale(locale),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeStep extends ConsumerWidget {
  const _ThemeStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l10n = context.l10n;
    final tweaks = ref.watch(tweaksControllerProvider);
    final ctrl = ref.read(tweaksControllerProvider.notifier);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onbStep2Title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: t.ink,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onbStep2Subtitle,
            style: TextStyle(fontSize: 14, color: t.muted, height: 1.45),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              for (final p in Palette.all)
                GestureDetector(
                  onTap: () => ctrl.setPalette(p.id),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: p.id == tweaks.paletteId
                            ? t.uma
                            : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: Container(
                      width: 56,
                      height: 56,
                      clipBehavior: Clip.hardEdge,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Row(
                        children: [
                          Expanded(child: Container(color: p.brand)),
                          Expanded(child: Container(color: p.uma)),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _Chip(
                  label: l10n.moodLight,
                  selected: tweaks.mood == MoodId.light,
                  onTap: () => ctrl.setMood(MoodId.light),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Chip(
                  label: l10n.moodDark,
                  selected: tweaks.mood == MoodId.dark,
                  onTap: () => ctrl.setMood(MoodId.dark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _PreviewCard(
            title: l10n.onbPalettePreviewTitle,
            body: l10n.onbPalettePreviewBody,
          ),
        ],
      ),
    );
  }
}

class _ImportStep extends StatelessWidget {
  const _ImportStep({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onbStep3Title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: t.ink,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onbStep3Subtitle,
            style: TextStyle(fontSize: 14, color: t.muted, height: 1.45),
          ),
          const SizedBox(height: 22),
          _ActionTile(
            icon: Icons.upload_file_outlined,
            label: l10n.onbImportNow,
            color: t.brand,
            onTap: () => showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              barrierColor: Colors.black.withValues(alpha: 0.45),
              builder: (_) => const StatementImportSheet(),
            ),
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.document_scanner_outlined,
            label: l10n.onbScanNow,
            color: t.uma,
            onTap: () => showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              barrierColor: Colors.black.withValues(alpha: 0.45),
              builder: (_) => const ReceiptScanSheet(),
            ),
          ),
          const SizedBox(height: 14),
          _PreviewCard(
            title: l10n.onbBlankCanvasTitle,
            body: l10n.onbBlankCanvasBody,
            icon: Icons.landscape_outlined,
          ),
        ],
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge({
    required this.current,
    required this.total,
  });

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: t.bgSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: t.line),
      ),
      child: Text(
        '$current / $total',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: t.ink2,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.title,
    required this.body,
    this.icon = Icons.auto_awesome,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: const Alignment(-1, -1),
          end: const Alignment(1, 1),
          colors: [
            t.brand.withValues(alpha: 0.08),
            t.uma.withValues(alpha: 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: t.card,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: t.uma, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: t.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 12,
                    color: t.ink2,
                    height: 1.45,
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

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: selected ? t.uma : t.bgSoft,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : t.ink2,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
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
      color: t.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: t.line),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: t.ink,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: t.muted, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
