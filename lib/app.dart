import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_tokens.dart';
import 'core/theme/tweaks_controller.dart';
import 'features/auth/domain/auth_session.dart';
import 'features/auth/state/auth_controller.dart';

class VeraApp extends ConsumerWidget {
  const VeraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = ref.watch(tokensProvider);
    final auth = ref.watch(authControllerProvider);

    return TokensProvider(
      tokens: tokens,
      child: auth.status == AuthStatus.loading
          ? MaterialApp(
              title: 'Vera',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.fromTokens(tokens),
              home: _AppLoading(tokens: tokens),
            )
          : MaterialApp.router(
              title: 'Vera',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.fromTokens(tokens),
              routerConfig: ref.watch(appRouterProvider),
            ),
    );
  }
}

class _AppLoading extends StatelessWidget {
  const _AppLoading({required this.tokens});

  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tokens.bg,
      body: Center(
        child: CircularProgressIndicator(color: tokens.uma),
      ),
    );
  }
}
