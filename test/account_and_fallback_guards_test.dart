import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vera/core/firebase/firebase_bootstrap.dart';
import 'package:vera/core/localization/app_locale.dart';
import 'package:vera/core/localization/app_strings.dart';
import 'package:vera/core/theme/app_tokens.dart';
import 'package:vera/core/theme/palette.dart';
import 'package:vera/core/theme/vibe.dart';
import 'package:vera/features/auth/data/auth_storage.dart';
import 'package:vera/features/auth/data/firebase_auth_service.dart';
import 'package:vera/features/auth/domain/auth_session.dart';
import 'package:vera/features/auth/state/auth_controller.dart';
import 'package:vera/features/receipt_scan/domain/parsed_receipt.dart';
import 'package:vera/features/receipt_scan/presentation/receipt_scan_sheet.dart';
import 'package:vera/features/receipt_scan/state/receipt_controller.dart';
import 'package:vera/features/statement_import/domain/parsed_statement.dart';
import 'package:vera/features/statement_import/presentation/statement_import_sheet.dart';
import 'package:vera/features/statement_import/state/statement_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('deleteAccount clears demo session and local cache', () async {
    SharedPreferences.setMockInitialValues({
      'home.feed.cache': 'cached',
      'onboarding.completed': true,
    });

    final storage = _MemoryAuthStorage();
    late _FakeFirebaseAuthService authService;
    final container = ProviderContainer(
      overrides: [
        firebaseBootstrapProvider.overrideWith(
          (ref) => const FirebaseBootstrapState(
            enabled: false,
            initialized: false,
          ),
        ),
        authStorageProvider.overrideWith((ref) => storage),
        firebaseAuthServiceProvider.overrideWith(
          (ref) => authService = _FakeFirebaseAuthService(ref),
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(authControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    await controller.signInDemo(displayName: 'Demo User', email: 'a');
    await controller.deleteAccount();

    final prefs = await SharedPreferences.getInstance();
    expect(container.read(authControllerProvider).status, AuthStatus.signedOut);
    expect(storage.cleared, isTrue);
    expect(authService.deleteCalls, 1);
    expect(prefs.getString('home.feed.cache'), isNull);
    expect(prefs.getBool('onboarding.completed'), isNull);
  });

  testWidgets('ReceiptScanSheet disables import CTA on fallback result', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildShell(
        overrides: [
          receiptControllerProvider.overrideWith(
            (ref) => _FakeReceiptController(
              const ReceiptState(
                status: ReceiptScanStatus.ready,
                receipt: ParsedReceipt(
                  merchant: 'Fallback Receipt',
                  source: ReceiptSource.fallback,
                ),
              ),
            ),
          ),
        ],
        child: const Scaffold(body: ReceiptScanSheet()),
      ),
    );

    expect(
      find.text(AppStrings(AppLocale.tr).scanFallbackAction),
      findsOneWidget,
    );
    expect(
      find.text(AppStrings(AppLocale.tr).importFallbackNextTitle),
      findsOneWidget,
    );
    expect(
      find.text(AppStrings(AppLocale.tr).importFallbackAskUma),
      findsOneWidget,
    );
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('StatementImportSheet disables import CTA on fallback result', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildShell(
        overrides: [
          statementControllerProvider.overrideWith(
            (ref) => _FakeStatementController(
              const StatementState(
                status: StatementStatus.ready,
                statement: ParsedStatement(
                  bank: 'Fallback Bank',
                  source: StatementSource.fallback,
                ),
              ),
            ),
          ),
        ],
        child: const Scaffold(body: StatementImportSheet()),
      ),
    );

    expect(
      find.text(AppStrings(AppLocale.tr).statementFallbackAction),
      findsOneWidget,
    );
    expect(
      find.text(AppStrings(AppLocale.tr).importFallbackManualEntry),
      findsOneWidget,
    );
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });
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

class _MemoryAuthStorage extends AuthStorage {
  _MemoryAuthStorage();

  AuthSession? _session;
  bool cleared = false;

  @override
  Future<AuthSession?> readSession() async => _session;

  @override
  Future<void> writeSession(AuthSession session) async {
    _session = session;
  }

  @override
  Future<void> clearSession() async {
    cleared = true;
    _session = null;
  }
}

class _FakeFirebaseAuthService extends FirebaseAuthService {
  _FakeFirebaseAuthService(Ref ref)
      : super(
          const FirebaseBootstrapState(enabled: false, initialized: false),
          ref,
        );

  int deleteCalls = 0;

  @override
  AuthSession? get currentSession => null;

  @override
  Future<void> deleteAccount() async {
    deleteCalls++;
  }
}

class _FakeReceiptController extends StateNotifier<ReceiptState>
    implements ReceiptController {
  _FakeReceiptController(super.state);

  @override
  void reset() {
    state = const ReceiptState();
  }

  @override
  Future<void> scan({
    required Uint8List bytes,
    required String mimeType,
    required String fileName,
  }) async {}
}

class _FakeStatementController extends StateNotifier<StatementState>
    implements StatementController {
  _FakeStatementController(super.state);

  @override
  void reset() {
    state = const StatementState();
  }

  @override
  Future<void> parse({
    required Uint8List bytes,
    required String mimeType,
    required String fileName,
  }) async {}
}
