import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../home/data/bank.dart';
import '../../home/data/banks_store.dart';
import '../../home/data/firebase_banks_service.dart';
import '../../home/data/firebase_imported_transactions_service.dart';
import '../../home/data/firebase_upcoming_bills_service.dart';
import '../../home/data/goal.dart';
import '../../home/data/goals_store.dart';
import '../../home/data/imported_transactions_store.dart';
import '../../home/data/transaction.dart';
import '../../home/data/upcoming_bill.dart';
import '../../home/data/upcoming_bills_store.dart';

/// Populates the local stores with a single realistic sample dataset so the
/// "Try sample account" flow lands on a non-empty home — banks, transactions
/// (designed to trigger subscription detection and one fraud-heuristic
/// signal), upcoming bills, and a partially funded emergency goal.
///
/// Lives ONLY on the demo path; signed-up real users still start empty.
class DemoSeeder {
  const DemoSeeder(
    this._banks,
    this._transactions,
    this._bills,
    this._goals,
  );

  final BanksStore _banks;
  final ImportedTransactionsStore _transactions;
  final UpcomingBillsStore _bills;
  final GoalsStore _goals;

  Future<void> seed(AppStrings l10n) async {
    await Future.wait([
      _seedBanks(l10n),
      _seedTransactions(l10n),
      _seedBills(l10n),
      _seedGoal(),
    ]);
  }

  Future<void> _seedBanks(AppStrings l10n) async {
    final existing = await _banks.load();
    if (existing.isNotEmpty) return;
    await _banks.add(Bank(
      id: 'demo-bank-primary',
      name: l10n.demoBankPrimary,
      shortCode: 'VBC',
      balance: 42150.75,
      color: const Color(0xFF7C3AED),
      last4: '4242',
    ));
    await _banks.add(Bank(
      id: 'demo-bank-savings',
      name: l10n.demoBankSavings,
      shortCode: 'VBS',
      balance: 18000.00,
      color: const Color(0xFF22C55E),
      last4: '8901',
    ));
  }

  Future<void> _seedTransactions(AppStrings l10n) async {
    final existing = await _transactions.load();
    if (existing.isNotEmpty) return;

    final base = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final today = l10n.todayAt('14:32');
    final txns = <Txn>[
      // Income (this month)
      Txn(
        id: base + 1,
        name: l10n.demoTxnSalary,
        category: l10n.categorySalary,
        icon: Icons.work_outline,
        amount: 35000,
        when: today,
        color: const Color(0xFF2F8B5C),
      ),
      Txn(
        id: base + 2,
        name: l10n.demoTxnFamilyIncoming,
        category: l10n.categoryTransfer,
        icon: Icons.south_west,
        amount: 5000,
        when: today,
        color: const Color(0xFF2F8B5C),
      ),

      // Recurring subscriptions (2x each → detection fires)
      Txn(
        id: base + 10,
        name: 'Netflix',
        category: l10n.categorySubscription,
        icon: Icons.movie_outlined,
        amount: -149.99,
        when: today,
        color: const Color(0xFFC03A2B),
      ),
      Txn(
        id: base + 11,
        name: 'Netflix',
        category: l10n.categorySubscription,
        icon: Icons.movie_outlined,
        amount: -149.99,
        when: today,
        color: const Color(0xFFC03A2B),
      ),
      Txn(
        id: base + 12,
        name: 'Spotify',
        category: l10n.categorySubscription,
        icon: Icons.headphones_outlined,
        amount: -59.99,
        when: today,
        color: const Color(0xFFC03A2B),
      ),
      Txn(
        id: base + 13,
        name: 'Spotify',
        category: l10n.categorySubscription,
        icon: Icons.headphones_outlined,
        amount: -59.99,
        when: today,
        color: const Color(0xFFC03A2B),
      ),

      // Everyday spending
      Txn(
        id: base + 20,
        name: l10n.demoTxnGrocery,
        category: l10n.categoryMarket,
        icon: Icons.shopping_cart_outlined,
        amount: -847.30,
        when: today,
        color: const Color(0xFFE67E22),
      ),
      Txn(
        id: base + 21,
        name: l10n.demoTxnGrocery,
        category: l10n.categoryMarket,
        icon: Icons.shopping_cart_outlined,
        amount: -512.80,
        when: today,
        color: const Color(0xFFE67E22),
      ),
      Txn(
        id: base + 22,
        name: l10n.demoTxnFuel,
        category: l10n.categoryFuel,
        icon: Icons.local_gas_station_outlined,
        amount: -1250.00,
        when: today,
        color: const Color(0xFF34495E),
      ),
      Txn(
        id: base + 23,
        name: l10n.demoTxnRestaurant,
        category: l10n.categoryFood,
        icon: Icons.local_cafe_outlined,
        amount: -425.50,
        when: today,
        color: const Color(0xFF8E5A3C),
      ),
      Txn(
        id: base + 24,
        name: l10n.demoTxnPharmacy,
        category: l10n.categoryHealth,
        icon: Icons.local_hospital_outlined,
        amount: -187.20,
        when: today,
        color: const Color(0xFFC03A2B),
      ),

      // Rent (large recurring outflow)
      Txn(
        id: base + 30,
        name: l10n.demoTxnRent,
        category: l10n.categoryBill,
        icon: Icons.home_outlined,
        amount: -12500.00,
        when: today,
        color: const Color(0xFF8E44AD),
      ),

      // Manual savings transfer
      Txn(
        id: base + 40,
        name: l10n.demoTxnTransfer,
        category: l10n.categoryTransfer,
        icon: Icons.send_outlined,
        amount: -2500.00,
        when: today,
        color: const Color(0xFF2D5FB0),
      ),

      // ATM withdrawal
      Txn(
        id: base + 41,
        name: l10n.demoTxnAtm,
        category: l10n.categoryTransfer,
        icon: Icons.local_atm_outlined,
        amount: -1000.00,
        when: today,
        color: const Color(0xFF2D5FB0),
      ),

      // Round outlier — surfaces in fraud heuristic (>=10k, ends in 000,
      // and 3-6x median expense)
      Txn(
        id: base + 50,
        name: 'EFT',
        category: l10n.categoryTransfer,
        icon: Icons.send_outlined,
        amount: -15000.00,
        when: today,
        color: const Color(0xFF2D5FB0),
      ),
    ];

    await _transactions.append(txns);
  }

  Future<void> _seedBills(AppStrings l10n) async {
    final existing = await _bills.load();
    if (existing.isNotEmpty) return;

    final now = DateTime.now();
    DateTime daysFromNow(int d) =>
        DateTime(now.year, now.month, now.day).add(Duration(days: d));

    await _bills.add(UpcomingBill(
      id: 'demo-bill-credit-card',
      name: l10n.demoBillCreditCard,
      amount: 3850.40,
      dueDate: daysFromNow(3),
      iconCode: Icons.credit_card.codePoint,
      accentColor: 0xFFC03A2B,
    ));
    await _bills.add(UpcomingBill(
      id: 'demo-bill-electric',
      name: l10n.demoBillElectric,
      amount: 612.30,
      dueDate: daysFromNow(8),
      iconCode: Icons.bolt.codePoint,
      accentColor: 0xFFE67E22,
    ));
    await _bills.add(UpcomingBill(
      id: 'demo-bill-internet',
      name: l10n.demoBillInternet,
      amount: 549.00,
      dueDate: daysFromNow(15),
      iconCode: Icons.wifi.codePoint,
      accentColor: 0xFF2980B9,
    ));
  }

  Future<void> _seedGoal() async {
    final existing = await _goals.load();
    if (existing.target > 0) return;
    await _goals.save(const FinancialGoal(
      target: 60000,
      saved: 18000,
      monthlyContribution: 2500,
    ));
  }
}

/// Builds the seeder from the underlying Firebase services rather than from
/// the auth-aware *StoreProviders, so importing this provider does not pull
/// `authControllerProvider` into a dependency cycle.
final demoSeederProvider = Provider<DemoSeeder>((ref) {
  return DemoSeeder(
    BanksStore(ref.watch(firebaseBanksServiceProvider)),
    ImportedTransactionsStore(
      ref.watch(firebaseImportedTransactionsServiceProvider),
    ),
    UpcomingBillsStore(ref.watch(firebaseUpcomingBillsServiceProvider)),
    const GoalsStore(),
  );
});
