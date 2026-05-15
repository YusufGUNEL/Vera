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
              'I prepared a 10g gold purchase plan. Open Garanti BBVA and confirm — I will track it from the SMS.',
          card: OrderCard(
            type: UmaActionType.buyGold,
            title: 'Buy 10g of Gold',
            from: 'Main · Garanti ••2847',
            to: 'Gold Vault (Garanti)',
            amount: 29840,
            bankApp: 'Garanti BBVA',
            detailLabel: 'Rate',
            detailValue: 'TL 2.984/g',
          ),
        );
      case UmaIntentType.payCreditCard:
        return const UmaMessage(
          role: UmaRole.uma,
          text:
              'Your Akbank statement is ready to pay. I will open the Akbank app on the payment screen.',
          card: OrderCard(
            type: UmaActionType.payCreditCard,
            title: 'Pay credit card statement',
            from: 'Main · Akbank ••1082',
            to: 'Platinum Card',
            amount: 12450,
            bankApp: 'Akbank',
            detailLabel: 'Due date',
            detailValue: '16 May',
          ),
        );
      case UmaIntentType.moveToSavings:
        return const UmaMessage(
          role: UmaRole.uma,
          text:
              'Your emergency fund plan is ready. Open Yapı Kredi and confirm the transfer there.',
          card: OrderCard(
            type: UmaActionType.moveToSavings,
            title: 'Move money to emergency fund',
            from: 'Daily Account · Yapı Kredi ••4301',
            to: 'Emergency Fund (Yapı Kredi)',
            amount: 2500,
            bankApp: 'Yapı Kredi',
            detailLabel: 'Goal progress',
            detailValue: '76% after transfer',
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
              'Vera tracks your portfolio across the accounts you imported. Based on this month, equities are slightly over-allocated; my suggestion is to top up gold or cash next time you open your bank.',
        );
      case UmaIntentType.checkLoanEligibility:
        return const UmaMessage(
          role: UmaRole.uma,
          text:
              'Based on the income and debt I see in your imported statements, you look strongest in the review-to-approve range for mid-sized personal loans. Open the credit simulation and I can help tune the amount and term for a safer fit.',
        );
      case UmaIntentType.explainSecurityAlert:
        return const UmaMessage(
          role: UmaRole.uma,
          text:
              'I flagged that transfer because the recipient appeared once before and the device location did not match your usual pattern. Vera does not block at your bank — it warns you and you decide together.',
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

  String _systemPrompt(String userText) {
    return '''
You are Uma, the AI coach inside Vera, a Turkish personal finance app.
Vera does NOT execute bank transactions itself. It analyzes the user's data
(imported statements, receipts, screenshots, manual entries) and forwards
real actions to the user's bank app for them to confirm.

Tone: warm, concise (1-3 sentences), helpful. Use TL when relevant.
Never invent specific transaction history or prices the user hasn't asked about.
Never claim Vera will move money. If the user wants an action, say you will
open the right bank app and that they'll confirm there.

User: $userText
Uma:''';
  }
}

final umaRepositoryProvider = Provider<UmaRepository>((ref) {
  return UmaRepository(
    ref.watch(geminiServiceProvider),
    ref.watch(intentRouterProvider),
  );
});
