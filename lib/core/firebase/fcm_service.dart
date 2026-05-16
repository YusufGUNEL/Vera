import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_bootstrap.dart';

/// Arka planda (isolate dışında) gelen mesajları işler.
/// Top-level function olmak zorunda (FCM kısıtı).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Bootstrap zaten yapılmış olmalı; değilse graceful geç.
  debugPrint('[FCM-BG] messageId=${message.messageId} title=${message.notification?.title}');
}

class FcmService {
  FcmService(this._bootstrapState);

  final FirebaseBootstrapState _bootstrapState;

  bool get isEnabled => _bootstrapState.ready;

  final _messageController = StreamController<RemoteMessage>.broadcast();

  /// Foreground mesaj stream'i — UI katmanı dinleyebilir.
  Stream<RemoteMessage> get onMessage => _messageController.stream;

  /// Servisi başlat: izin iste, token kaydet, handler'ları bağla.
  Future<void> init() async {
    if (!isEnabled) return;

    // Arka plan handler'ı kaydet (uygulama açık olmadan gelen mesajlar).
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // iOS / Web için bildirim izni iste.
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Android 13+ için izin (flutter_local_notifications ile çakışmayacak şekilde).
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Token al ve Firestore'a kaydet.
    await _refreshAndSaveToken();

    // Token yenilendiğinde tekrar kaydet.
    FirebaseMessaging.instance.onTokenRefresh.listen(_saveToken);

    // Uygulama açıkken gelen mesajları yayımla.
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('[FCM] foreground: ${message.notification?.title}');
      _messageController.add(message);
    });

    // Bildirime tıklanıp uygulama açıldığında.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('[FCM] openedApp: ${message.notification?.title}');
      _messageController.add(message);
    });

    // Uygulama kapalıyken gelen bildirimden açılış.
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      _messageController.add(initial);
    }
  }

  Future<void> _refreshAndSaveToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _saveToken(token);
    } catch (e) {
      debugPrint('[FCM] Token alınamadı: $e');
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
          .doc(token.substring(0, 20)) // Token'ın ilk 20 karakteri doc ID
          .set({
        'token': token,
        'platform': defaultTargetPlatform.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('[FCM] Token Firestore\'a kaydedildi.');
    } catch (e) {
      debugPrint('[FCM] Token kaydetme hatası: $e');
    }
  }

  /// Kullanıcı çıkış yaptığında token'ı Firestore'dan sil.
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
    } catch (e) {
      debugPrint('[FCM] Token silme hatası: $e');
    }
  }

  void dispose() {
    _messageController.close();
  }
}

final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService(ref.watch(firebaseBootstrapProvider));
});
