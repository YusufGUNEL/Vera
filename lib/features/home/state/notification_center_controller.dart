import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/utils/formatters.dart';
import '../../security/state/security_controller.dart';
import '../../subscriptions/domain/subscription_status.dart';
import '../../subscriptions/state/subscriptions_controller.dart';
import '../data/notification_center_store.dart';
import '../data/upcoming_bill.dart';
import 'upcoming_bills_controller.dart';

enum NoticeAccent { red, gold, muted, blue }

class AppNotice {
  const AppNotice({
    required this.id,
    required this.icon,
    required this.title,
    required this.body,
    required this.accent,
    required this.when,
    this.isRead = false,
    this.isDismissed = false,
  });

  final String id;
  final IconData icon;
  final String title;
  final String body;
  final NoticeAccent accent;
  final String when;
  final bool isRead;
  final bool isDismissed;

  AppNotice copyWith({
    bool? isRead,
    bool? isDismissed,
  }) {
    return AppNotice(
      id: id,
      icon: icon,
      title: title,
      body: body,
      accent: accent,
      when: when,
      isRead: isRead ?? this.isRead,
      isDismissed: isDismissed ?? this.isDismissed,
    );
  }
}

class NotificationCenterState {
  const NotificationCenterState({
    this.notices = const [],
    this.localState = const {},
    this.hydrated = false,
  });

  final List<AppNotice> notices;
  final Map<String, NoticeLocalState> localState;
  final bool hydrated;

  List<AppNotice> get visibleNotices => notices
      .where((notice) => !notice.isRead && !notice.isDismissed)
      .toList(growable: false);

  int get unreadCount => visibleNotices.length;

  NotificationCenterState copyWith({
    List<AppNotice>? notices,
    Map<String, NoticeLocalState>? localState,
    bool? hydrated,
  }) {
    return NotificationCenterState(
      notices: notices ?? this.notices,
      localState: localState ?? this.localState,
      hydrated: hydrated ?? this.hydrated,
    );
  }
}

class NotificationCenterController
    extends StateNotifier<NotificationCenterState> {
  NotificationCenterController(
    this._store,
    this._ref,
  ) : super(const NotificationCenterState()) {
    _bootstrap();
    _securitySub = _ref.listen<SecurityState>(
      securityControllerProvider,
      (_, __) => _rebuild(),
    );
    _subscriptionsSub = _ref.listen<SubscriptionsState>(
      subscriptionsControllerProvider,
      (_, __) => _rebuild(),
    );
    _billsSub = _ref.listen<List<UpcomingBill>>(
      upcomingBillsControllerProvider,
      (_, __) => _rebuild(),
    );
  }

  final NotificationCenterStore _store;
  final Ref _ref;
  ProviderSubscription<SecurityState>? _securitySub;
  ProviderSubscription<SubscriptionsState>? _subscriptionsSub;
  ProviderSubscription<List<UpcomingBill>>? _billsSub;

  Future<void> _bootstrap() async {
    final localState = await _store.load();
    if (!mounted) return;
    state = state.copyWith(localState: localState, hydrated: true);
    _rebuild();
  }

  Future<void> markRead(String id) async {
    final next = {
      ...state.localState,
      id: (state.localState[id] ?? const NoticeLocalState()).copyWith(
        isRead: true,
        updatedAt: DateTime.now(),
      ),
    };
    await _persistAndRebuild(next);
  }

  Future<void> dismiss(String id) async {
    final next = {
      ...state.localState,
      id: (state.localState[id] ?? const NoticeLocalState()).copyWith(
        isRead: true,
        isDismissed: true,
        updatedAt: DateTime.now(),
      ),
    };
    await _persistAndRebuild(next);
  }

  Future<void> markAllRead() async {
    if (state.visibleNotices.isEmpty) return;
    final now = DateTime.now();
    final next = {...state.localState};
    for (final notice in state.visibleNotices) {
      next[notice.id] = (next[notice.id] ?? const NoticeLocalState()).copyWith(
        isRead: true,
        updatedAt: now,
      );
    }
    await _persistAndRebuild(next);
  }

  Future<void> dismissAllVisible() async {
    if (state.visibleNotices.isEmpty) return;
    final now = DateTime.now();
    final next = {...state.localState};
    for (final notice in state.visibleNotices) {
      next[notice.id] = (next[notice.id] ?? const NoticeLocalState()).copyWith(
        isRead: true,
        isDismissed: true,
        updatedAt: now,
      );
    }
    await _persistAndRebuild(next);
  }

  Future<void> _persistAndRebuild(
    Map<String, NoticeLocalState> localState,
  ) async {
    state = state.copyWith(localState: localState);
    await _store.save(localState);
    if (!mounted) return;
    _rebuild();
  }

  void _rebuild() {
    final strings = AppStrings(_ref.read(localeControllerProvider));
    final security = _ref.read(securityControllerProvider);
    final subscriptions = _ref.read(subscriptionsControllerProvider);
    final bills = _ref.read(upcomingBillsControllerProvider);
    final next = <AppNotice>[
      for (final check in security.checks.where((c) => c.blocked).take(3))
        _withLocalState(
          AppNotice(
            id: 'security:${check.id}:${check.name}:${check.when}',
            icon: Icons.shield_outlined,
            title: check.name,
            body: check.reason ?? strings.notifBlockedDefault,
            accent: NoticeAccent.red,
            when: check.when,
          ),
        ),
      for (final sub in subscriptions.items
          .where((s) => s.status == SubscriptionStatus.priceIncreased)
          .take(3))
        _withLocalState(
          AppNotice(
            id: 'subscription:${sub.id}:${sub.status.name}:${sub.renewalLabel}:${sub.monthlyPrice.round()}:${sub.previousPrice.round()}',
            icon: Icons.trending_up,
            title: strings.notifPriceIncreaseTitle(sub.name),
            body: strings.notifPriceIncreaseBody(
              fmtTL(sub.priceDelta),
              fmtTL(sub.monthlyPrice),
            ),
            accent: NoticeAccent.gold,
            when: sub.renewalLabel,
          ),
        ),
      for (final sub in subscriptions.items
          .where((s) => s.status == SubscriptionStatus.unused)
          .take(2))
        _withLocalState(
          AppNotice(
            id: 'subscription:${sub.id}:${sub.status.name}:${sub.lastUsedLabel}:${sub.renewalLabel}',
            icon: Icons.subscriptions_outlined,
            title: strings.notifUnusedTitle(sub.name),
            body: strings.notifUnusedBody(sub.lastUsedLabel),
            accent: NoticeAccent.muted,
            when: sub.renewalLabel,
          ),
        ),
      for (final bill in bills.where((b) => b.daysUntilDue <= 5))
        _withLocalState(
          AppNotice(
            id: 'bill:${bill.id}:${bill.dueDate.toIso8601String()}:${bill.amount.round()}',
            icon: bill.icon,
            title: strings.notifBillTitle(bill.name),
            body: strings.notifBillBody(fmtTL(bill.amount)),
            accent:
                bill.daysUntilDue <= 3 ? NoticeAccent.red : NoticeAccent.blue,
            when: strings.daysLeft(bill.daysUntilDue),
          ),
        ),
    ];
    state = state.copyWith(notices: next);
  }

  AppNotice _withLocalState(AppNotice notice) {
    final local = state.localState[notice.id];
    if (local == null) return notice;
    return notice.copyWith(
      isRead: local.isRead,
      isDismissed: local.isDismissed,
    );
  }

  @override
  void dispose() {
    _securitySub?.close();
    _subscriptionsSub?.close();
    _billsSub?.close();
    super.dispose();
  }
}

final notificationCenterControllerProvider = StateNotifierProvider<
    NotificationCenterController, NotificationCenterState>((ref) {
  return NotificationCenterController(
    ref.watch(notificationCenterStoreProvider),
    ref,
  );
});
