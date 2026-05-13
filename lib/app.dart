import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_tokens.dart';
import 'core/theme/tweaks_controller.dart';

class VeraApp extends ConsumerWidget {
  const VeraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = ref.watch(tokensProvider);
    final router = ref.watch(appRouterProvider);

    return TokensProvider(
      tokens: tokens,
      child: MaterialApp.router(
        title: 'Vera',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.fromTokens(tokens),
        routerConfig: router,
      ),
    );
  }
}
