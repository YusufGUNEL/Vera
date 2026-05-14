import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/routes.dart';
import '../../core/theme/app_tokens.dart';
import '../../features/uma_chat/presentation/uma_chat_sheet.dart';

class AppShell extends ConsumerWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  static const _tabs = [
    _Tab(
      route: Routes.home,
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    _Tab(
      route: Routes.wealth,
      label: 'Wealth',
      icon: Icons.show_chart,
      activeIcon: Icons.show_chart,
    ),
    _Tab(
      route: Routes.subscriptions,
      label: 'Plans',
      icon: Icons.subscriptions_outlined,
      activeIcon: Icons.subscriptions,
    ),
    _Tab(
      route: Routes.credit,
      label: 'Credit',
      icon: Icons.credit_card_outlined,
      activeIcon: Icons.credit_card,
    ),
    _Tab(
      route: Routes.security,
      label: 'Security',
      icon: Icons.shield_outlined,
      activeIcon: Icons.shield,
    ),
  ];

  int _index(String location) {
    final i = _tabs.indexWhere((t) => t.route == location);
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
    final location = GoRouterState.of(context).uri.path;
    final current = _index(location);

    return Scaffold(
      backgroundColor: t.bg,
      extendBody: true,
      body: child,
      bottomNavigationBar: _BottomBar(
        tabs: _tabs,
        current: current,
        onTap: (i) => context.go(_tabs[i].route),
        onUma: () => _openUma(context),
      ),
    );
  }
}

class _Tab {
  const _Tab({
    required this.route,
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String route;
  final String label;
  final IconData icon;
  final IconData activeIcon;
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.tabs,
    required this.current,
    required this.onTap,
    required this.onUma,
  });

  final List<_Tab> tabs;
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
                color: t.card.withValues(alpha: 0.92),
                border: Border(top: BorderSide(color: t.line)),
              ),
              child: Row(
                children: [
                  _NavBtn(
                    tab: tabs[0],
                    active: current == 0,
                    onTap: () => onTap(0),
                  ),
                  _NavBtn(
                    tab: tabs[1],
                    active: current == 1,
                    onTap: () => onTap(1),
                  ),
                  const SizedBox(width: 64),
                  _NavBtn(
                    tab: tabs[2],
                    active: current == 2,
                    onTap: () => onTap(2),
                  ),
                  _NavBtn(
                    tab: tabs[3],
                    active: current == 3,
                    onTap: () => onTap(3),
                  ),
                  _NavBtn(
                    tab: tabs[4],
                    active: current == 4,
                    onTap: () => onTap(4),
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
                    'UMA',
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
    required this.tab,
    required this.active,
    required this.onTap,
  });

  final _Tab tab;
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
              Icon(active ? tab.activeIcon : tab.icon, color: color, size: 22),
              const SizedBox(height: 3),
              Text(
                tab.label,
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
