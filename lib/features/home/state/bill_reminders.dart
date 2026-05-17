import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/formatters.dart';
import '../data/upcoming_bill.dart';
import 'upcoming_bills_controller.dart';

/// Re-schedules a local notification 24h before each user-tracked upcoming
/// bill. Listens to the bills list and to the active locale so the alert is
/// always written in the user's language and reflects the live list.
class BillRemindersScheduler {
  BillRemindersScheduler(this._notifications, this._ref) {
    _bootstrap();
    _localeSub = _ref.listen<AppLocale>(
      localeControllerProvider,
      (_, __) => _schedule(_ref.read(upcomingBillsControllerProvider)),
    );
    _billsSub = _ref.listen<List<UpcomingBill>>(
      upcomingBillsControllerProvider,
      (_, next) => _schedule(next),
    );
  }

  static const int _idBase = 4000;
  // Cap the number of scheduled reminders we track to avoid leaking notification ids.
  static const int _maxScheduled = 32;

  final NotificationService _notifications;
  final Ref _ref;
  ProviderSubscription<AppLocale>? _localeSub;
  ProviderSubscription<List<UpcomingBill>>? _billsSub;
  bool _disposed = false;

  Future<void> _bootstrap() async {
    await _notifications.init();
    await _schedule(_ref.read(upcomingBillsControllerProvider));
  }

  Future<void> _schedule(List<UpcomingBill> bills) async {
    if (_disposed) return;
    final locale = _ref.read(localeControllerProvider);
    final strings = AppStrings(locale);

    // Cancel the full reserved id range so removed bills don't keep firing.
    for (var i = 0; i < _maxScheduled; i++) {
      await _notifications.cancel(_idBase + i);
    }
    final now = DateTime.now();
    final count = bills.length > _maxScheduled ? _maxScheduled : bills.length;
    for (var i = 0; i < count; i++) {
      final bill = bills[i];
      if (bill.daysUntilDue < 1) continue;
      final due = DateTime(
        bill.dueDate.year,
        bill.dueDate.month,
        bill.dueDate.day,
        9,
      );
      final remindAt = due.subtract(const Duration(days: 1));
      if (remindAt.isBefore(now)) continue;
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
    _localeSub?.close();
    _billsSub?.close();
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
