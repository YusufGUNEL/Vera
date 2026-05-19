import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_bootstrap.dart';

/// Firebase Remote Config üzerinden feature flag ve konfigürasyon değerlerini yönetir.
/// Firebase hazır değilse her metot .env / hardcoded fallback değeri döner.
class RemoteConfigService {
  RemoteConfigService(this._bootstrapState);

  final FirebaseBootstrapState _bootstrapState;

  bool get isEnabled => _bootstrapState.ready;

  /// Remote Config'i başlat ve fetch et.
  Future<void> init() async {
    if (!isEnabled) return;

    final rc = FirebaseRemoteConfig.instance;

    // Default değerler (Firebase Console'dan override edilebilir).
    await rc.setDefaults({
      _kGeminiModel: 'gemini-2.5-flash',
      _kUmaFallbackMessage: 'Şu an yardımcı olamıyorum, lütfen tekrar dene.',
      _kFraudAlertThreshold: 85,        // Güven skoru eşiği (0-100)
      _kReceiptOcrEnabled: true,
      _kWealthAutonomyEnabled: true,
      _kStatementImportEnabled: true,
      _kMaxImportTransactions: 500,
    });

    await rc.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval:
          kDebugMode ? Duration.zero : const Duration(hours: 1),
    ));

    try {
      await rc.fetchAndActivate();
      debugPrint('[RemoteConfig] Fetch tamamlandı.');
    } catch (e) {
      debugPrint('[RemoteConfig] Fetch hatası (fallback kullanılıyor): $e');
    }
  }

  // ─── Getterlar ────────────────────────────────────────────────────────────

  static const _kGeminiModel = 'gemini_model';
  static const _kUmaFallbackMessage = 'uma_fallback_message';
  static const _kFraudAlertThreshold = 'fraud_alert_threshold';
  static const _kReceiptOcrEnabled = 'receipt_ocr_enabled';
  static const _kWealthAutonomyEnabled = 'wealth_autonomy_enabled';
  static const _kStatementImportEnabled = 'statement_import_enabled';
  static const _kMaxImportTransactions = 'max_import_transactions';

  String get geminiModel {
    if (!isEnabled) return 'gemini-2.5-flash';
    final fromRc = FirebaseRemoteConfig.instance.getString(_kGeminiModel);
    return fromRc.isEmpty ? 'gemini-2.5-flash' : fromRc;
  }

  String get umaFallbackMessage {
    if (!isEnabled) return 'Şu an yardımcı olamıyorum, lütfen tekrar dene.';
    return FirebaseRemoteConfig.instance.getString(_kUmaFallbackMessage);
  }

  int get fraudAlertThreshold {
    if (!isEnabled) return 85;
    return FirebaseRemoteConfig.instance.getInt(_kFraudAlertThreshold);
  }

  bool get receiptOcrEnabled {
    if (!isEnabled) return true;
    return FirebaseRemoteConfig.instance.getBool(_kReceiptOcrEnabled);
  }

  bool get wealthAutonomyEnabled {
    if (!isEnabled) return true;
    return FirebaseRemoteConfig.instance.getBool(_kWealthAutonomyEnabled);
  }

  bool get statementImportEnabled {
    if (!isEnabled) return true;
    return FirebaseRemoteConfig.instance.getBool(_kStatementImportEnabled);
  }

  int get maxImportTransactions {
    if (!isEnabled) return 500;
    return FirebaseRemoteConfig.instance.getInt(_kMaxImportTransactions);
  }
}

final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService(ref.watch(firebaseBootstrapProvider));
});
