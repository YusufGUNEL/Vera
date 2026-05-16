import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_bootstrap.dart';

/// Uma intent, ekran geçişi ve kritik kullanıcı aksiyonlarını Analytics'e gönderir.
class AnalyticsService {
  AnalyticsService(this._bootstrapState);

  final FirebaseBootstrapState _bootstrapState;

  FirebaseAnalytics? get _analytics =>
      _bootstrapState.ready ? FirebaseAnalytics.instance : null;

  FirebaseAnalyticsObserver? get observer {
    final a = _analytics;
    if (a == null) return null;
    return FirebaseAnalyticsObserver(analytics: a);
  }

  // ─── Ekran Takibi ─────────────────────────────────────────────────────────

  Future<void> logScreen(String screenName) async {
    await _analytics?.logScreenView(screenName: screenName);
  }

  // ─── Uma Intent Olayları ──────────────────────────────────────────────────

  Future<void> logUmaIntent({
    required String intent,
    required bool resolvedByGemini,
  }) async {
    await _analytics?.logEvent(
      name: 'uma_intent_triggered',
      parameters: {
        'intent': intent,
        'resolved_by_gemini': resolvedByGemini ? 1 : 0,
      },
    );
  }

  Future<void> logUmaFeedback({
    required String vote, // 'helpful' | 'not_helpful'
    required String intent,
  }) async {
    await _analytics?.logEvent(
      name: 'uma_feedback_submitted',
      parameters: {'vote': vote, 'intent': intent},
    );
  }

  // ─── Fatura & Ekstre ──────────────────────────────────────────────────────

  Future<void> logReceiptScanned({required String source}) async {
    await _analytics?.logEvent(
      name: 'receipt_scanned',
      parameters: {'source': source}, // 'ai' | 'fallback'
    );
  }

  Future<void> logStatementImported({
    required int transactionCount,
    required String source,
  }) async {
    await _analytics?.logEvent(
      name: 'statement_imported',
      parameters: {'transaction_count': transactionCount, 'source': source},
    );
  }

  // ─── Güvenlik ─────────────────────────────────────────────────────────────

  Future<void> logSecurityAlertViewed({required bool wasBlocked}) async {
    await _analytics?.logEvent(
      name: 'security_alert_viewed',
      parameters: {'was_blocked': wasBlocked ? 1 : 0},
    );
  }

  // ─── Portföy / Wealth ─────────────────────────────────────────────────────

  Future<void> logWealthActionViewed({required String actionType}) async {
    await _analytics?.logEvent(
      name: 'wealth_action_viewed',
      parameters: {'action_type': actionType},
    );
  }

  // ─── Auth ─────────────────────────────────────────────────────────────────

  Future<void> logLogin({required String method}) async {
    await _analytics?.logLogin(loginMethod: method);
  }

  Future<void> logSignUp({required String method}) async {
    await _analytics?.logSignUp(signUpMethod: method);
  }

  Future<void> setUserId(String? uid) async {
    await _analytics?.setUserId(id: uid);
  }
}

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(ref.watch(firebaseBootstrapProvider));
});
