import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/uma_intent.dart';

class IntentRouter {
  const IntentRouter();

  UmaIntent parse(String userText) {
    final lower = userText.toLowerCase();

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
        lower.contains('analiz') ||
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
}

final intentRouterProvider = Provider<IntentRouter>((ref) {
  return const IntentRouter();
});
