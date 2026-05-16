import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/bank.dart';
import '../data/banks_store.dart';
import '../data/home_feed_repository.dart';
import '../data/imported_transactions_store.dart';
import '../data/transaction.dart';
import '../domain/home_feed_data.dart';
import 'balance_controller.dart';

class HomeState {
  const HomeState({
    this.banks = const [],
    this.transactions = const [],
    this.insight = '',
    this.lastUpdated,
    this.refreshing = false,
  });

  final List<Bank> banks;
  final List<Txn> transactions;
  final String insight;
  final DateTime? lastUpdated;
  final bool refreshing;

  String? get lastUpdatedTime {
    final dt = lastUpdated;
    if (dt == null) return null;
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  HomeState copyWith({
    List<Bank>? banks,
    List<Txn>? transactions,
    String? insight,
    DateTime? lastUpdated,
    bool? refreshing,
  }) {
    return HomeState(
      banks: banks ?? this.banks,
      transactions: transactions ?? this.transactions,
      insight: insight ?? this.insight,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      refreshing: refreshing ?? this.refreshing,
    );
  }
}

class HomeController extends StateNotifier<HomeState> {
  HomeController(this._repository, this._imports, this._banksStore, this._ref)
      : super(const HomeState()) {
    _bootstrap();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => refresh());
  }

  final HomeFeedRepository _repository;
  final ImportedTransactionsStore _imports;
  final BanksStore _banksStore;
  final Ref _ref;
  Timer? _timer;
  List<Txn> _imported = const [];
  List<Bank> _customBanks = const [];
  HomeFeedData? _feed;

  Future<void> _bootstrap() async {
    _imported = await _imports.load();
    _customBanks = await _banksStore.load();
    final cached = await _repository.loadCached();
    if (cached != null) {
      _feed = cached;
      _apply(cached);
    }
    await refresh();
  }

  Future<void> refresh() async {
    if (state.refreshing) return;
    state = state.copyWith(refreshing: true);
    final data = await _repository.refresh();
    _feed = data;
    _apply(data);
    state = state.copyWith(refreshing: false);
  }

  /// Prepends OCR / statement imports to the visible transaction list and
  /// persists them. Returns the new list size for the caller to show feedback.
  Future<int> addImportedTransactions(List<Txn> txns) async {
    if (txns.isEmpty) return _imported.length;
    _imported = [...txns, ..._imported];
    await _imports.save(_imported);
    final feed = _feed;
    if (feed != null) _apply(feed);
    return _imported.length;
  }

  Future<void> clearImported() async {
    _imported = const [];
    await _imports.clear();
    final feed = _feed;
    if (feed != null) _apply(feed);
  }

  /// Wipes user-added state (imports + custom banks) so the demo starts fresh.
  /// Goal progress lives in [goalsControllerProvider] and is reset separately.
  Future<void> resetDemoState() async {
    _imported = const [];
    _customBanks = const [];
    await _imports.clear();
    await _banksStore.clear();
    final feed = _feed;
    if (feed != null) _apply(feed);
  }

  /// Adds a user-defined bank, persists it, and updates state.
  Future<void> addBank(Bank bank) async {
    _customBanks = await _banksStore.add(bank);
    final feed = _feed;
    if (feed != null) _apply(feed);
  }

  /// Removes a user-defined bank (preset banks from the feed can't be removed).
  Future<void> removeCustomBank(String id) async {
    _customBanks = await _banksStore.remove(id);
    final feed = _feed;
    if (feed != null) _apply(feed);
  }

  void _apply(HomeFeedData data) {
    final allBanks = [...data.banks, ..._customBanks];
    final totalBalance =
        allBanks.fold<double>(0, (sum, b) => sum + b.balance);
    _ref.read(balanceProvider.notifier).setBalance(totalBalance);
    state = state.copyWith(
      banks: allBanks,
      transactions: [..._imported, ...data.transactions],
      insight: data.insight,
      lastUpdated: data.lastUpdated,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final homeControllerProvider =
    StateNotifierProvider<HomeController, HomeState>((ref) {
  return HomeController(
    ref.watch(homeFeedRepositoryProvider),
    ref.watch(importedTransactionsStoreProvider),
    ref.watch(banksStoreProvider),
    ref,
  );
});
