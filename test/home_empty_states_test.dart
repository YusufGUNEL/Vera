import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vera/core/localization/app_locale.dart';
import 'package:vera/core/localization/app_strings.dart';
import 'package:vera/core/theme/app_tokens.dart';
import 'package:vera/core/theme/palette.dart';
import 'package:vera/core/theme/vibe.dart';
import 'package:vera/features/home/data/bank.dart';
import 'package:vera/features/home/data/transaction.dart';
import 'package:vera/features/home/data/upcoming_bill.dart';
import 'package:vera/features/home/presentation/widgets/proactive_insight_card.dart';
import 'package:vera/features/home/presentation/widgets/connected_banks.dart';
import 'package:vera/features/home/presentation/widgets/goal_card.dart';
import 'package:vera/features/home/presentation/widgets/home_first_steps_card.dart';
import 'package:vera/features/home/presentation/widgets/uma_insight_strip.dart';
import 'package:vera/features/home/state/home_controller.dart';
import 'package:vera/features/home/state/upcoming_bills_controller.dart';
import 'package:vera/features/subscriptions/state/subscriptions_controller.dart';

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

    testWidgets('UmaInsightStrip renders contextual CTA label', (tester) async {
      await tester.pumpWidget(
        _buildTestShell(
          child: const Scaffold(
            body: UmaInsightStrip(
              text: 'Henüz işlem görünmüyor.',
              ctaLabel: 'İlk işlemi ekle',
            ),
          ),
        ),
      );

      expect(find.text('UMA İÇGÖRÜ'), findsOneWidget);
      expect(find.text('Henüz işlem görünmüyor.'), findsOneWidget);
      expect(find.text('İlk işlemi ekle'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
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

    testWidgets('ProactiveInsightCard shows import fallback when no data exists', (tester) async {
      await tester.pumpWidget(
        _buildTestShell(
          overrides: [
            homeControllerProvider.overrideWith((ref) => _FakeHomeController(
                  const HomeState(),
                )),
            subscriptionsControllerProvider.overrideWith(
              (ref) => _FakeSubscriptionsController(
                const SubscriptionsState(),
              ),
            ),
            upcomingBillsControllerProvider.overrideWith(
              (ref) => _FakeUpcomingBillsController(const []),
            ),
          ],
          child: const Scaffold(
            body: ProactiveInsightCard(),
          ),
        ),
      );

      expect(find.text('Vera henüz izlenecek sinyal bulmadı'), findsOneWidget);
      expect(find.text('Ekstre yükle'), findsOneWidget);
    });

    testWidgets('ProactiveInsightCard shows healthy state when data exists without risk', (tester) async {
      final txns = [
        const Txn(
          id: 1,
          name: 'Migros',
          category: 'market',
          icon: Icons.shopping_bag_outlined,
          amount: -250,
          when: 'Bugün',
          color: Colors.green,
        ),
      ];

      await tester.pumpWidget(
        _buildTestShell(
          overrides: [
            homeControllerProvider.overrideWith((ref) => _FakeHomeController(
                  HomeState(transactions: txns),
                )),
            subscriptionsControllerProvider.overrideWith(
              (ref) => _FakeSubscriptionsController(
                const SubscriptionsState(),
              ),
            ),
            upcomingBillsControllerProvider.overrideWith(
              (ref) => _FakeUpcomingBillsController(const []),
            ),
          ],
          child: const Scaffold(
            body: ProactiveInsightCard(),
          ),
        ),
      );

      expect(find.text('Şimdilik kritik bir sinyal yok'), findsOneWidget);
      expect(find.text('Uma yorumlasın'), findsOneWidget);
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

class _FakeHomeController extends StateNotifier<HomeState> implements HomeController {
  _FakeHomeController(super.state);

  @override
  Future<void> addBank(Bank bank) async {}

  @override
  Future<int> addImportedTransactions(List<Txn> txns) async => state.transactions.length;

  @override
  Future<void> clearImported() async {}

  @override
  Future<void> refresh() async {}

  @override
  Future<void> removeCustomBank(String id) async {}

  @override
  Future<void> resetDemoState() async {}
}

class _FakeSubscriptionsController extends StateNotifier<SubscriptionsState>
    implements SubscriptionsController {
  _FakeSubscriptionsController(super.state);

  @override
  void setFilter(SubscriptionFilter filter) {}
}

class _FakeUpcomingBillsController extends StateNotifier<List<UpcomingBill>>
    implements UpcomingBillsController {
  _FakeUpcomingBillsController(super.state);

  @override
  Future<void> add(UpcomingBill bill) async {}

  @override
  Future<void> clear() async {}

  @override
  Future<void> refresh() async {}

  @override
  Future<void> remove(String id) async {}

  @override
  Future<void> update(UpcomingBill bill) async {}
}
