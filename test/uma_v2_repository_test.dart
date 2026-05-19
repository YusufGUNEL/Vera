import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vera/core/firebase/analytics_service.dart';
import 'package:vera/core/firebase/firebase_bootstrap.dart';
import 'package:vera/core/firebase/remote_config_service.dart';
import 'package:vera/core/localization/app_locale.dart';
import 'package:vera/core/localization/locale_controller.dart';
import 'package:vera/core/services/gemini_service.dart';
import 'package:vera/core/services/voice_input_service.dart';
import 'package:vera/features/auth/data/firebase_auth_service.dart';
import 'package:vera/features/auth/domain/auth_session.dart';
import 'package:vera/features/auth/state/auth_controller.dart';
import 'package:vera/features/home/data/bank.dart';
import 'package:vera/features/home/data/goal.dart';
import 'package:vera/features/home/data/transaction.dart';
import 'package:vera/features/home/data/upcoming_bill.dart';
import 'package:vera/features/home/state/goals_controller.dart';
import 'package:vera/features/home/state/home_controller.dart';
import 'package:vera/features/home/state/upcoming_bills_controller.dart';
import 'package:vera/features/subscriptions/state/subscriptions_controller.dart';
import 'package:vera/features/uma_chat/data/firebase_uma_audit_store.dart';
import 'package:vera/features/uma_chat/data/firebase_uma_feedback_store.dart';
import 'package:vera/features/uma_chat/data/firebase_uma_memory_store.dart';
import 'package:vera/features/uma_chat/data/uma_audit_store.dart';
import 'package:vera/features/uma_chat/data/uma_feedback_store.dart';
import 'package:vera/features/uma_chat/data/uma_memory_store.dart';
import 'package:vera/features/uma_chat/data/uma_repository.dart';
import 'package:vera/features/uma_chat/domain/uma_feedback.dart';
import 'package:vera/features/uma_chat/domain/uma_response.dart';
import 'package:vera/features/subscriptions/domain/subscription_alert.dart';
import 'package:vera/features/subscriptions/domain/subscription_item.dart';
import 'package:vera/features/subscriptions/domain/subscription_status.dart';
import 'package:vera/features/wealth/domain/autonomy_policy.dart';
import 'package:vera/features/wealth/domain/portfolio_allocation.dart';
import 'package:vera/features/wealth/domain/rebalance_action.dart';
import 'package:vera/features/wealth/state/wealth_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('deterministic spending answer includes grounded sources', () async {
    final container = _buildContainer();
    addTearDown(container.dispose);

    final repo = container.read(umaRepositoryProvider);
    final reply = await repo.handle('Bu ay harcamalarimi analiz et');

    expect(reply.envelope, isNotNull);
    expect(reply.envelope!.kind, UmaResponseKind.answer);
    expect(reply.envelope!.sources, isNotEmpty);
    expect(
      reply.envelope!.sources.any(
        (source) => source.type == UmaSourceType.transaction,
      ),
      isTrue,
    );
    expect(reply.envelope!.confidence, greaterThan(0.5));
  });

  test('tool requests become confirmation-first proposals in strict mode', () async {
    final container = _buildContainer(
      gemini: _FakeGeminiService(
        onRunAgent: ({required onCall}) async {
          await onCall('add_expense', {
            'name': 'Migros',
            'amount_tl': 420,
            'category': 'market',
          });
          return const AgentResult(text: '', calls: []);
        },
      ),
    );
    addTearDown(container.dispose);

    final repo = container.read(umaRepositoryProvider);
    final reply = await repo.handle('Migros 420 TL harcadim', requireConfirmation: true);

    expect(reply.envelope, isNotNull);
    expect(reply.envelope!.kind, UmaResponseKind.proposal);
    expect(reply.envelope!.pendingToolCall, isNotNull);
    expect(
      reply.envelope!.toolPolicy?.status,
      UmaToolPolicyStatus.needsConfirmation,
    );
  });

  test('feedback updates memory profile for personalization', () async {
    final container = _buildContainer();
    addTearDown(container.dispose);

    final repo = container.read(umaRepositoryProvider);
    await repo.rememberFeedback(vote: UmaFeedbackVote.helpful, note: 'Good');

    final profile =
        await container.read(firebaseUmaMemoryStoreProvider).loadProfile();
    expect(profile.helpfulFeedbackCount, 1);
    expect(profile.riskTone, 'calm');
  });
}

ProviderContainer _buildContainer({
  _FakeGeminiService? gemini,
}) {
  return ProviderContainer(
    overrides: [
      localeControllerProvider.overrideWith((ref) => _FakeLocaleController()),
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
      voiceInputControllerProvider.overrideWith(
        (ref) => _FakeVoiceController(
          const VoiceState(status: VoiceStatus.idle),
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
                balance: 55000,
                color: Colors.green,
                last4: '1234',
              ),
            ],
            transactions: [
              Txn(
                id: 1,
                name: 'Migros',
                category: 'Market',
                icon: Icons.shopping_cart_outlined,
                amount: -420,
                when: 'Bugun',
                color: Colors.green,
              ),
              Txn(
                id: 2,
                name: 'Shell',
                category: 'Fuel',
                icon: Icons.local_gas_station_outlined,
                amount: -900,
                when: 'Dun',
                color: Colors.orange,
              ),
            ],
          ),
        ),
      ),
      goalsControllerProvider.overrideWith(
        (ref) => _FakeGoalsController(
          const FinancialGoal(
            target: 100000,
            saved: 20000,
            monthlyContribution: 4000,
          ),
        ),
      ),
      upcomingBillsControllerProvider.overrideWith(
        (ref) => _FakeUpcomingBillsController(
              [
                UpcomingBill(
                  id: 'bill-1',
                  name: 'Kart ekstresi',
                  amount: 12500,
                  dueDate: DateTime(2026, 6, 12),
                  iconCode: 0,
                  accentColor: 0xFF000000,
                ),
          ],
        ),
      ),
      subscriptionsControllerProvider.overrideWith(
        (ref) => _FakeSubscriptionsController(
          const SubscriptionsState(
            items: [
              SubscriptionItem(
                id: 'sub-1',
                name: 'Netflix',
                vendor: 'Netflix',
                category: 'Video',
                monthlyPrice: 229,
                previousPrice: 199,
                status: SubscriptionStatus.healthy,
                renewalLabel: '12 June',
                lastUsedLabel: 'Yesterday',
                recommendation: 'Keep',
                icon: Icons.subscriptions_outlined,
              ),
            ],
            alerts: <SubscriptionAlert>[],
          ),
        ),
      ),
      wealthControllerProvider.overrideWith(
        (ref) => _FakeWealthController(
          const WealthState(
            policy: AutonomyPolicy(
              enabled: false,
              approvalMode: ApprovalMode.confirmLargeMoves,
              monthlyMoveLimit: 0,
              riskProfile: 'balanced',
            ),
            allocations: [
              PortfolioAllocation(
                label: 'Cash',
                amount: 15000,
                weight: 100,
                paletteKey: 'cash',
              ),
            ],
            actions: <RebalanceAction>[],
            insight: '',
          ),
        ),
      ),
      geminiServiceProvider.overrideWith(
        (ref) => gemini ?? _FakeGeminiService(),
      ),
      remoteConfigServiceProvider.overrideWith(
        (ref) => RemoteConfigService(
          const FirebaseBootstrapState(enabled: false, initialized: false),
        ),
      ),
      analyticsServiceProvider.overrideWith(
        (ref) => AnalyticsService(
          const FirebaseBootstrapState(enabled: false, initialized: false),
        ),
      ),
      firebaseAuthServiceProvider.overrideWith(
        (ref) => _FakeFirebaseAuthService(ref),
      ),
      firebaseUmaFeedbackStoreProvider.overrideWith(
        (ref) => FirebaseUmaFeedbackStore(
          const FirebaseBootstrapState(enabled: false, initialized: false),
          ref.read(firebaseAuthServiceProvider),
          ref.read(umaFeedbackStoreProvider),
        ),
      ),
      firebaseUmaAuditStoreProvider.overrideWith(
        (ref) => FirebaseUmaAuditStore(
          const FirebaseBootstrapState(enabled: false, initialized: false),
          ref.read(firebaseAuthServiceProvider),
          ref.read(umaAuditStoreProvider),
        ),
      ),
      firebaseUmaMemoryStoreProvider.overrideWith(
        (ref) => FirebaseUmaMemoryStore(
          const FirebaseBootstrapState(enabled: false, initialized: false),
          ref.read(firebaseAuthServiceProvider),
          ref.read(umaMemoryStoreProvider),
        ),
      ),
    ],
  );
}

class _FakeGeminiService implements GeminiService {
  _FakeGeminiService({this.onRunAgent});

  final Future<AgentResult> Function({
    required Future<Map<String, Object?>> Function(
      String name,
      Map<String, Object?> args,
    )
    onCall,
  })? onRunAgent;

  @override
  bool get isAvailable => true;

  @override
  Future<AgentResult> runAgent({
    required String prompt,
    required List<Tool> tools,
    required Future<Map<String, Object?>> Function(
      String name,
      Map<String, Object?> args,
    )
    onCall,
    int maxIterations = 3,
  }) async {
    if (onRunAgent != null) {
      return onRunAgent!(onCall: onCall);
    }
    return const AgentResult(
      text: 'Harcama analizini mevcut işlem geçmişine göre hazırladım.',
      calls: [],
      payload: {
        'answer': 'Harcama analizini mevcut işlem geçmişine göre hazırladım.',
        'confidence': 0.82,
        'why': 'Son işlem ve kategori sinyallerine dayanıyorum.',
      },
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthController extends StateNotifier<AuthSession>
    implements AuthController {
  _FakeAuthController(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeLocaleController extends StateNotifier<AppLocale>
    implements LocaleController {
  _FakeLocaleController() : super(AppLocale.tr);

  @override
  Future<void> setLocale(AppLocale locale) async {
    state = locale;
  }
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

class _FakeHomeController extends StateNotifier<HomeState>
    implements HomeController {
  _FakeHomeController(super.state);

  @override
  Future<void> addBank(Bank bank) async {}

  @override
  Future<int> addImportedTransactions(List<Txn> txns) async =>
      state.transactions.length + txns.length;

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
  }) async {
    state = FinancialGoal(
      target: target,
      saved: saved,
      monthlyContribution: monthlyContribution,
    );
  }

  @override
  Future<void> updateGoal({double? target, double? saved}) async {}
}

class _FakeUpcomingBillsController extends StateNotifier<List<UpcomingBill>>
    implements UpcomingBillsController {
  _FakeUpcomingBillsController(super.state);

  @override
  Future<void> add(UpcomingBill bill) async {
    state = [...state, bill];
  }

  @override
  Future<void> clear() async {}

  @override
  Future<void> refresh() async {}

  @override
  Future<void> remove(String id) async {}

  @override
  Future<void> update(UpcomingBill bill) async {}
}

class _FakeSubscriptionsController extends StateNotifier<SubscriptionsState>
    implements SubscriptionsController {
  _FakeSubscriptionsController(super.state);

  @override
  void setFilter(SubscriptionFilter filter) {}
}

class _FakeWealthController extends StateNotifier<WealthState>
    implements WealthController {
  _FakeWealthController(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFirebaseAuthService extends FirebaseAuthService {
  _FakeFirebaseAuthService(Ref ref)
      : super(
          const FirebaseBootstrapState(enabled: false, initialized: false),
          ref,
        );
}
