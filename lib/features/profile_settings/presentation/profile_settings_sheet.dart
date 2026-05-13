import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/palette.dart';
import '../../../core/theme/tweaks_controller.dart';
import '../../../core/theme/vibe.dart';

class ProfileSettingsSheet extends ConsumerWidget {
  const ProfileSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final tweaks = ref.watch(tweaksControllerProvider);
    final ctrl = ref.read(tweaksControllerProvider.notifier);

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
            // Drag handle
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
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.chevron_left, color: t.ink, size: 26),
                  ),
                  Expanded(
                    child: Text('Profile & Settings',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: t.ink,
                          letterSpacing: -0.3,
                        )),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  _ProfileCard(),
                  const SizedBox(height: 24),
                  _SectionLabel(label: 'APPEARANCE & THEMING'),
                  const SizedBox(height: 8),
                  _PaletteSelector(
                    selected: tweaks.paletteId,
                    onChange: ctrl.setPalette,
                  ),
                  const SizedBox(height: 16),
                  _SegmentedSelector<MoodId>(
                    label: 'Mood',
                    selected: tweaks.mood,
                    options: const [
                      (MoodId.light, 'Light'),
                      (MoodId.dark, 'Dark'),
                    ],
                    onChange: ctrl.setMood,
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
                    onChange: ctrl.setVibe,
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(label: 'ACCOUNT'),
                  const SizedBox(height: 8),
                  _AccountTile(icon: Icons.person_outline, label: 'Personal info'),
                  _AccountTile(icon: Icons.lock_outline, label: 'Security & PIN'),
                  _AccountTile(icon: Icons.face_outlined, label: 'Face ID'),
                  _AccountTile(icon: Icons.help_outline, label: 'Help & support'),
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
            child: Text('MA',
                style: TextStyle(
                    color: t.brandFG,
                    fontWeight: FontWeight.w600,
                    fontSize: 19)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mert Aksoy',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: t.ink,
                      letterSpacing: -0.3,
                    )),
                const SizedBox(height: 2),
                Text('mert@aksoy.com',
                    style: TextStyle(fontSize: 13, color: t.muted)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: t.uma.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('PRIVATE TIER',
                      style: TextStyle(
                        color: t.uma,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      )),
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
      child: Text(label,
          style: TextStyle(
            fontSize: 11,
            color: t.muted,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          )),
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
          Text('Brand palette',
              style: TextStyle(
                fontSize: 14,
                color: t.muted,
                fontWeight: FontWeight.w500,
              )),
          const SizedBox(height: 4),
          Text('Vera × Uma',
              style: TextStyle(
                fontSize: 16,
                color: t.ink,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              )),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final p in Palette.all)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _Swatch(
                    palette: p,
                    selected: p.id == selected,
                    onTap: () => onChange(p.id),
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
          Text(label,
              style: TextStyle(
                fontSize: 14,
                color: t.muted,
                fontWeight: FontWeight.w500,
              )),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: t.bgSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                for (final o in options)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onChange(o.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: o.$1 == selected ? t.card : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                          boxShadow: o.$1 == selected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          o.$2,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: o.$1 == selected ? t.ink : t.muted,
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

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.icon, required this.label});
  final IconData icon;
  final String label;

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
                  child: Text(label,
                      style: TextStyle(
                          fontSize: 14,
                          color: t.ink,
                          fontWeight: FontWeight.w500)),
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
