import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/data/transaction.dart';
import '../../home/state/home_controller.dart';
import '../data/subscriptions_repository.dart';
import '../domain/subscription_alert.dart';
import '../domain/subscription_item.dart';
import '../domain/subscription_status.dart';

enum SubscriptionFilter { all, attention, unused, priceChanges }

class SubscriptionsState {
  const SubscriptionsState({
    this.items = const [],
    this.alerts = const [],
    this.insight = '',
    this.filter = SubscriptionFilter.all,
  });

  final List<SubscriptionItem> items;
  final List<SubscriptionAlert> alerts;
  final String insight;
  final SubscriptionFilter filter;

  List<SubscriptionItem> get visibleItems {
    return switch (filter) {
      SubscriptionFilter.all => items,
      SubscriptionFilter.attention =>
        items.where((item) => item.status.needsAttention).toList(),
      SubscriptionFilter.unused => items
          .where((item) => item.status == SubscriptionStatus.unused)
          .toList(),
      SubscriptionFilter.priceChanges => items
          .where((item) => item.status == SubscriptionStatus.priceIncreased)
          .toList(),
    };
  }

  double get monthlyTotal =>
      items.fold<double>(0, (sum, item) => sum + item.monthlyPrice);

  int get attentionCount =>
      items.where((item) => item.status.needsAttention).length;

  SubscriptionsState copyWith({
    List<SubscriptionItem>? items,
    List<SubscriptionAlert>? alerts,
    String? insight,
    SubscriptionFilter? filter,
  }) {
    return SubscriptionsState(
      items: items ?? this.items,
      alerts: alerts ?? this.alerts,
      insight: insight ?? this.insight,
      filter: filter ?? this.filter,
    );
  }
}

class SubscriptionsController extends StateNotifier<SubscriptionsState> {
  SubscriptionsController(this._repository, this._ref)
      : super(const SubscriptionsState()) {
    _load();
    _sub = _ref.listen<List<Txn>>(
      homeControllerProvider.select((s) => s.transactions),
      (_, __) => _load(),
    );
  }

  final SubscriptionsRepository _repository;
  final Ref _ref;
  ProviderSubscription<List<Txn>>? _sub;

  void _load() {
    final txns = _ref.read(homeControllerProvider).transactions;
    final items = _repository.getSubscriptions(userTxns: txns);
    state = state.copyWith(
      items: items,
      alerts: _repository.buildAlerts(items),
      insight: _repository.buildInsight(items),
    );
  }

  void setFilter(SubscriptionFilter filter) {
    state = state.copyWith(filter: filter);
  }

  @override
  void dispose() {
    _sub?.close();
    super.dispose();
  }
}

final subscriptionsControllerProvider =
    StateNotifierProvider<SubscriptionsController, SubscriptionsState>((ref) {
  return SubscriptionsController(
    ref.watch(subscriptionsRepositoryProvider),
    ref,
  );
});
