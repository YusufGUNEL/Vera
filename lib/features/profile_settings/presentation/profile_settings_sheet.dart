import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/palette.dart';
import '../../../core/theme/tweaks_controller.dart';
import '../../../core/theme/vibe.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/auth_session.dart';
import '../../auth/state/auth_controller.dart';
import '../../home/data/bank.dart';
import '../domain/profile_state.dart';
import '../state/profile_controller.dart';

class ProfileSettingsSheet extends ConsumerWidget {
  const ProfileSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final tweaks = ref.watch(tweaksControllerProvider);
    final tweaksCtrl = ref.read(tweaksControllerProvider.notifier);
    final auth = ref.watch(authControllerProvider);
    final profile = ref.watch(profileControllerProvider);
    final profileCtrl = ref.read(profileControllerProvider.notifier);

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
                      'Profile & Settings',
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
                    name: auth.displayName ?? 'Vera User',
                    email: auth.email ?? 'demo@vera.app',
                    aiTone: profile.aiTone,
                  ),
                  const SizedBox(height: 12),
                  _SessionVaultCard(auth: auth, profile: profile),
                  const SizedBox(height: 24),
                  const _SectionLabel(label: 'APPEARANCE & THEMING'),
                  const SizedBox(height: 8),
                  _PaletteSelector(
                    selected: tweaks.paletteId,
                    onChange: tweaksCtrl.setPalette,
                  ),
                  const SizedBox(height: 16),
                  _SegmentedSelector<MoodId>(
                    label: 'Mood',
                    selected: tweaks.mood,
                    options: const [
                      (MoodId.light, 'Light'),
                      (MoodId.dark, 'Dark'),
                    ],
                    onChange: tweaksCtrl.setMood,
                  ),
                  const SizedBox(height: 12),
                  _SegmentedSelector<VibeId>(
                    label: 'Vibe',
                    selected: tweaks.vibeId,
                    options: const [
                      (VibeId.calm, 'Calm'),
                      (VibeId.standard, 'Standard'),
                      (VibeId.bold, 'Bold'),
                    ],
                    onChange: tweaksCtrl.setVibe,
                  ),
                  const SizedBox(height: 24),
                  const _SectionLabel(label: 'AI PREFERENCES'),
                  const SizedBox(height: 8),
                  _SegmentedSelector<AiTone>(
                    label: 'Uma tone',
                    selected: profile.aiTone,
                    options: const [
                      (AiTone.concise, 'Concise'),
                      (AiTone.coach, 'Coach'),
                      (AiTone.proactive, 'Proactive'),
                    ],
                    onChange: profileCtrl.setAiTone,
                  ),
                  const SizedBox(height: 12),
                  _ToggleTile(
                    icon: Icons.wb_twilight_outlined,
                    label: 'Daily AI briefing',
                    subtitle:
                        'Start the day with account health, suspicious activity, and savings prompts',
                    value: profile.dailyBriefingEnabled,
                    onChanged: profileCtrl.setDailyBriefing,
                  ),
                  const SizedBox(height: 12),
                  _SegmentedSelector<DataSyncMode>(
                    label: 'Live data sync',
                    selected: profile.dataSyncMode,
                    options: const [
                      (DataSyncMode.live, 'Live'),
                      (DataSyncMode.balanced, 'Balanced'),
                      (DataSyncMode.saver, 'Saver'),
                    ],
                    onChange: profileCtrl.setDataSyncMode,
                  ),
                  const SizedBox(height: 12),
                  _SegmentedSelector<int>(
                    label: 'Auto-approve limit',
                    selected: profile.autoApproveLimit,
                    options: const [
                      (0, 'Off'),
                      (2500, 'TL 2.500'),
                      (10000, 'TL 10.000'),
                    ],
                    onChange: profileCtrl.setAutoApproveLimit,
                  ),
                  const SizedBox(height: 12),
                  _ToggleTile(
                    icon: Icons.notifications_outlined,
                    label: 'Smart notifications',
                    subtitle:
                        'Alerts for fraud, renewals, and approval changes',
                    value: profile.notificationsEnabled,
                    onChanged: profileCtrl.setNotifications,
                  ),
                  const SizedBox(height: 8),
                  _ToggleTile(
                    icon: Icons.face_outlined,
                    label: 'Face ID relock',
                    subtitle:
                        'Require biometric unlock before sensitive actions',
                    value: profile.faceIdEnabled,
                    onChanged: profileCtrl.setFaceId,
                  ),
                  const SizedBox(height: 8),
                  _ToggleTile(
                    icon: Icons.shield_outlined,
                    label: 'High-sensitivity fraud alerts',
                    subtitle:
                        'Let Vera flag unusual device and payment patterns earlier',
                    value: profile.fraudAlertsEnabled,
                    onChanged: profileCtrl.setFraudAlerts,
                  ),
                  const SizedBox(height: 24),
                  const _SectionLabel(label: 'CONNECTED INSTITUTIONS'),
                  const SizedBox(height: 8),
                  const _ConnectedInstitutionsCard(),
                  const SizedBox(height: 24),
                  const _SectionLabel(label: 'ACCOUNT'),
                  const SizedBox(height: 8),
                  _AccountTile(
                    icon: Icons.person_outline,
                    label: 'Personal info',
                    value: auth.displayName ?? 'Demo user',
                  ),
                  _AccountTile(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: auth.email ?? 'demo@vera.app',
                  ),
                  _AccountTile(
                    icon: Icons.lock_outline,
                    label: 'Security & PIN',
                    value: profile.faceIdEnabled
                        ? 'Session vault + Face ID'
                        : 'Session vault only',
                  ),
                  _AccountTile(
                    icon: Icons.storage_outlined,
                    label: 'Storage policy',
                    value: _syncModeLabel(profile.dataSyncMode),
                  ),
                  _AccountTile(
                    icon: Icons.help_outline,
                    label: 'Help & support',
                    value: auth.authMethod,
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
                      child: const Text('Sign out'),
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
                    'AI TONE / ${_aiToneLabel(aiTone).toUpperCase()}',
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
                      'Protected session vault',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: t.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Identity is persisted separately from local preferences.',
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
                  label: 'Sign-in',
                  value: auth.authMethod,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _VaultStat(
                  label: 'Protected since',
                  value: _signedInLabel(auth.signedInAt),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _VaultStat(
                  label: 'Sync mode',
                  value: _syncModeLabel(profile.dataSyncMode),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _VaultStat(
                  label: 'Approval guardrail',
                  value: profile.autoApproveLimit == 0
                      ? 'Manual only'
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
            'Brand palette',
            style: TextStyle(
              fontSize: 14,
              color: t.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Vera x Uma',
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

class _ConnectedInstitutionsCard extends StatelessWidget {
  const _ConnectedInstitutionsCard();

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
            '${kBanks.length} connected institutions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: t.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Live balances refresh through the current sync policy and feed cache.',
            style: TextStyle(
              fontSize: 12,
              color: t.muted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          for (final bank in kBanks) ...[
            _InstitutionTile(bank: bank),
            if (bank != kBanks.last) const SizedBox(height: 8),
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
                  'Account ${bank.last4}',
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
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: t.card,
        borderRadius: BorderRadius.circular(t.vibe.radius),
        child: InkWell(
          onTap: () {},
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

String _syncModeLabel(DataSyncMode mode) {
  return switch (mode) {
    DataSyncMode.live => 'Live sync',
    DataSyncMode.balanced => 'Balanced sync',
    DataSyncMode.saver => 'Battery saver sync',
  };
}

String _signedInLabel(DateTime? date) {
  if (date == null) return 'This device';
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${date.day}.${date.month} $hour:$minute';
}
