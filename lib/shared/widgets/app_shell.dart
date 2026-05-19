import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_strings.dart';
import '../../core/routing/routes.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/responsive.dart';
import '../../features/uma_chat/presentation/uma_chat_sheet.dart';

class AppShell extends ConsumerWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  static const _tabRoutes = [
    Routes.home,
    Routes.wealth,
    Routes.subscriptions,
    Routes.security,
  ];

  static const _tabIcons = [
    _TabIcon(icon: Icons.home_outlined, activeIcon: Icons.home_rounded),
    _TabIcon(icon: Icons.show_chart, activeIcon: Icons.show_chart),
    _TabIcon(
        icon: Icons.subscriptions_outlined, activeIcon: Icons.subscriptions),
    _TabIcon(icon: Icons.shield_outlined, activeIcon: Icons.shield),
  ];

  int _index(String location) {
    final i = _tabRoutes.indexOf(location);
    return i == -1 ? 0 : i;
  }

  void _openUma(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => const UmaChatSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l10n = context.l10n;
    final location = GoRouterState.of(context).uri.path;
    final current = _index(location);
    final responsive = context.responsive;

    final labels = [
      l10n.navHome,
      l10n.navWealth,
      l10n.navPlans,
      l10n.navSecurity,
    ];

    return Scaffold(
      backgroundColor: t.bg,
      extendBody: true,
      body: responsive.useDesktopNav
          ? Row(
              children: [
                _SideRail(
                  icons: _tabIcons,
                  labels: labels,
                  umaLabel: l10n.navUma,
                  current: current,
                  onTap: (i) => context.go(_tabRoutes[i]),
                  onUma: () => _openUma(context),
                ),
                Expanded(child: child),
              ],
            )
          : child,
      bottomNavigationBar: responsive.useDesktopNav
          ? null
          : _BottomBar(
              icons: _tabIcons,
              labels: labels,
              umaLabel: l10n.navUma,
              current: current,
              onTap: (i) => context.go(_tabRoutes[i]),
              onUma: () => _openUma(context),
            ),
    );
  }
}

class _SideRail extends StatelessWidget {
  const _SideRail({
    required this.icons,
    required this.labels,
    required this.umaLabel,
    required this.current,
    required this.onTap,
    required this.onUma,
  });

  final List<_TabIcon> icons;
  final List<String> labels;
  final String umaLabel;
  final int current;
  final ValueChanged<int> onTap;
  final VoidCallback onUma;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SafeArea(
      right: false,
      child: Container(
        width: 96,
        decoration: BoxDecoration(
          color: t.card,
          border: Border(right: BorderSide(color: t.line)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 18),
            for (var i = 0; i < icons.length; i++) ...[
              _RailBtn(
                icon: icons[i],
                label: labels[i],
                active: current == i,
                onTap: () => onTap(i),
              ),
              const SizedBox(height: 8),
            ],
            const Spacer(),
            GestureDetector(
              onTap: onUma,
              child: Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.4, -0.4),
                    colors: [t.umaLight, t.uma],
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.auto_awesome,
                  size: 26,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              umaLabel,
              style: TextStyle(
                color: t.uma,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 22),
          ],
        ),
      ),
    );
  }
}

class _TabIcon {
  const _TabIcon({required this.icon, required this.activeIcon});

  final IconData icon;
  final IconData activeIcon;
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.icons,
    required this.labels,
    required this.umaLabel,
    required this.current,
    required this.onTap,
    required this.onUma,
  });

  final List<_TabIcon> icons;
  final List<String> labels;
  final String umaLabel;
  final int current;
  final ValueChanged<int> onTap;
  final VoidCallback onUma;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final mq = MediaQuery.of(context);

    return SizedBox(
      height: 88 + mq.padding.bottom,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding:
                  EdgeInsets.fromLTRB(8, 8, 8, 22 + mq.padding.bottom * 0.4),
              decoration: BoxDecoration(
                color: t.card,
                border: Border(top: BorderSide(color: t.line)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _NavBtn(
                    icon: icons[0],
                    label: labels[0],
                    active: current == 0,
                    onTap: () => onTap(0),
                  ),
                  _NavBtn(
                    icon: icons[1],
                    label: labels[1],
                    active: current == 1,
                    onTap: () => onTap(1),
                  ),
                  const SizedBox(width: 64),
                  _NavBtn(
                    icon: icons[2],
                    label: labels[2],
                    active: current == 2,
                    onTap: () => onTap(2),
                  ),
                  _NavBtn(
                    icon: icons[3],
                    label: labels[3],
                    active: current == 3,
                    onTap: () => onTap(3),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 38 + mq.padding.bottom * 0.4,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: onUma,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: const Alignment(-0.4, -0.4),
                          colors: [t.umaLight, t.uma],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: t.uma.withValues(alpha: 0.45),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: t.uma.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.35),
                                width: 1.5,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.auto_awesome,
                            size: 26,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    umaLabel,
                    style: TextStyle(
                      color: t.uma,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final _TabIcon icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final color = active ? t.brand : t.muted;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(active ? icon.activeIcon : icon.icon,
                  color: color, size: 22),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.2,
                  color: color,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RailBtn extends StatelessWidget {
  const _RailBtn({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final _TabIcon icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final color = active ? t.brand : t.muted;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 72,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: active ? t.bgSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(active ? icon.activeIcon : icon.icon,
                  color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5,
                  color: color,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
