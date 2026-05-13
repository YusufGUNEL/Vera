import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/credit/presentation/credit_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/security/presentation/security_screen.dart';
import '../../features/wealth/presentation/wealth_screen.dart';
import '../../shared/widgets/app_shell.dart';
import 'routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.home,
    debugLogDiagnostics: false,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: Routes.wealth,
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: WealthScreen()),
          ),
          GoRoute(
            path: Routes.credit,
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: CreditScreen()),
          ),
          GoRoute(
            path: Routes.security,
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: SecurityScreen()),
          ),
        ],
      ),
    ],
  );
});
