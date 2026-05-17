import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/gemini_service.dart';
import 'category_summary.dart';
import 'goal.dart';
import 'transaction.dart';

class GoalAdviceResult {
  const GoalAdviceResult({
    required this.monthlyRequired,
    required this.etaMonths,
    required this.summary,
    required this.aiNarrative,
  });

  final double monthlyRequired;
  final int etaMonths;
  final String summary;
  final String aiNarrative;
}

/// Builds a deterministic plan to reach a goal, then asks Gemini for a short,
/// human narrative. The numbers are always real (never invented by the LLM).
class GoalAdvisor {
  GoalAdvisor(this._gemini);

  final GeminiService _gemini;

  Future<GoalAdviceResult> advise({
    required FinancialGoal goal,
    required List<Txn> transactions,
    int targetMonths = 12,
  }) async {
    final remaining = (goal.target - goal.saved)
        .clamp(0, double.infinity)
        .toDouble();
    final months = targetMonths <= 0 ? 12 : targetMonths;
    final monthlyRequired = remaining / months;
    final summary = remaining <= 0
        ? 'Hedefine ulaştın. Yeni bir hedef belirleyebilirsin.'
        : 'Kalan ${remaining.toStringAsFixed(0)} TL\'yi $months ayda biriktirmek için aylık ${monthlyRequired.toStringAsFixed(0)} TL ayırmalısın.';

    if (!_gemini.isAvailable) {
      return GoalAdviceResult(
        monthlyRequired: monthlyRequired,
        etaMonths: months,
        summary: summary,
        aiNarrative: _heuristicNarrative(
          monthlyRequired: monthlyRequired,
          transactions: transactions,
        ),
      );
    }

    try {
      final spending = summarizeSpending(transactions, otherLabel: 'Diğer');
      final byCat = spending
          .map((s) => '${s.category}=${s.amount.toStringAsFixed(0)}')
          .join(', ');
      final prompt = '''
Vera'nın AI koçu Uma'sın. Türkçe konuş.
Kullanıcının hedefi: ${goal.target.toStringAsFixed(0)} TL.
Şu ana kadar biriktirdiği: ${goal.saved.toStringAsFixed(0)} TL.
Kalan: ${remaining.toStringAsFixed(0)} TL.
Hedef süre: $months ay.
Aylık ayırması gereken: ${monthlyRequired.toStringAsFixed(0)} TL.
Kategorilere göre son dönem harcamaları: ${byCat.isEmpty ? 'henüz veri yok' : byCat}.

İki kısa cümle yaz:
1) Plan gerçekçi mi (mevcut harcamasına oranla)? Net ol.
2) Hangi 1-2 kategoriden kısarak bu aylık tasarrufu çıkarabilir? Veri yoksa "ekstre yükle" de.

Yalnızca cümleleri yaz. Madde işareti, ön söz, sayı tekrarı yok.
''';
      final raw = await _gemini.generateText(prompt);
      final narrative = raw.trim().isEmpty
          ? _heuristicNarrative(
              monthlyRequired: monthlyRequired,
              transactions: transactions,
            )
          : raw.trim();
      return GoalAdviceResult(
        monthlyRequired: monthlyRequired,
        etaMonths: months,
        summary: summary,
        aiNarrative: narrative,
      );
    } catch (_) {
      return GoalAdviceResult(
        monthlyRequired: monthlyRequired,
        etaMonths: months,
        summary: summary,
        aiNarrative: _heuristicNarrative(
          monthlyRequired: monthlyRequired,
          transactions: transactions,
        ),
      );
    }
  }

  String _heuristicNarrative({
    required double monthlyRequired,
    required List<Txn> transactions,
  }) {
    if (monthlyRequired <= 0) {
      return 'Hedefin için yeni bir tutar belirleyebilirsin.';
    }
    final spending = summarizeSpending(transactions, otherLabel: 'Diğer');
    if (spending.isEmpty) {
      return 'Henüz işlem verisi yok. Ekstre yükle veya birkaç manuel işlem ekle, Uma sana özel öneri sunsun.';
    }
    final top = spending.first;
    return 'Hedef için aylık ${monthlyRequired.toStringAsFixed(0)} TL ayırman gerek. ${top.category} bütçenden küçük kısmalarla başlamak mantıklı.';
  }
}

final goalAdvisorProvider = Provider<GoalAdvisor>((ref) {
  return GoalAdvisor(ref.watch(geminiServiceProvider));
});
