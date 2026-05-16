import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/formatters.dart';
import '../data/upcoming_bill.dart';

/// One-shot scheduler that registers a local notification for each upcoming
/// bill 24 hours before it is due. Listens to the active locale so re-
/// scheduling rewrites the message in the user's language.
///
/// We avoid persisting the schedule ourselves — flutter_local_notifications
/// keeps the pending schedule across app restarts. To stay safe we cancel
/// any previously scheduled bill ids before re-registering.
class BillRemindersScheduler {
  BillRemindersScheduler(this._notifications, this._ref) {
    _bootstrap();
    _sub = _ref.listen<AppLocale>(
      localeControllerProvider,
      (_, __) => _schedule(),
    );
  }

  static const int _idBase = 4000;

  final NotificationService _notifications;
  final Ref _ref;
  ProviderSubscription<AppLocale>? _sub;
  bool _disposed = false;

  Future<void> _bootstrap() async {
    await _notifications.init();
    await _schedule();
  }

  Future<void> _schedule() async {
    if (_disposed) return;
    final locale = _ref.read(localeControllerProvider);
    final strings = AppStrings(locale);
    // Cancel and reschedule a stable id range so locale switches refresh
    // copy in-place.
    for (var i = 0; i < kUpcomingBills.length; i++) {
      await _notifications.cancel(_idBase + i);
    }
    final now = DateTime.now();
    for (var i = 0; i < kUpcomingBills.length; i++) {
      final bill = kUpcomingBills[i];
      if (bill.daysUntilDue < 1) continue;
      final due = DateTime(now.year, now.month, now.day + bill.daysUntilDue, 9);
      final remindAt = due.subtract(const Duration(days: 1));
      await _notifications.scheduleAt(
        id: _idBase + i,
        title: strings.notifBillTitle(bill.name),
        body: strings.notifBillBody(fmtTL(bill.amount)),
        when: remindAt,
        payload: '/',
      );
    }
  }

  void dispose() {
    _disposed = true;
    _sub?.close();
  }
}

final billRemindersProvider = Provider<BillRemindersScheduler>((ref) {
  final scheduler = BillRemindersScheduler(
    ref.watch(notificationServiceProvider),
    ref,
  );
  ref.onDispose(scheduler.dispose);
  return scheduler;
});
