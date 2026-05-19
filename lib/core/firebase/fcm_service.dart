import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_bootstrap.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint(
    '[FCM-BG] messageId=${message.messageId} title=${message.notification?.title}',
  );
}

class FcmService {
  FcmService(this._bootstrapState);

  final FirebaseBootstrapState _bootstrapState;
  final _messageController = StreamController<RemoteMessage>.broadcast();
  bool _initialized = false;

  bool get isEnabled => _bootstrapState.ready;

  Stream<RemoteMessage> get onMessage => _messageController.stream;

  Future<void> init() async {
    if (!isEnabled || _initialized) return;
    _initialized = true;

    try {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      await _refreshAndSaveToken();
      FirebaseMessaging.instance.onTokenRefresh.listen(_saveToken);

      FirebaseMessaging.onMessage.listen((message) {
        debugPrint('[FCM] foreground: ${message.notification?.title}');
        _messageController.add(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        debugPrint('[FCM] openedApp: ${message.notification?.title}');
        _messageController.add(message);
      });

      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) {
        _messageController.add(initial);
      }
    } catch (error) {
      debugPrint('[FCM] Init failed, continuing without push: $error');
    }
  }

  Future<void> _refreshAndSaveToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _saveToken(token);
    } catch (error) {
      debugPrint('[FCM] Token alinamadi: $error');
    }
  }

  Future<void> _saveToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || !isEnabled) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('fcmTokens')
          .doc(token.substring(0, 20))
          .set({
        'token': token,
        'platform': defaultTargetPlatform.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('[FCM] Token Firestore\'a kaydedildi.');
    } catch (error) {
      debugPrint('[FCM] Token kaydetme hatasi: $error');
    }
  }

  Future<void> deleteToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (token != null && uid != null && isEnabled) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('fcmTokens')
            .doc(token.substring(0, 20))
            .delete();
      }
      await FirebaseMessaging.instance.deleteToken();
    } catch (error) {
      debugPrint('[FCM] Token silme hatasi: $error');
    }
  }

  void dispose() {
    _messageController.close();
  }
}

final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService(ref.watch(firebaseBootstrapProvider));
});
