import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/bank.dart';
import '../data/home_feed_repository.dart';
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

  String get refreshedLabel {
    if (lastUpdated == null) return 'Waiting for first sync';
    final dt = lastUpdated!;
    return 'Updated ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
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
  HomeController(this._repository, this._ref) : super(const HomeState()) {
    _bootstrap();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => refresh());
  }

  final HomeFeedRepository _repository;
  final Ref _ref;
  Timer? _timer;

  Future<void> _bootstrap() async {
    final cached = await _repository.loadCached();
    if (cached != null) {
      _apply(cached);
    }
    await refresh();
  }

  Future<void> refresh() async {
    if (state.refreshing) return;
    state = state.copyWith(refreshing: true);
    final data = await _repository.refresh();
    _apply(data);
    state = state.copyWith(refreshing: false);
  }

  void _apply(HomeFeedData data) {
    _ref.read(balanceProvider.notifier).setBalance(data.totalBalance);
    state = state.copyWith(
      banks: data.banks,
      transactions: data.transactions,
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
  return HomeController(ref.watch(homeFeedRepositoryProvider), ref);
});
