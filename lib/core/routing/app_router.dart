import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/auth_session.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/state/auth_controller.dart';
import '../services/notification_service.dart';
import '../../features/credit/presentation/credit_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/state/onboarding_controller.dart';
import '../../features/security/presentation/security_screen.dart';
import '../../features/subscriptions/presentation/subscriptions_screen.dart';
import '../../features/wealth/presentation/wealth_screen.dart';
import '../../shared/widgets/app_shell.dart';
import 'routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);
  final onboarding = ref.watch(onboardingControllerProvider);

  final router = GoRouter(
    initialLocation: Routes.home,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final path = state.uri.path;
      final isAuthRoute = path == Routes.login || path == Routes.signup;
      final isOnboarding = path == Routes.onboarding;

      if (auth.status == AuthStatus.loading) return null;
      if (!onboarding.loaded) return null;

      if (auth.status == AuthStatus.signedOut) {
        return isAuthRoute ? null : Routes.login;
      }

      // signed in past this point
      if (!onboarding.completed && !isOnboarding) {
        return Routes.onboarding;
      }
      if (onboarding.completed && isOnboarding) {
        return Routes.home;
      }

      if (auth.status == AuthStatus.signedIn && isAuthRoute) {
        return Routes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: Routes.login,
        pageBuilder: (_, __) => const NoTransitionPage(child: LoginScreen()),
      ),
      GoRoute(
        path: Routes.signup,
        builder: (_, __) => const SignupScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            pageBuilder: (_, __) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: Routes.wealth,
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: WealthScreen()),
          ),
          GoRoute(
            path: Routes.subscriptions,
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: SubscriptionsScreen()),
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

  final sub = NotificationService.instance.onTap.listen((payload) {
    if (payload.startsWith('/')) {
      router.go(payload);
    }
  });
  ref.onDispose(sub.cancel);

  return router;
});
