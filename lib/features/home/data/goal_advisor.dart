import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
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
    required AppStrings l10n,
    int targetMonths = 12,
  }) async {
    final remaining = (goal.target - goal.saved)
        .clamp(0, double.infinity)
        .toDouble();
    final months = targetMonths <= 0 ? 12 : targetMonths;
    final monthlyRequired = remaining / months;
    final summary = remaining <= 0
        ? l10n.goalReached
        : l10n.goalRemainingPlan(
            remaining.toStringAsFixed(0),
            months,
            monthlyRequired.toStringAsFixed(0),
          );

    if (!_gemini.isAvailable) {
      return GoalAdviceResult(
        monthlyRequired: monthlyRequired,
        etaMonths: months,
        summary: summary,
        aiNarrative: _heuristicNarrative(
          monthlyRequired: monthlyRequired,
          transactions: transactions,
          l10n: l10n,
        ),
      );
    }

    try {
      final spending = summarizeSpending(transactions, otherLabel: 'Other');
      final byCat = spending
          .map((s) => '${s.category}=${s.amount.toStringAsFixed(0)}')
          .join(', ');
      final prompt = _buildPrompt(
        l10n: l10n,
        goal: goal,
        remaining: remaining,
        months: months,
        monthlyRequired: monthlyRequired,
        byCat: byCat,
      );
      final raw = await _gemini.generateText(prompt);
      final narrative = raw.trim().isEmpty
          ? _heuristicNarrative(
              monthlyRequired: monthlyRequired,
              transactions: transactions,
              l10n: l10n,
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
          l10n: l10n,
        ),
      );
    }
  }

  String _buildPrompt({
    required AppStrings l10n,
    required FinancialGoal goal,
    required double remaining,
    required int months,
    required double monthlyRequired,
    required String byCat,
  }) {
    final languageName = switch (l10n.localeCode) {
      'tr' => 'Turkish',
      'en' => 'English',
      'de' => 'German',
      'ar' => 'Arabic',
      'ru' => 'Russian',
      'zh' => 'Chinese',
      _ => 'English',
    };
    return '''
You are Uma, the AI coach inside Vera. Respond in $languageName.
User goal target: ${goal.target.toStringAsFixed(0)} TL.
Saved so far: ${goal.saved.toStringAsFixed(0)} TL.
Remaining: ${remaining.toStringAsFixed(0)} TL.
Target horizon: $months months.
Required monthly: ${monthlyRequired.toStringAsFixed(0)} TL.
Recent spend by category: ${byCat.isEmpty ? 'no data yet' : byCat}.

Write exactly two short sentences:
1) Is the plan realistic relative to current spending? Be direct.
2) Which 1-2 categories should they trim to free up this monthly saving? If there is no data, say "import a statement".

Only output the sentences. No bullets, no preamble, no number repetition.
''';
  }

  String _heuristicNarrative({
    required double monthlyRequired,
    required List<Txn> transactions,
    required AppStrings l10n,
  }) {
    if (monthlyRequired <= 0) return l10n.goalNarrativeNewTarget;
    final spending = summarizeSpending(transactions, otherLabel: 'Other');
    if (spending.isEmpty) return l10n.goalNarrativeNoData;
    final top = spending.first;
    return l10n.goalNarrativeTrim(
      monthlyRequired.toStringAsFixed(0),
      top.category,
    );
  }
}

final goalAdvisorProvider = Provider<GoalAdvisor>((ref) {
  return GoalAdvisor(ref.watch(geminiServiceProvider));
});
