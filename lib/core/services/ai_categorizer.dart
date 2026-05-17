import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'gemini_service.dart';

/// Suggests a transaction category from a free-text merchant/description.
///
/// Lightweight heuristic first (no network), then Gemini fallback when an
/// API key is configured. Heuristic is good enough for the most common
/// Turkish merchants and protects the user when offline.
class AiCategorizer {
  AiCategorizer(this._gemini);

  final GeminiService _gemini;

  /// Categories the rest of the app already knows about. Keeping a stable
  /// allow-list avoids "creative" Gemini outputs that wouldn't render with
  /// the right color/icon downstream.
  static const allowed = <String>[
    'Market',
    'Yeme & İçme',
    'Akaryakıt',
    'Fatura',
    'Sağlık',
    'Eğitim',
    'Eğlence',
    'Transfer',
    'Maaş',
    'Abonelik',
    'Diğer',
  ];

  String heuristic(String description) {
    final n = description.toLowerCase();
    if (_anyOf(n, [
      'migros',
      'bim',
      'şok',
      'sok',
      'a101',
      'carrefour',
      'macrocenter',
      'market',
      'metro',
    ])) {
      return 'Market';
    }
    if (_anyOf(n, [
      'restoran',
      'restaurant',
      'kahve',
      'starbucks',
      'kahveci',
      'yemeksepeti',
      'getir',
      'trendyol yemek',
      'burger',
      'pizza',
      'mcdonald',
      'kfc',
      'lokanta',
      'cafe',
      'kafe',
    ])) {
      return 'Yeme & İçme';
    }
    if (_anyOf(n, [
      'opet',
      'shell',
      'po',
      'bp',
      'total',
      'akaryakıt',
      'benzin',
      'mazot',
      'petrol',
    ])) {
      return 'Akaryakıt';
    }
    if (_anyOf(n, [
      'türk telekom',
      'turkcell',
      'vodafone',
      'bedaş',
      'igdaş',
      'iski',
      'fatura',
      'doğalgaz',
      'elektrik',
      'su faturası',
      'kira',
    ])) {
      return 'Fatura';
    }
    if (_anyOf(n,
        ['hastane', 'eczane', 'medical park', 'memorial', 'sağlık', 'doktor'])) {
      return 'Sağlık';
    }
    if (_anyOf(n, ['okul', 'kurs', 'üniversite', 'eğitim', 'udemy', 'coursera'])) {
      return 'Eğitim';
    }
    if (_anyOf(n, [
      'netflix',
      'spotify',
      'youtube',
      'icloud',
      'amazon prime',
      'disney',
      'blutv',
      'exxen',
      'gain',
      'tabii',
      'apple',
      'github',
      'openai',
      'anthropic',
      'claude',
      'abonelik',
    ])) {
      return 'Abonelik';
    }
    if (_anyOf(n, [
      'sinema',
      'tiyatro',
      'konser',
      'biletix',
      'passolig',
      'eğlence',
      'oyun',
      'steam',
      'playstation',
    ])) {
      return 'Eğlence';
    }
    if (_anyOf(n, ['eft', 'havale', 'transfer', 'fast'])) {
      return 'Transfer';
    }
    if (_anyOf(n, ['maaş', 'salary', 'aylık'])) {
      return 'Maaş';
    }
    return 'Diğer';
  }

  /// Tries Gemini, falls back to the heuristic on any failure. Result is
  /// always one of [allowed].
  Future<String> categorize({
    required String description,
    double? amount,
  }) async {
    final fallback = heuristic(description);
    if (!_gemini.isAvailable) return fallback;

    try {
      final prompt = '''
You categorize a single Turkish bank transaction into ONE of these EXACT labels:
${allowed.join(', ')}

Reply with only the label, nothing else.

Description: $description
${amount == null ? '' : 'Amount (TL, negative = expense, positive = income): $amount'}
Category:''';
      final raw = await _gemini.generateText(prompt);
      final candidate = raw.trim().split(RegExp(r'\s+')).first;
      final clean = candidate.replaceAll(RegExp(r'[^\w &İıÇçĞğÜüŞşÖö]'), '');
      for (final label in allowed) {
        if (label.toLowerCase() == clean.toLowerCase()) return label;
      }
      // Permissive contains check for cases like "Yeme & İçme."
      for (final label in allowed) {
        if (clean.toLowerCase().contains(label.toLowerCase())) return label;
      }
      return fallback;
    } catch (_) {
      return fallback;
    }
  }

  bool _anyOf(String haystack, List<String> needles) {
    for (final n in needles) {
      if (haystack.contains(n)) return true;
    }
    return false;
  }
}

final aiCategorizerProvider = Provider<AiCategorizer>((ref) {
  return AiCategorizer(ref.watch(geminiServiceProvider));
});
