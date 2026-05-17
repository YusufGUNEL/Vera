import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vera/core/localization/app_strings.dart';
import 'package:vera/core/localization/locale_controller.dart';
import 'package:vera/core/theme/app_tokens.dart';
import 'package:vera/core/theme/tweaks_controller.dart';
import 'package:vera/features/onboarding/presentation/onboarding_screen.dart';

void main() {
  group('Onboarding smoke', () {
    testWidgets('flows through three steps and shows final secondary CTA', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const _OnboardingTestShell());
      await tester.pumpAndSettle();

      expect(find.text("Vera'ya hoş geldin"), findsOneWidget);
      expect(find.text('1 / 3'), findsOneWidget);
      expect(find.text('Atla'), findsOneWidget);

      await tester.tap(find.text('Devam et'));
      await tester.pumpAndSettle();

      expect(find.text('Görünüşünü ayarla'), findsOneWidget);
      expect(find.text('2 / 3'), findsOneWidget);
      expect(find.text('Atla'), findsOneWidget);

      await tester.tap(find.text('Devam et'));
      await tester.pumpAndSettle();

      expect(find.text('Verini getir'), findsOneWidget);
      expect(find.text('3 / 3'), findsOneWidget);
      expect(find.text('İçe aktarmadan devam et'), findsOneWidget);
      expect(find.text('Atla'), findsNothing);
    });

    testWidgets('back button returns to previous step', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const _OnboardingTestShell());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Devam et'));
      await tester.pumpAndSettle();
      expect(find.text('Görünüşünü ayarla'), findsOneWidget);

      await tester.tap(find.text('Geri'));
      await tester.pumpAndSettle();

      expect(find.text("Vera'ya hoş geldin"), findsOneWidget);
      expect(find.text('1 / 3'), findsOneWidget);
    });
  });
}

class _OnboardingTestShell extends StatelessWidget {
  const _OnboardingTestShell();

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(
      child: _OnboardingTestApp(),
    );
  }
}

class _OnboardingTestApp extends ConsumerWidget {
  const _OnboardingTestApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = ref.watch(tokensProvider);
    final strings = ref.watch(stringsProvider);
    ref.watch(localeControllerProvider);
    ref.watch(tweaksControllerProvider);

    return TokensProvider(
      tokens: tokens,
      child: StringsProvider(
        strings: strings,
        child: const MaterialApp(
          home: OnboardingScreen(),
        ),
      ),
    );
  }
}
