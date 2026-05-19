import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vera/core/firebase/firebase_bootstrap.dart';
import 'package:vera/core/orchestration/user_readiness.dart';
import 'package:vera/core/services/gemini_service.dart';
import 'package:vera/core/services/voice_input_service.dart';
import 'package:vera/features/auth/domain/auth_session.dart';
import 'package:vera/features/auth/state/auth_controller.dart';
import 'package:vera/features/home/data/bank.dart';
import 'package:vera/features/home/data/goal.dart';
import 'package:vera/features/home/data/transaction.dart';
import 'package:vera/features/home/state/goals_controller.dart';
import 'package:vera/features/home/state/home_controller.dart';

void main() {
  test('user readiness combines auth, firebase, data, and voice signals', () {
    final container = ProviderContainer(
      overrides: [
        firebaseBootstrapProvider.overrideWith(
          (ref) => const FirebaseBootstrapState(
            enabled: false,
            initialized: false,
          ),
        ),
        authControllerProvider.overrideWith(
          (ref) => _FakeAuthController(
            const AuthSession(
              status: AuthStatus.signedIn,
              userId: 'demo-user',
              authMethod: 'demo vault',
            ),
          ),
        ),
        homeControllerProvider.overrideWith(
          (ref) => _FakeHomeController(
            const HomeState(
              banks: [
                Bank(
                  id: '1',
                  name: 'Garanti',
                  shortCode: 'GAR',
                  last4: '1234',
                  balance: 1200,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
        goalsControllerProvider.overrideWith(
          (ref) => _FakeGoalsController(FinancialGoal.empty),
        ),
        voiceInputControllerProvider.overrideWith(
          (ref) => _FakeVoiceController(
            const VoiceState(status: VoiceStatus.permissionDenied),
          ),
        ),
        geminiServiceProvider.overrideWith(
          (ref) => _FakeGeminiService(isAvailable: false),
        ),
      ],
    );
    addTearDown(container.dispose);

    final readiness = container.read(userReadinessProvider);

    expect(readiness.isDemoSession, isTrue);
    expect(readiness.localOnly, isTrue);
    expect(readiness.firebaseReady, isFalse);
    expect(readiness.geminiReady, isFalse);
    expect(readiness.hasImportedData, isTrue);
    expect(readiness.needsUserData, isFalse);
    expect(readiness.voiceAvailable, isTrue);
  });

  test('user readiness marks missing user data when state is empty', () {
    final container = ProviderContainer(
      overrides: [
        firebaseBootstrapProvider.overrideWith(
          (ref) => const FirebaseBootstrapState(
            enabled: true,
            initialized: true,
          ),
        ),
        authControllerProvider.overrideWith(
          (ref) => _FakeAuthController(
            const AuthSession(
              status: AuthStatus.signedIn,
              userId: 'real-user',
              authMethod: 'firebase_email',
            ),
          ),
        ),
        homeControllerProvider.overrideWith(
          (ref) => _FakeHomeController(const HomeState()),
        ),
        goalsControllerProvider.overrideWith(
          (ref) => _FakeGoalsController(FinancialGoal.empty),
        ),
        voiceInputControllerProvider.overrideWith(
          (ref) => _FakeVoiceController(
            const VoiceState(status: VoiceStatus.unavailable),
          ),
        ),
        geminiServiceProvider.overrideWith(
          (ref) => _FakeGeminiService(isAvailable: true),
        ),
      ],
    );
    addTearDown(container.dispose);

    final readiness = container.read(userReadinessProvider);

    expect(readiness.isDemoSession, isFalse);
    expect(readiness.localOnly, isFalse);
    expect(readiness.firebaseReady, isTrue);
    expect(readiness.geminiReady, isTrue);
    expect(readiness.hasImportedData, isFalse);
    expect(readiness.needsUserData, isTrue);
    expect(readiness.voiceAvailable, isFalse);
  });
}

class _FakeAuthController extends StateNotifier<AuthSession>
    implements AuthController {
  _FakeAuthController(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHomeController extends StateNotifier<HomeState>
    implements HomeController {
  _FakeHomeController(super.state);

  @override
  Future<void> addBank(Bank bank) async {}

  @override
  Future<int> addImportedTransactions(List<Txn> txns) async =>
      state.transactions.length;

  @override
  Future<void> clearImported() async {}

  @override
  Future<void> refresh() async {}

  @override
  Future<void> removeCustomBank(String id) async {}

  @override
  Future<void> resetDemoState() async {}
}

class _FakeGoalsController extends StateNotifier<FinancialGoal>
    implements GoalsController {
  _FakeGoalsController(super.state);

  @override
  Future<void> reset() async {}

  @override
  Future<void> setGoal({
    required double target,
    double saved = 0,
    double monthlyContribution = 0,
  }) async {}

  @override
  Future<void> updateGoal({double? target, double? saved}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeVoiceController extends StateNotifier<VoiceState>
    implements VoiceInputController {
  _FakeVoiceController(super.state);

  @override
  Future<void> start({required void Function(String text) onFinalResult}) async {}

  @override
  Future<void> stop() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGeminiService implements GeminiService {
  _FakeGeminiService({required this.isAvailable});

  @override
  final bool isAvailable;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
