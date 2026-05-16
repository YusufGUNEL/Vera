import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<String> _taps = StreamController<String>.broadcast();

  Stream<String> get onTap => _taps.stream;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
    } catch (_) {
      // Fallback: keep default UTC; scheduled times still fire correctly.
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleResponse,
    );

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'vera_security',
        'Güvenlik uyarıları',
        description: 'Uma fraud radar bildirimleri',
        importance: Importance.high,
      ),
    );
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'vera_bills',
        'Fatura hatırlatmaları',
        description: 'Yaklaşan ödeme bildirimleri',
        importance: Importance.defaultImportance,
      ),
    );
  }

  void _handleResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      _taps.add(payload);
    }
  }

  Future<void> showFraudAlert({
    required String title,
    required String body,
    String payload = '/security',
  }) async {
    if (!_initialized) await init();
    await _plugin.show(
      _idCounter++,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'vera_security',
          'Güvenlik uyarıları',
          channelDescription: 'Uma fraud radar bildirimleri',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFF7C3AED),
          icon: '@mipmap/ic_launcher',
          ticker: 'Vera Güvenlik',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  int _idCounter = 1000;

  /// Schedules a one-shot local notification to fire on [when].
  /// Returns the assigned notification id (so callers can cancel it later).
  /// Silently drops the call if [when] is in the past.
  Future<int?> scheduleAt({
    required int id,
    required String title,
    required String body,
    required DateTime when,
    String payload = '/',
  }) async {
    if (!_initialized) await init();
    final scheduled = tz.TZDateTime.from(when, tz.local);
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) return null;
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'vera_bills',
            'Fatura hatırlatmaları',
            channelDescription: 'Yaklaşan ödeme bildirimleri',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            color: Color(0xFF7C3AED),
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      return id;
    } catch (_) {
      return null;
    }
  }

  Future<void> cancel(int id) async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(id);
    } catch (_) {}
  }

  Future<void> cancelAll() async {
    if (!_initialized) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }

  @visibleForTesting
  void disposeForTest() {
    _taps.close();
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});
