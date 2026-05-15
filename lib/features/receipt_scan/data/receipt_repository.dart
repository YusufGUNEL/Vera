import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/gemini_service.dart';
import '../domain/parsed_receipt.dart';

/// Fis veya banka ekran goruntusu parser'i. Gemini multimodal cagrisi yapar,
/// JSON cikti bekler. AI cagrisi basarisiz olursa deterministic mock fallback
/// doner (docs/GEMINI.md fallback prensibine uygun).
class ReceiptRepository {
  ReceiptRepository(this._gemini);

  final GeminiService _gemini;

  Future<ParsedReceipt> parse({
    required Uint8List imageBytes,
    required String mimeType,
  }) async {
    try {
      final raw = await _gemini.analyzeImage(
        imageBytes: imageBytes,
        mimeType: mimeType,
        prompt: _prompt,
      );
      final parsed = _tryParseJson(raw);
      if (parsed != null) return parsed;
      return _fallback(rawText: raw);
    } catch (_) {
      return _fallback();
    }
  }

  ParsedReceipt? _tryParseJson(String raw) {
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) return null;
    final jsonStr = raw.substring(start, end + 1);
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final linesData = (map['lines'] as List?) ?? const [];
      return ParsedReceipt(
        merchant: map['merchant'] as String?,
        total: (map['total'] as num?)?.toDouble(),
        currency: (map['currency'] as String?) ?? 'TL',
        category: map['category'] as String?,
        date: map['date'] as String?,
        rawText: raw,
        source: ReceiptSource.ai,
        lines: [
          for (final line in linesData)
            if (line is Map<String, dynamic>)
              ParsedReceiptLine(
                name: (line['name'] as String?) ?? '—',
                amount: ((line['amount'] as num?) ?? 0).toDouble(),
              ),
        ],
      );
    } catch (_) {
      return null;
    }
  }

  ParsedReceipt _fallback({String? rawText}) {
    return ParsedReceipt(
      merchant: 'Migros M.Pro',
      total: 642.80,
      category: 'Market',
      date: 'Bugün',
      rawText: rawText,
      source: ReceiptSource.fallback,
      lines: const [
        ParsedReceiptLine(name: 'Süt 1 lt', amount: 38.50),
        ParsedReceiptLine(name: 'Ekmek', amount: 12.00),
        ParsedReceiptLine(name: 'Tavuk göğüs 1 kg', amount: 154.90),
        ParsedReceiptLine(name: 'Mevsim sebze', amount: 287.40),
        ParsedReceiptLine(name: 'Diğer', amount: 150.00),
      ],
    );
  }

  static const _prompt = '''
You are a receipt and bank screenshot parser inside a Turkish finance app.
Given the image, extract the following information and return ONLY valid JSON
(no markdown, no commentary):

{
  "merchant": "<store or bank name, null if unknown>",
  "total": <total amount as number in TL, null if not visible>,
  "currency": "TL",
  "category": "<one of: Market, Yemek, Akaryakit, Fatura, Saglik, Egitim, Eglence, Banka, Diger>",
  "date": "<date as 'DD MMM' or null>",
  "lines": [
    {"name": "<line item or transaction>", "amount": <number>}
  ]
}

If it's a bank app screenshot, treat each transaction as a line. If it's a
till receipt, treat each line item as a line. Numbers must be plain numerics
(no currency symbols, no thousand separators).
''';
}

final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  return ReceiptRepository(ref.watch(geminiServiceProvider));
});
