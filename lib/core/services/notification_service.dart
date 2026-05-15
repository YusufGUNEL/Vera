import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @visibleForTesting
  void disposeForTest() {
    _taps.close();
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});
