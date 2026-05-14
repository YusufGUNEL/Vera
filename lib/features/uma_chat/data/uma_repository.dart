import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/gemini_service.dart';
import '../domain/uma_intent.dart';
import '../domain/uma_message.dart';
import 'intent_router.dart';

class UmaRepository {
  UmaRepository(this._gemini, this._router);

  final GeminiService _gemini;
  final IntentRouter _router;

  Future<UmaMessage> handle(String userText) async {
    final intent = _router.parse(userText);

    switch (intent.type) {
      case UmaIntentType.buyGold:
        return const UmaMessage(
          role: UmaRole.uma,
          text:
              'I prepared the order. Review it and confirm if it looks right.',
          card: OrderCard(
            type: UmaActionType.buyGold,
            title: 'Buy 10g of Gold',
            from: 'Main · Garanti ••2847',
            to: 'Gold Vault',
            amount: 29840,
            balanceDelta: -29840,
            detailLabel: 'Rate',
            detailValue: 'TL 2.984/g',
            successMessage:
                'Gold order placed. 10g was added to your protected vault position.',
          ),
        );
      case UmaIntentType.payCreditCard:
        return const UmaMessage(
          role: UmaRole.uma,
          text: 'Your card payment is ready. You can approve it below.',
          card: OrderCard(
            type: UmaActionType.payCreditCard,
            title: 'Pay credit card statement',
            from: 'Main · Akbank ••1082',
            to: 'Platinum Card',
            amount: 12450,
            balanceDelta: -12450,
            detailLabel: 'Due date',
            detailValue: '16 May',
            successMessage:
                'Credit card statement paid in full. Your minimum payment risk is now cleared.',
          ),
        );
      case UmaIntentType.moveToSavings:
        return const UmaMessage(
          role: UmaRole.uma,
          text:
              'I set aside a transfer plan for your goal. Confirm to move it now.',
          card: OrderCard(
            type: UmaActionType.moveToSavings,
            title: 'Move money to emergency fund',
            from: 'Daily Account · Yapi Kredi ••4301',
            to: 'Emergency Fund',
            amount: 2500,
            balanceDelta: 0,
            detailLabel: 'Goal progress',
            detailValue: '76% after transfer',
            successMessage:
                'Transfer completed. Your emergency fund is now one step closer to target.',
          ),
        );
      case UmaIntentType.showSubscriptions:
        return const UmaMessage(
          role: UmaRole.uma,
          text:
              'I found a few plans worth reviewing. Netflix increased in price, YouTube Premium looks underused, and your monthly subscription spend is around TL 348.',
        );
      case UmaIntentType.analyzeSpending:
        return const UmaMessage(
          role: UmaRole.uma,
          text:
              'Your top categories this month are groceries TL 3.420, dining TL 1.180, and transport TL 840. You are tracking 14% below last month, which is a healthy trend.',
        );
      case UmaIntentType.explainWealth:
        return const UmaMessage(
          role: UmaRole.uma,
          text:
              'Your portfolio is running in balanced growth mode. Vera recently shifted some idle cash into gold and kept equities near target to protect your downside without slowing long-term growth.',
        );
      case UmaIntentType.checkLoanEligibility:
        return const UmaMessage(
          role: UmaRole.uma,
          text:
              'Based on your current income and debt profile, you look strongest in the review-to-approve range for mid-sized personal loans. Open the credit simulation and I can help tune the amount and term for a safer fit.',
        );
      case UmaIntentType.explainSecurityAlert:
        return const UmaMessage(
          role: UmaRole.uma,
          text:
              'The blocked transfer was flagged because the recipient account was newly created and the device location did not match your normal activity. Vera treated it as high-risk until you confirm otherwise.',
        );
      case UmaIntentType.unknown:
        break;
    }

    try {
      final reply = await _gemini.generateText(_systemPrompt(userText));
      return UmaMessage(role: UmaRole.uma, text: reply.trim());
    } catch (_) {
      return const UmaMessage(
        role: UmaRole.uma,
        text:
            'I can help with that. If you want, I can give you a quick financial read or prepare a safe next step.',
      );
    }
  }

  UmaMessage actionConfirmation({
    required OrderCard card,
    required double newBalance,
  }) {
    final balanceLine = card.balanceDelta == 0
        ? 'Your total balance stays at TL ${_fmt(newBalance)} after this internal move.'
        : 'Your portfolio balance is now TL ${_fmt(newBalance)}.';

    return UmaMessage(
      role: UmaRole.uma,
      text: '${card.successMessage} $balanceLine',
    );
  }

  String _systemPrompt(String userText) {
    return '''
You are Uma, the friendly AI assistant inside Vera, a Turkish mobile banking app.
Your tone is warm, concise (1-3 sentences), helpful. Use simple language.
You can mention Turkish Lira using "TL" and Turkish bank names if relevant.
Never invent specific transaction history or prices the user hasn't asked about.
If the user asks something off-topic, gently steer back to banking/finance.

User: $userText
Uma:''';
  }

  String _fmt(double n) {
    final s = n.round().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i != 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

final umaRepositoryProvider = Provider<UmaRepository>((ref) {
  return UmaRepository(
    ref.watch(geminiServiceProvider),
    ref.watch(intentRouterProvider),
  );
});
