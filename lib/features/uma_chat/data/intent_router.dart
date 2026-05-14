import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/uma_intent.dart';

class IntentRouter {
  const IntentRouter();

  UmaIntent parse(String userText) {
    final lower = userText.toLowerCase();

    if (_isGoldIntent(lower)) {
      return UmaIntent(type: UmaIntentType.buyGold, originalText: userText);
    }

    if (_isCardPaymentIntent(lower)) {
      return UmaIntent(
          type: UmaIntentType.payCreditCard, originalText: userText);
    }

    if (_isSavingsIntent(lower)) {
      return UmaIntent(
          type: UmaIntentType.moveToSavings, originalText: userText);
    }

    if (lower.contains('subscription') ||
        lower.contains('subscriptions') ||
        lower.contains('abonelik')) {
      return UmaIntent(
        type: UmaIntentType.showSubscriptions,
        originalText: userText,
      );
    }

    if (lower.contains('spend') ||
        lower.contains('analyze') ||
        lower.contains('harca')) {
      return UmaIntent(
          type: UmaIntentType.analyzeSpending, originalText: userText);
    }

    if (lower.contains('wealth') ||
        lower.contains('portfolio') ||
        lower.contains('rebalance') ||
        lower.contains('yatirim')) {
      return UmaIntent(
          type: UmaIntentType.explainWealth, originalText: userText);
    }

    if ((lower.contains('loan') ||
            lower.contains('credit') ||
            lower.contains('kredi')) &&
        (lower.contains('eligible') ||
            lower.contains('can i') ||
            lower.contains('uygun') ||
            lower.contains('basvur'))) {
      return UmaIntent(
        type: UmaIntentType.checkLoanEligibility,
        originalText: userText,
      );
    }

    if (lower.contains('fraud') ||
        lower.contains('blocked') ||
        lower.contains('security') ||
        lower.contains('supheli')) {
      return UmaIntent(
        type: UmaIntentType.explainSecurityAlert,
        originalText: userText,
      );
    }

    return UmaIntent(type: UmaIntentType.unknown, originalText: userText);
  }

  bool _isGoldIntent(String lower) {
    return lower.contains('gold') &&
        (lower.contains('buy') ||
            lower.contains('al') ||
            lower.contains('gram') ||
            lower.contains('10g'));
  }

  bool _isCardPaymentIntent(String lower) {
    return (lower.contains('credit card') ||
            lower.contains('kart') ||
            lower.contains('statement')) &&
        (lower.contains('pay') ||
            lower.contains('ode') ||
            lower.contains('kapat'));
  }

  bool _isSavingsIntent(String lower) {
    return (lower.contains('save') ||
            lower.contains('savings') ||
            lower.contains('birikim') ||
            lower.contains('emergency')) &&
        (lower.contains('move') ||
            lower.contains('set aside') ||
            lower.contains('aktar') ||
            lower.contains('put'));
  }
}

final intentRouterProvider = Provider<IntentRouter>((ref) {
  return const IntentRouter();
});
