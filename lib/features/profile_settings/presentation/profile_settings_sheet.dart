import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/localization/app_locale.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/palette.dart';
import '../../../core/theme/tweaks_controller.dart';
import '../../../core/theme/vibe.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/auth_session.dart';
import '../../auth/state/auth_controller.dart';
import '../../home/data/bank.dart';
import '../../home/data/firebase_import_artifacts_service.dart';
import '../../home/state/goals_controller.dart';
import '../../home/state/home_controller.dart';
import '../../home/state/upcoming_bills_controller.dart';
import '../../uma_chat/data/uma_audit_store.dart';
import '../../uma_chat/data/uma_feedback_store.dart';
import '../domain/profile_state.dart';
import '../state/profile_controller.dart';
import 'widgets/account_info_sheet.dart';
import 'widgets/export_data_sheet.dart';

class ProfileSettingsSheet extends ConsumerWidget {
  const ProfileSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l10n = context.l10n;
    final tweaks = ref.watch(tweaksControllerProvider);
    final tweaksCtrl = ref.read(tweaksControllerProvider.notifier);
    final auth = ref.watch(authControllerProvider);
    final profile = ref.watch(profileControllerProvider);
    final profileCtrl = ref.read(profileControllerProvider.notifier);
    final currentLocale = ref.watch(localeControllerProvider);
    final localeCtrl = ref.read(localeControllerProvider.notifier);

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
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
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: t.isDark ? t.line : const Color(0xFFD9D4C8),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.chevron_left, color: t.ink, size: 26),
                  ),
                  Expanded(
                    child: Text(
                      l10n.profileAndSettings,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: t.ink,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: EdgeInsets.fromLTRB(
                  16,
                  4,
                  16,
                  120 + MediaQuery.of(context).padding.bottom,
                ),
                children: [
                  _ProfileCard(
                    initials: auth.initials,
                    name: auth.displayName ?? l10n.defaultUserName,
                    email: auth.email ?? 'demo@vera.app',
                    aiTone: profile.aiTone,
                  ),
                  const SizedBox(height: 28),
                  _SectionLabel(label: l10n.sectionLanguage),
                  const SizedBox(height: 10),
                  _LanguageSelector(
                    selected: currentLocale,
                    onChange: localeCtrl.setLocale,
                  ),
                  const SizedBox(height: 28),
                  _SectionLabel(label: l10n.sectionAppearance),
                  const SizedBox(height: 10),
                  _PaletteSelector(
                    selected: tweaks.paletteId,
                    onChange: tweaksCtrl.setPalette,
                  ),
                  const SizedBox(height: 12),
                  _SegmentedSelector<MoodId>(
                    label: l10n.mood,
                    selected: tweaks.mood,
                    options: [
                      (MoodId.light, l10n.moodLight),
                      (MoodId.dark, l10n.moodDark),
                    ],
                    onChange: tweaksCtrl.setMood,
                  ),
                  const SizedBox(height: 12),
                  _SegmentedSelector<VibeId>(
                    label: l10n.vibe,
                    selected: tweaks.vibeId,
                    options: [
                      (VibeId.calm, l10n.vibeCalm),
                      (VibeId.standard, l10n.vibeStandard),
                      (VibeId.bold, l10n.vibeBold),
                    ],
                    onChange: tweaksCtrl.setVibe,
                  ),
                  const SizedBox(height: 28),
                  _SectionLabel(label: l10n.sectionAi),
                  const SizedBox(height: 10),
                  _SegmentedSelector<AiTone>(
                    label: l10n.umaTone,
                    selected: profile.aiTone,
                    options: [
                      (AiTone.concise, l10n.toneConcise),
                      (AiTone.coach, l10n.toneCoach),
                      (AiTone.proactive, l10n.toneProactive),
                    ],
                    onChange: profileCtrl.setAiTone,
                  ),
                  const SizedBox(height: 28),
                  _SectionLabel(label: l10n.sectionNotifications),
                  const SizedBox(height: 10),
                  _ToggleTile(
                    icon: Icons.notifications_outlined,
                    label: l10n.profileSmartNotif,
                    subtitle: l10n.profileSmartNotifSub,
                    value: profile.notificationsEnabled,
                    onChanged: profileCtrl.setNotifications,
                  ),
                  const SizedBox(height: 10),
                  _ToggleTile(
                    icon: Icons.face_outlined,
                    label: l10n.profileFaceId,
                    subtitle: l10n.profileFaceIdSub,
                    value: profile.faceIdEnabled,
                    onChanged: profileCtrl.setFaceId,
                  ),
                  const SizedBox(height: 10),
                  _ToggleTile(
                    icon: Icons.shield_outlined,
                    label: l10n.profileFraudHigh,
                    subtitle: l10n.profileFraudHighSub,
                    value: profile.fraudAlertsEnabled,
                    onChanged: profileCtrl.setFraudAlerts,
                  ),
                  const SizedBox(height: 28),
                  _SectionLabel(label: l10n.sectionConnected),
                  const SizedBox(height: 10),
                  const _ConnectedInstitutionsCard(),
                  const SizedBox(height: 28),
                  _SectionLabel(label: l10n.sectionAccount),
                  const SizedBox(height: 10),
                  _AccountTile(
                    icon: Icons.person_outline,
                    label: l10n.accountTilePersonal,
                    value: auth.displayName ?? l10n.demoUser,
                    onTap: () => _openInfo(
                      context,
                      _personalInfo(l10n, auth),
                    ),
                  ),
                  _AccountTile(
                    icon: Icons.email_outlined,
                    label: l10n.accountTileEmail,
                    value: auth.email ?? 'demo@vera.app',
                    onTap: () => _openInfo(context, _emailInfo(l10n, auth)),
                  ),
                  _AccountTile(
                    icon: Icons.help_outline,
                    label: l10n.accountTileHelp,
                    value: l10n.accountTileHelpValue,
                    onTap: () => _openInfo(context, _helpInfo(l10n)),
                  ),
                  _AccountTile(
                    icon: Icons.download_outlined,
                    label: l10n.exportTile,
                    value: l10n.exportTileValue,
                    onTap: () => _openExport(context),
                  ),
                  _AccountTile(
                    icon: Icons.delete_outline,
                    label: l10n.deleteAccountTile,
                    value: auth.userId == 'demo-user' ||
                            auth.authMethod == 'demo vault'
                        ? l10n.deleteAccountDemoTileValue
                        : l10n.deleteAccountTileValue,
                    onTap: () => _confirmDeleteAccount(context, ref, auth),
                  ),
                  _AccountTile(
                    icon: Icons.restart_alt,
                    label: l10n.demoResetTile,
                    value: l10n.demoResetTileValue,
                    onTap: () => _confirmDemoReset(context, ref),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () async {
                        await ref
                            .read(authControllerProvider.notifier)
                            .signOut();
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: t.red,
                        side: BorderSide(color: t.red.withValues(alpha: 0.4)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        l10n.signOut,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () =>
                          _confirmDeleteAccount(context, ref, auth),
                      style: TextButton.styleFrom(
                        foregroundColor: t.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      child: Text(
                        l10n.deleteAccount,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: t.red,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: t.red.withValues(alpha: 0.5),
                          decorationThickness: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openInfo(BuildContext context, AccountInfoSheet sheet) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => sheet,
    );
  }

  void _openExport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => const ExportDataSheet(),
    );
  }

  Future<void> _confirmDemoReset(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final t = context.tokens;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.demoResetTitle),
        content: Text(l10n.demoResetBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.demoResetCancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: t.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.demoResetConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    await ref.read(homeControllerProvider.notifier).resetDemoState();
    await ref.read(upcomingBillsControllerProvider.notifier).clear();
    await ref.read(goalsControllerProvider.notifier).reset();
    await ref.read(umaFeedbackStoreProvider).clear();
    await ref.read(umaAuditStoreProvider).clear();
    await ref.read(firebaseImportArtifactsServiceProvider).clearAll();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.demoResetDone),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    WidgetRef ref,
    AuthSession auth,
  ) async {
    final l10n = context.l10n;
    final t = context.tokens;
    final isDemo =
        auth.userId == 'demo-user' || auth.authMethod == 'demo vault';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteAccountTitle),
        content:
            Text(isDemo ? l10n.deleteAccountDemoBody : l10n.deleteAccountBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.deleteAccountCancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: t.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.deleteAccountConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(l10n.deleteAccountProcessing)),
            ],
          ),
        ),
      ),
    );

    try {
      await ref.read(authControllerProvider.notifier).deleteAccount();
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(l10n.deleteAccountDone)),
      );
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (error) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        final message = error.code == 'requires-recent-login'
            ? l10n.deleteAccountRecentLogin
            : (error.message?.trim().isNotEmpty ?? false)
                ? error.message!.trim()
                : l10n.deleteAccountError;
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (_) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text(l10n.deleteAccountError)),
        );
      }
    }
  }

  AccountInfoSheet _personalInfo(AppStrings l10n, AuthSession auth) {
    return AccountInfoSheet(
      title: l10n.accountTilePersonal,
      icon: Icons.person_outline,
      sections: [
        AccountInfoSection(
          label: l10n.infoDisplayName,
          body: auth.displayName ?? l10n.demoUser,
        ),
        AccountInfoSection(
          label: l10n.infoMember,
          body: l10n.infoMemberDescription,
        ),
      ],
    );
  }

  AccountInfoSheet _emailInfo(AppStrings l10n, AuthSession auth) {
    return AccountInfoSheet(
      title: l10n.accountTileEmail,
      icon: Icons.email_outlined,
      sections: [
        AccountInfoSection(
          label: l10n.infoEmailLabel,
          body: auth.email ?? 'demo@vera.app',
        ),
        AccountInfoSection(
          label: l10n.infoEmailUsage,
          body: l10n.infoEmailDescription,
        ),
      ],
    );
  }

  AccountInfoSheet _helpInfo(AppStrings l10n) {
    return AccountInfoSheet(
      title: l10n.accountTileHelp,
      icon: Icons.help_outline,
      sections: [
        AccountInfoSection(
          label: l10n.helpFaqQ1,
          body: l10n.helpFaqA1,
        ),
        AccountInfoSection(
          label: l10n.helpFaqQ2,
          body: l10n.helpFaqA2,
        ),
        AccountInfoSection(
          label: l10n.helpFaqQ3,
          body: l10n.helpFaqA3,
        ),
        AccountInfoSection(
          label: l10n.helpContact,
          body: 'support@vera.app · https://github.com/YusufGUNEL/Vera/issues',
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.initials,
    required this.name,
    required this.email,
    required this.aiTone,
  });

  final String initials;
  final String name;
  final String email;
  final AiTone aiTone;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(t.vibe.radius),
        border: Border.all(color: t.line),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [t.brandSoft, t.brand],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: TextStyle(
                color: t.brandFG,
                fontWeight: FontWeight.w600,
                fontSize: 19,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: t.ink,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(email, style: TextStyle(fontSize: 13, color: t.muted)),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: t.uma.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    context.l10n
                        .profileAiToneBadge(_aiToneLabel(aiTone).toUpperCase()),
                    style: TextStyle(
                      color: t.uma,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
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
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: t.muted,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({
    required this.selected,
    required this.onChange,
  });

  final AppLocale selected;
  final ValueChanged<AppLocale> onChange;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(t.vibe.radius),
        border: Border.all(color: t.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.language,
            style: TextStyle(
              fontSize: 14,
              color: t.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            selected.label,
            style: TextStyle(
              fontSize: 16,
              color: t.ink,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final locale in AppLocale.values)
                _LanguageChip(
                  locale: locale,
                  selected: locale == selected,
                  onTap: () => onChange(locale),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    required this.locale,
    required this.selected,
    required this.onTap,
  });

  final AppLocale locale;
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                locale.short,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : t.muted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                locale.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : t.ink2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaletteSelector extends StatelessWidget {
  const _PaletteSelector({required this.selected, required this.onChange});

  final PaletteId selected;
  final ValueChanged<PaletteId> onChange;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(t.vibe.radius),
        border: Border.all(color: t.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.brandPalette,
            style: TextStyle(
              fontSize: 14,
              color: t.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Vera × Uma',
            style: TextStyle(
              fontSize: 16,
              color: t.ink,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final palette in Palette.all)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _Swatch(
                    palette: palette,
                    selected: palette.id == selected,
                    onTap: () => onChange(palette.id),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  final Palette palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? t.uma : Colors.transparent,
            width: 2,
          ),
        ),
        child: Container(
          width: 48,
          height: 48,
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: Stack(
            children: [
              Row(
                children: [
                  Expanded(child: Container(color: palette.brand)),
                  Expanded(child: Container(color: palette.uma)),
                ],
              ),
              if (selected)
                const Center(
                  child: Icon(Icons.check, color: Colors.white, size: 22),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SegmentedSelector<T> extends StatelessWidget {
  const _SegmentedSelector({
    required this.label,
    required this.selected,
    required this.options,
    required this.onChange,
  });

  final String label;
  final T selected;
  final List<(T, String)> options;
  final ValueChanged<T> onChange;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(t.vibe.radius),
        border: Border.all(color: t.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: t.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: t.bgSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                for (final option in options)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onChange(option.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: option.$1 == selected
                              ? t.card
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                          boxShadow: option.$1 == selected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          option.$2,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: option.$1 == selected ? t.ink : t.muted,
                          ),
                        ),
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
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(t.vibe.radius),
        border: Border.all(color: t.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: t.bgSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: t.brand, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: t.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: t.muted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ConnectedInstitutionsCard extends ConsumerWidget {
  const _ConnectedInstitutionsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l10n = context.l10n;
    final banks = ref.watch(homeControllerProvider).banks;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(t.vibe.radius),
        border: Border.all(color: t.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.profileConnectedTitle(banks.length),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: t.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.profileConnectedSubtitle,
            style: TextStyle(
              fontSize: 12,
              color: t.muted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < banks.length; i++) ...[
            _InstitutionTile(bank: banks[i]),
            if (i != banks.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _InstitutionTile extends StatelessWidget {
  const _InstitutionTile({required this.bank});

  final Bank bank;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.bgSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bank.color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              bank.shortCode,
              style: TextStyle(
                color: bank.color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bank.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: t.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.profileConnectedAccount(bank.last4),
                  style: TextStyle(fontSize: 12, color: t.muted),
                ),
              ],
            ),
          ),
          Text(
            fmtTL(bank.balance),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: t.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: t.card,
        borderRadius: BorderRadius.circular(t.vibe.radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(t.vibe.radius),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(t.vibe.radius),
              border: Border.all(color: t.line),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: t.bgSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: t.brand, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          color: t.ink,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: TextStyle(fontSize: 12, color: t.muted),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: t.muted, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _aiToneLabel(AiTone tone) {
  return switch (tone) {
    AiTone.concise => 'Concise',
    AiTone.coach => 'Coach',
    AiTone.proactive => 'Proactive',
  };
}
