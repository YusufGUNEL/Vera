import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vera/core/config/env.dart';
import 'package:vera/core/firebase/firebase_bootstrap.dart';
import 'package:vera/core/localization/app_locale.dart';
import 'package:vera/core/localization/app_strings.dart';
import 'package:vera/core/theme/app_tokens.dart';
import 'package:vera/core/theme/palette.dart';
import 'package:vera/core/theme/vibe.dart';
import 'package:vera/features/auth/data/firebase_auth_service.dart';
import 'package:vera/features/auth/presentation/login_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Env.load tolerates a missing .env file', (tester) async {
    await Env.load(fileName: 'assets/does_not_exist.env');

    expect(Env.isLoaded, isTrue);
    expect(Env.hasFirebaseCoreConfig, isFalse);
    expect(Env.state.warning, isNotNull);
  });

  test('FirebaseAuthService throws a controlled exception when disabled', () async {
    final container = ProviderContainer(
      overrides: [
        firebaseBootstrapProvider.overrideWith(
          (ref) => const FirebaseBootstrapState(
            enabled: false,
            initialized: false,
            hasCoreConfig: false,
            debugMessage: 'Missing Firebase config for test.',
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final service = container.read(firebaseAuthServiceProvider);

    expect(
      () => service.signInWithEmail(email: 'user@vera.app', password: 'secret'),
      throwsA(isA<FirebaseAuthUnavailableException>()),
    );
  });

  testWidgets(
    'LoginScreen shows local-mode guidance and blocks non-demo login without Firebase',
    (tester) async {
      await tester.pumpWidget(
        _buildShell(
          overrides: [
            firebaseBootstrapProvider.overrideWith(
              (ref) => const FirebaseBootstrapState(
                enabled: false,
                initialized: false,
                hasCoreConfig: false,
              ),
            ),
          ],
          child: const LoginScreen(),
        ),
      );

      expect(find.textContaining('demo hesab'), findsOneWidget);

      await tester.enterText(find.byType(TextField).at(0), 'user@vera.app');
      await tester.enterText(find.byType(TextField).at(1), 'secret123');
      await tester.tap(find.text('E-posta ile devam et'));
      await tester.pump();

      expect(
        find.text("Firebase yapılandırılmadıysa giriş başarısız olur. .env'i kontrol et."),
        findsOneWidget,
      );
    },
  );
}

Widget _buildShell({
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
        child: MaterialApp(home: child),
      ),
    ),
  );
}
