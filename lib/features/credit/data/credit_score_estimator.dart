import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale.dart';
import '../../../core/services/gemini_service.dart';
import '../domain/bank_loan_offer.dart';
import '../domain/loan_application.dart';

/// Calls Gemini to estimate a Findeks-style credit score band and a small set
/// of bank loan offers. We deliberately avoid scraping any real lender API —
/// no public one exists for individual scores in Turkey — so the result is
/// always framed as "tahmini" (estimated) in the UI.
class CreditScoreEstimator {
  CreditScoreEstimator(this._gemini);

  final GeminiService _gemini;

  bool get isAvailable => _gemini.isAvailable;

  Future<CreditEstimate?> estimate({
    required LoanApplication application,
    required AppLocale locale,
  }) async {
    if (!_gemini.isAvailable) return null;

    final languageHint = switch (locale) {
      AppLocale.tr => 'Turkish',
      AppLocale.en => 'English',
      AppLocale.de => 'German',
      AppLocale.ru => 'Russian',
      AppLocale.ar => 'Arabic',
      AppLocale.zh => 'Simplified Chinese',
    };

    final prompt =
        'You are a financial assistant operating inside a Turkish personal-'
        'finance app. The user wants an INDICATIVE Findeks-style credit '
        'estimate AND a small list of typical bank loan offers based on '
        'currently published consumer-loan rate ranges in Turkey. Findeks '
        'scores range 0–1900: under 700 = "Düşük", 700–1100 = "Orta", '
        '1100–1500 = "İyi", 1500+ = "Çok İyi".\n\n'
        'User application (Turkish lira):\n'
        '  Loan amount: ${application.amount.toStringAsFixed(0)} TL\n'
        '  Term: ${application.months} months\n'
        '  Monthly income: ${application.monthlyIncome.toStringAsFixed(0)} TL\n'
        '  Existing monthly debt: ${application.monthlyDebt.toStringAsFixed(0)} TL\n'
        '  Debt-to-income: ${(application.debtToIncome * 100).toStringAsFixed(0)}%\n\n'
        'Return STRICT JSON (no markdown, no fences, no extra text) with this '
        'exact shape:\n'
        '{\n'
        '  "score": <integer 0-1900>,\n'
        '  "band": "<Düşük|Orta|İyi|Çok İyi (translate to $languageHint)>",\n'
        '  "summary": "<one short sentence in $languageHint explaining the '
        'estimate>",\n'
        '  "offers": [\n'
        '    {"bankName": "<bank>", "estimatedApr": <decimal e.g. 0.42>, '
        '"monthlyPayment": <TL>, "totalCost": <TL>, "note": "<short qualifier in $languageHint>"}\n'
        '  ]\n'
        '}\n\n'
        'Include 4–6 Turkish retail banks the user can realistically apply '
        'to (Ziraat Bankası, VakıfBank, Halkbank, İş Bankası, Garanti BBVA, '
        'Yapı Kredi, Akbank, QNB Finansbank, DenizBank, TEB, ING, Şekerbank, '
        'Enpara). Use plausible APRs from current ranges; banks targeting '
        'salary customers usually quote lower. monthlyPayment must be '
        'computed with the standard amortization formula '
        'P*i*(1+i)^n/((1+i)^n-1) using the monthly rate (apr/12) and the '
        'user-selected term. Round to the nearest whole TL. Output JSON only.';

    try {
      final responseText = await _gemini.generateText(prompt);
      final cleaned = _stripFences(responseText);
      if (cleaned.isEmpty) return null;
      final decoded = jsonDecode(cleaned);
      if (decoded is! Map) return null;
      return CreditEstimate.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  String _stripFences(String raw) {
    var text = raw.trim();
    if (text.startsWith('```')) {
      text = text.replaceFirst(RegExp(r'^```[a-zA-Z]*'), '').trim();
    }
    if (text.endsWith('```')) {
      text = text.substring(0, text.length - 3).trim();
    }
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) return '';
    return text.substring(start, end + 1);
  }
}

final creditScoreEstimatorProvider = Provider<CreditScoreEstimator>((ref) {
  return CreditScoreEstimator(ref.watch(geminiServiceProvider));
});
