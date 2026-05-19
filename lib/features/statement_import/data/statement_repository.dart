import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/gemini_service.dart';
import '../domain/parsed_statement.dart';

/// Banka ekstresi (PDF veya gorsel) parser'i.
/// Gemini multimodal cagrisi yapar, JSON cikti bekler.
/// API key yoksa veya parse hata verirse bos bir fallback doner.
class StatementRepository {
  StatementRepository(this._gemini);

  final GeminiService _gemini;

  Future<ParsedStatement> parse({
    required Uint8List bytes,
    required String mimeType,
  }) async {
    try {
      final raw = await _gemini.analyzeImage(
        imageBytes: bytes,
        mimeType: mimeType,
        prompt: _prompt,
      );
      final parsed = _tryParseJson(raw);
      if (parsed != null) return parsed;
      return _fallback(rawText: raw);
    } on MissingGeminiBackendException catch (_) {
      return _fallback();
    } on GeminiBusyException catch (_) {
      return _fallback();
    } catch (_) {
      return _fallback();
    }
  }

  ParsedStatement? _tryParseJson(String raw) {
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) return null;
    final jsonStr = raw.substring(start, end + 1);
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final txList = (map['transactions'] as List?) ?? const [];
      return ParsedStatement(
        bank: map['bank'] as String?,
        accountLast4: map['account_last4'] as String?,
        period: map['period'] as String?,
        openingBalance: (map['opening_balance'] as num?)?.toDouble(),
        closingBalance: (map['closing_balance'] as num?)?.toDouble(),
        rawText: raw,
        source: StatementSource.ai,
        transactions: [
          for (final t in txList)
            if (t is Map<String, dynamic>)
              ParsedStatementTxn(
                date: (t['date'] as String?) ?? '',
                description: (t['description'] as String?) ?? '—',
                amount: ((t['amount'] as num?) ?? 0).toDouble(),
                category: t['category'] as String?,
              ),
        ],
      );
    } catch (_) {
      return null;
    }
  }

  ParsedStatement _fallback({String? rawText}) {
    return ParsedStatement(
      bank: null,
      accountLast4: null,
      period: null,
      openingBalance: null,
      closingBalance: null,
      rawText: rawText,
      source: StatementSource.fallback,
      transactions: const [],
    );
  }

  static const _prompt = '''
You are a Turkish bank statement parser inside a finance app.
The input is a PDF or screenshot of a bank account statement.
Return ONLY valid JSON, no markdown, no commentary:

{
  "bank": "<bank name>",
  "account_last4": "<last 4 of account, null if unknown>",
  "period": "<statement period, e.g. '01.05 - 14.05.2026'>",
  "opening_balance": <number>,
  "closing_balance": <number>,
  "transactions": [
    {
      "date": "DD.MM",
      "description": "<merchant or counterparty>",
      "amount": <signed number; positive = incoming, negative = outgoing>,
      "category": "<Market/Yemek/Akaryakit/Fatura/Saglik/Egitim/Eglence/Banka/Diger>"
    }
  ]
}

Amounts must be plain numerics (no TL symbol, no thousand separators).
List at most 20 most recent transactions.
''';
}

final statementRepositoryProvider = Provider<StatementRepository>((ref) {
  return StatementRepository(ref.watch(geminiServiceProvider));
});
