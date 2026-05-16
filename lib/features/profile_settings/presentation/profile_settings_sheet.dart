import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/firebase/firebase_bootstrap.dart';
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
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  _ProfileCard(
                    initials: auth.initials,
                    name: auth.displayName ?? l10n.defaultUserName,
                    email: auth.email ?? 'demo@vera.app',
                    aiTone: profile.aiTone,
                  ),
                  const SizedBox(height: 12),
                  _SessionVaultCard(auth: auth, profile: profile),
                  const SizedBox(height: 24),
                  _SectionLabel(label: l10n.sectionLanguage),
                  const SizedBox(height: 8),
                  _LanguageSelector(
                    selected: currentLocale,
                    onChange: localeCtrl.setLocale,
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(label: l10n.sectionAppearance),
                  const SizedBox(height: 8),
                  _PaletteSelector(
                    selected: tweaks.paletteId,
                    onChange: tweaksCtrl.setPalette,
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 24),
                  _SectionLabel(label: l10n.sectionAi),
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 12),
                  _ToggleTile(
                    icon: Icons.wb_twilight_outlined,
                    label: l10n.profileDailyBriefing,
                    subtitle: l10n.profileDailyBriefingSub,
                    value: profile.dailyBriefingEnabled,
                    onChanged: profileCtrl.setDailyBriefing,
                  ),
                  const SizedBox(height: 12),
                  _SegmentedSelector<DataSyncMode>(
                    label: l10n.profileLiveSync,
                    selected: profile.dataSyncMode,
                    options: [
                      (DataSyncMode.live, l10n.profileLiveSyncLive),
                      (DataSyncMode.balanced, l10n.profileLiveSyncBalanced),
                      (DataSyncMode.saver, l10n.profileLiveSyncSaver),
                    ],
                    onChange: profileCtrl.setDataSyncMode,
                  ),
                  const SizedBox(height: 12),
                  _SegmentedSelector<int>(
                    label: l10n.profileAutoApprove,
                    selected: profile.autoApproveLimit,
                    options: [
                      (0, l10n.profileAutoApproveOff),
                      (2500, 'TL 2.500'),
                      (10000, 'TL 10.000'),
                    ],
                    onChange: profileCtrl.setAutoApproveLimit,
                  ),
                  const SizedBox(height: 12),
                  _ToggleTile(
                    icon: Icons.notifications_outlined,
                    label: l10n.profileSmartNotif,
                    subtitle: l10n.profileSmartNotifSub,
                    value: profile.notificationsEnabled,
                    onChanged: profileCtrl.setNotifications,
                  ),
                  const SizedBox(height: 8),
                  _ToggleTile(
                    icon: Icons.face_outlined,
                    label: l10n.profileFaceId,
                    subtitle: l10n.profileFaceIdSub,
                    value: profile.faceIdEnabled,
                    onChanged: profileCtrl.setFaceId,
                  ),
                  const SizedBox(height: 8),
                  _ToggleTile(
                    icon: Icons.shield_outlined,
                    label: l10n.profileFraudHigh,
                    subtitle: l10n.profileFraudHighSub,
                    value: profile.fraudAlertsEnabled,
                    onChanged: profileCtrl.setFraudAlerts,
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(label: l10n.sectionConnected),
                  const SizedBox(height: 8),
                  const _ConnectedInstitutionsCard(),
                  const SizedBox(height: 24),
                  _SectionLabel(label: l10n.sectionAccount),
                  const SizedBox(height: 8),
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
                    onTap: () =>
                        _openInfo(context, _emailInfo(l10n, auth)),
                  ),
                  _AccountTile(
                    icon: Icons.lock_outline,
                    label: l10n.accountTileSecurity,
                    value: profile.faceIdEnabled
                        ? 'Session vault + Face ID'
                        : 'Session vault only',
                    onTap: () =>
                        _openInfo(context, _securityInfo(l10n, profile)),
                  ),
                  _AccountTile(
                    icon: Icons.storage_outlined,
                    label: l10n.accountTileStorage,
                    value: _syncModeLabel(context, profile.dataSyncMode),
                    onTap: () =>
                        _openInfo(context, _storageInfo(context, l10n, profile)),
                  ),
                  _AccountTile(
                    icon: Icons.help_outline,
                    label: l10n.accountTileHelp,
                    value: auth.authMethod,
                    onTap: () => _openInfo(context, _helpInfo(l10n)),
                  ),
                  _AccountTile(
                    icon: Icons.download_outlined,
                    label: l10n.exportTile,
                    value: l10n.exportTileValue,
                    onTap: () => _openExport(context),
                  ),
                  _AccountTile(
                    icon: Icons.restart_alt,
                    label: l10n.demoResetTile,
                    value: l10n.demoResetTileValue,
                    onTap: () => _confirmDemoReset(context, ref),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        await ref
                            .read(authControllerProvider.notifier)
                            .signOut();
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: t.red,
                        side: BorderSide(color: t.red.withValues(alpha: 0.35)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(l10n.signOut),
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

  AccountInfoSheet _securityInfo(AppStrings l10n, ProfileState profile) {
    return AccountInfoSheet(
      title: l10n.accountTileSecurity,
      icon: Icons.lock_outline,
      sections: [
        AccountInfoSection(
          label: l10n.infoSessionVault,
          body: l10n.infoSessionVaultDescription,
        ),
        AccountInfoSection(
          label: l10n.infoFaceId,
          body: profile.faceIdEnabled
              ? l10n.infoFaceIdOn
              : l10n.infoFaceIdOff,
        ),
        AccountInfoSection(
          label: l10n.infoFraudAlerts,
          body: profile.fraudAlertsEnabled
              ? l10n.infoFraudAlertsOn
              : l10n.infoFraudAlertsOff,
        ),
      ],
    );
  }

  AccountInfoSheet _storageInfo(
      BuildContext context, AppStrings l10n, ProfileState profile) {
    final firebase = FirebaseBootstrap.state;
    return AccountInfoSheet(
      title: l10n.accountTileStorage,
      icon: Icons.storage_outlined,
      sections: [
        AccountInfoSection(
          label: l10n.infoSyncMode,
          body: _syncModeLabel(context, profile.dataSyncMode),
        ),
        AccountInfoSection(
          label: l10n.infoLocalData,
          body: l10n.infoLocalDataDescription,
        ),
        AccountInfoSection(
          label: 'Cloud sync',
          body: firebase.ready
              ? 'Firebase is active. Imported receipts, statements, banks, profile settings, and imported transactions can sync to the vera-ai-finance project.'
              : 'Firebase is not active on this session yet, so Vera is currently running in local-first mode.',
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
                    context.l10n.profileAiToneBadge(
                        _aiToneLabel(aiTone).toUpperCase()),
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

class _SessionVaultCard extends StatelessWidget {
  const _SessionVaultCard({
    required this.auth,
    required this.profile,
  });

  final AuthSession auth;
  final ProfileState profile;

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
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: t.bgSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.verified_user_outlined, color: t.uma),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.profileVaultTitle,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: t.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.profileVaultSubtitle,
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
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _VaultStat(
                  label: context.l10n.profileVaultSignIn,
                  value: auth.authMethod,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _VaultStat(
                  label: context.l10n.profileVaultProtectedSince,
                  value: _signedInLabel(context, auth.signedInAt),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _VaultStat(
                  label: context.l10n.profileVaultSyncMode,
                  value: _syncModeLabel(context, profile.dataSyncMode),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _VaultStat(
                  label: context.l10n.profileVaultApproval,
                  value: profile.autoApproveLimit == 0
                      ? context.l10n.profileVaultManualOnly
                      : fmtTL(profile.autoApproveLimit),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VaultStat extends StatelessWidget {
  const _VaultStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.bgSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: t.muted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
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
                          color:
                              option.$1 == selected ? t.card : Colors.transparent,
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

String _syncModeLabel(BuildContext context, DataSyncMode mode) {
  final l10n = context.l10n;
  return switch (mode) {
    DataSyncMode.live => l10n.profileVaultSyncLive,
    DataSyncMode.balanced => l10n.profileVaultSyncBalanced,
    DataSyncMode.saver => l10n.profileVaultSyncSaver,
  };
}

String _signedInLabel(BuildContext context, DateTime? date) {
  if (date == null) return context.l10n.profileVaultThisDevice;
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${date.day}.${date.month} $hour:$minute';
}
