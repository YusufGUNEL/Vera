import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vera/core/localization/app_locale.dart';
import 'package:vera/core/localization/app_strings.dart';
import 'package:vera/core/theme/app_tokens.dart';
import 'package:vera/core/theme/palette.dart';
import 'package:vera/core/theme/vibe.dart';
import 'package:vera/features/home/presentation/widgets/connected_banks.dart';
import 'package:vera/features/home/presentation/widgets/goal_card.dart';
import 'package:vera/features/home/presentation/widgets/home_first_steps_card.dart';

void main() {
  group('Home empty states', () {
    testWidgets('HomeFirstStepsCard shows onboarding actions', (tester) async {
      await tester.pumpWidget(
        _buildTestShell(
          child: Scaffold(
            body: HomeFirstStepsCard(
              onImport: () {},
              onScan: () {},
              onAddBank: () {},
            ),
          ),
        ),
      );

      expect(find.text('İlk adımı birlikte atalım'), findsOneWidget);
      expect(find.text('Ekstre yükle'), findsOneWidget);
      expect(find.text('Fiş tara'), findsOneWidget);
      expect(find.text('Banka ekle'), findsOneWidget);
    });

    testWidgets('ConnectedBanks shows explanatory empty state', (tester) async {
      await tester.pumpWidget(
        _buildTestShell(
          child: const Scaffold(
            body: ConnectedBanks(banks: []),
          ),
        ),
      );

      expect(find.text('Henüz bağlı hesap görünmüyor'), findsOneWidget);
      expect(find.textContaining('bakiyeni ana ekranda izler'), findsOneWidget);
    });

    testWidgets('GoalCard empty state shows hint and CTA', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        _buildTestShell(
          child: const Scaffold(
            body: GoalCard(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Acil durum fonu'), findsOneWidget);
      expect(find.text('Henüz hedef belirlemedin — dokun ve ekle.'), findsOneWidget);
      expect(find.text('Hedef kur'), findsOneWidget);
      expect(find.text('3 ay'), findsOneWidget);
      expect(find.text('6 ay'), findsOneWidget);
      expect(find.text('12 ay'), findsOneWidget);
    });
  });
}

Widget _buildTestShell({
  required Widget child,
  List<Override> overrides = const [],
}) {
  final tokens = AppTokens.build(
    paletteId: PaletteId.plum,
    mood: MoodId.light,
    vibeId: VibeId.standard,
  );

  return ProviderScope(
    overrides: overrides,
    child: TokensProvider(
      tokens: tokens,
      child: StringsProvider(
        strings: AppStrings(AppLocale.tr),
        child: MaterialApp(
          home: child,
        ),
      ),
    ),
  );
}
