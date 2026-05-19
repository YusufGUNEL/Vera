import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vera/core/localization/app_locale.dart';
import 'package:vera/core/localization/app_strings.dart';
import 'package:vera/core/localization/locale_controller.dart';
import 'package:vera/core/theme/app_tokens.dart';
import 'package:vera/core/theme/palette.dart';
import 'package:vera/core/theme/tweaks_controller.dart';
import 'package:vera/core/theme/vibe.dart';
import 'package:vera/features/auth/domain/auth_session.dart';
import 'package:vera/features/auth/state/auth_controller.dart';
import 'package:vera/features/profile_settings/domain/profile_state.dart';
import 'package:vera/features/profile_settings/presentation/profile_settings_sheet.dart';
import 'package:vera/features/profile_settings/state/profile_controller.dart';
import 'package:vera/features/receipt_scan/presentation/receipt_scan_sheet.dart';
import 'package:vera/features/statement_import/presentation/statement_import_sheet.dart';
import 'package:vera/shared/widgets/drag_drop_zone.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final l10n = AppStrings(AppLocale.tr);

  group('AuthSession.isAnonymous', () {
    test('demo vault session is anonymous', () {
      const session = AuthSession(
        status: AuthStatus.signedIn,
        userId: 'demo-user',
        authMethod: 'demo vault',
      );
      expect(session.isAnonymous, isTrue);
    });

    test('firebase session is not anonymous', () {
      const session = AuthSession(
        status: AuthStatus.signedIn,
        userId: 'uid-42',
        displayName: 'Ayşe Yılmaz',
        email: 'ayse@example.com',
        authMethod: 'firebase_google',
      );
      expect(session.isAnonymous, isFalse);
    });
  });

  group('ProfileSettingsSheet dynamic identity', () {
    testWidgets('anonymous session shows localized defaults', (tester) async {
      await tester.pumpWidget(
        _shell(
          auth: const AuthSession(
            status: AuthStatus.signedIn,
            userId: 'demo-user',
            authMethod: 'demo vault',
          ),
          child: const ProfileSettingsSheet(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(l10n.defaultUserName), findsWidgets);
      expect(find.text(l10n.notSet), findsWidgets);
      expect(find.textContaining('demo@'), findsNothing);
    });

    testWidgets('signed-in user shows profile name and email', (tester) async {
      await tester.pumpWidget(
        _shell(
          auth: const AuthSession(
            status: AuthStatus.signedIn,
            userId: 'uid-42',
            displayName: 'Ayşe Yılmaz',
            email: 'ayse@example.com',
            authMethod: 'firebase_google',
          ),
          child: const ProfileSettingsSheet(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ayşe Yılmaz'), findsWidgets);
      expect(find.text('ayse@example.com'), findsWidgets);
    });
  });

  group('DragDropZone integration', () {
    testWidgets('import sheets wrap pickers with DragDropZone', (tester) async {
      await tester.pumpWidget(
        _shell(
          child: const Scaffold(
            body: Column(
              children: [
                Expanded(child: StatementImportSheet()),
                Expanded(child: ReceiptScanSheet()),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DragDropZone), findsNWidgets(2));
    });

    testWidgets('mobile platform skips DropTarget wrapper', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        await tester.pumpWidget(
          _shell(
            child: DragDropZone(
              onFileDropped: (_, __) {},
              child: const Text('picker-child'),
            ),
          ),
        );

        expect(find.text('picker-child'), findsOneWidget);
        expect(find.byType(DragDropZone), findsOneWidget);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  });
}

Widget _shell({
  required Widget child,
  AuthSession auth = const AuthSession(status: AuthStatus.signedOut),
}) {
  final tokens = AppTokens.build(
    paletteId: PaletteId.plum,
    mood: MoodId.light,
    vibeId: VibeId.standard,
  );

  return ProviderScope(
    overrides: [
      authControllerProvider.overrideWith(
        (ref) => _FakeAuthController(auth),
      ),
      profileControllerProvider.overrideWith(
        (ref) => _FakeProfileController(const ProfileState()),
      ),
      localeControllerProvider.overrideWith(
        (ref) => _FakeLocaleController(AppLocale.tr),
      ),
      tweaksControllerProvider.overrideWith(
        (ref) => _FakeTweaksController(const TweaksState()),
      ),
    ],
    child: TokensProvider(
      tokens: tokens,
      child: StringsProvider(
        strings: AppStrings(AppLocale.tr),
        child: MaterialApp(home: child),
      ),
    ),
  );
}

class _FakeAuthController extends StateNotifier<AuthSession>
    implements AuthController {
  _FakeAuthController(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProfileController extends StateNotifier<ProfileState>
    implements ProfileController {
  _FakeProfileController(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeLocaleController extends StateNotifier<AppLocale>
    implements LocaleController {
  _FakeLocaleController(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeTweaksController extends StateNotifier<TweaksState>
    implements TweaksController {
  _FakeTweaksController(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
