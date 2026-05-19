import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_bootstrap.dart';

/// Firebase Remote Config uzerinden feature flag ve config degerlerini yonetir.
/// Firebase hazir degilse her metot fallback degeri dondurur.
class RemoteConfigService {
  RemoteConfigService(this._bootstrapState);

  final FirebaseBootstrapState _bootstrapState;
  bool _initialized = false;

  bool get isEnabled => _bootstrapState.ready;

  /// Remote Config'i baslat ve fetch et.
  Future<void> init() async {
    if (!isEnabled || _initialized) return;
    _initialized = true;

    try {
      final rc = FirebaseRemoteConfig.instance;

      await rc.setDefaults({
        _kGeminiModel: 'gemini-2.5-flash',
        _kUmaFallbackMessage: 'Su an yardimci olamiyorum, lutfen tekrar dene.',
        _kFraudAlertThreshold: 85,
        _kReceiptOcrEnabled: true,
        _kWealthAutonomyEnabled: true,
        _kStatementImportEnabled: true,
        _kMaxImportTransactions: 500,
        _kUmaMemoryWriteEnabled: true,
        _kUmaCitationMode: 'compact',
        _kUmaToolPolicyStrictness: 'strict',
      });

      await rc.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval:
            kDebugMode ? Duration.zero : const Duration(hours: 1),
      ));

      await rc.fetchAndActivate();
      debugPrint('[RemoteConfig] Fetch tamamlandi.');
    } catch (error) {
      debugPrint('[RemoteConfig] Init/fetch failed, using defaults: $error');
    }
  }

  static const _kGeminiModel = 'gemini_model';
  static const _kUmaFallbackMessage = 'uma_fallback_message';
  static const _kFraudAlertThreshold = 'fraud_alert_threshold';
  static const _kReceiptOcrEnabled = 'receipt_ocr_enabled';
  static const _kWealthAutonomyEnabled = 'wealth_autonomy_enabled';
  static const _kStatementImportEnabled = 'statement_import_enabled';
  static const _kMaxImportTransactions = 'max_import_transactions';
  static const _kUmaMemoryWriteEnabled = 'uma_memory_write_enabled';
  static const _kUmaCitationMode = 'uma_citation_mode';
  static const _kUmaToolPolicyStrictness = 'uma_tool_policy_strictness';

  String get geminiModel {
    if (!isEnabled) return 'gemini-2.5-flash';
    final fromRc = FirebaseRemoteConfig.instance.getString(_kGeminiModel);
    return fromRc.isEmpty ? 'gemini-2.5-flash' : fromRc;
  }

  String get umaFallbackMessage {
    if (!isEnabled) return 'Su an yardimci olamiyorum, lutfen tekrar dene.';
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

  bool get umaMemoryWriteEnabled {
    if (!isEnabled) return true;
    return FirebaseRemoteConfig.instance.getBool(_kUmaMemoryWriteEnabled);
  }

  String get umaCitationMode {
    if (!isEnabled) return 'compact';
    return FirebaseRemoteConfig.instance.getString(_kUmaCitationMode);
  }

  String get umaToolPolicyStrictness {
    if (!isEnabled) return 'strict';
    return FirebaseRemoteConfig.instance.getString(_kUmaToolPolicyStrictness);
  }
}

final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService(ref.watch(firebaseBootstrapProvider));
});
