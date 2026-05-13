import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/gemini_service.dart';
import '../domain/uma_message.dart';

/// Tasarimda Uma sahte intent matching kullaniyordu (text icinde "gold" varsa
/// order card render). Burada da ayni hizli yolu tutuyoruz: niyet bellidir →
/// kart goster, degilse → Gemini'ye sor. Gercekten otonom bir agent davranisi
/// icin function-calling'e tasinabilir.
class UmaRepository {
  UmaRepository(this._gemini);

  final GeminiService _gemini;

  /// Kullanici mesajini parse eder. Eger "buy gold" niyeti varsa OrderCard donus,
  /// degilse Gemini'den dogal dilde cevap.
  Future<UmaMessage> handle(String userText) async {
    final lower = userText.toLowerCase();

    // 1) Buy gold intent
    if (lower.contains('gold') &&
        (lower.contains('buy') || lower.contains('al') || lower.contains('10g'))) {
      return const UmaMessage(
        role: UmaRole.uma,
        text: "Sure. Here's the order — review and confirm:",
        card: OrderCard(
          from: 'Main · Garanti ••2847',
          to: 'Gold Vault',
          grams: 10,
          amount: 29840,
          ratePerGram: 2984,
        ),
      );
    }

    // 2) Spending analysis intent
    if (lower.contains('spend') ||
        lower.contains('analyze') ||
        lower.contains('harca')) {
      return const UmaMessage(
        role: UmaRole.uma,
        text:
            'Your top categories this month: Groceries ₺3.420, Dining ₺1.180, Transport ₺840. '
            "You're tracking 14% below last month — nicely done.",
      );
    }

    // 3) Diger her sey -> Gemini
    try {
      final reply = await _gemini.generateText(_systemPrompt(userText));
      return UmaMessage(role: UmaRole.uma, text: reply.trim());
    } catch (_) {
      return const UmaMessage(
        role: UmaRole.uma,
        text:
            "I can help with that. Want me to draft a plan, or just give you a quick read?",
      );
    }
  }

  /// Cevap onayi sonrasi - "10g gold purchased" konfirmasyon mesaji.
  UmaMessage purchaseConfirmation({
    required int grams,
    required double rate,
    required double newBalance,
  }) {
    return UmaMessage(
      role: UmaRole.uma,
      text:
          'Done. ${grams}g of gold purchased at ₺${rate.toStringAsFixed(0)}/g. '
          'New gold position: 94.6g. Your portfolio balance is now ₺${_fmt(newBalance)}.',
    );
  }

  String _systemPrompt(String userText) {
    return '''
You are Uma, the friendly AI assistant inside Vera, a Turkish mobile banking app.
Your tone is warm, concise (1-3 sentences), helpful. Use simple language.
You can mention Turkish Lira (₺) and Turkish bank names if relevant.
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
  return UmaRepository(ref.watch(geminiServiceProvider));
});
