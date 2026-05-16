import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA9WvX7_VYY7GcNStcpToso-mBDAuXue3c',
    appId: '1:322234106458:web:24b14231444dbe7b4d0e63',
    messagingSenderId: '322234106458',
    projectId: 'vera-ai-finance',
    authDomain: 'vera-ai-finance.firebaseapp.com',
    storageBucket: 'vera-ai-finance.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBQMtQVnxI7D0SNcVMACfmqKtfhQQ8-9kw',
    appId: '1:322234106458:android:a2c0a5dada1272774d0e63',
    messagingSenderId: '322234106458',
    projectId: 'vera-ai-finance',
    storageBucket: 'vera-ai-finance.firebasestorage.app',
  );
}
