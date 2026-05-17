import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vera/core/services/gemini_service.dart';
import 'package:vera/features/receipt_scan/data/receipt_repository.dart';
import 'package:vera/features/receipt_scan/domain/parsed_receipt.dart';
import 'package:vera/features/statement_import/data/statement_repository.dart';
import 'package:vera/features/statement_import/domain/parsed_statement.dart';

void main() {
  group('ReceiptRepository', () {
    test('returns empty fallback when Gemini throws', () async {
      final repo = ReceiptRepository(_FakeGeminiService(error: Exception('boom')));

      final result = await repo.parse(
        imageBytes: Uint8List.fromList([1, 2, 3]),
        mimeType: 'image/jpeg',
      );

      expect(result.source, ReceiptSource.fallback);
      expect(result.merchant, isNull);
      expect(result.total, isNull);
      expect(result.category, isNull);
      expect(result.lines, isEmpty);
    });

    test('returns empty fallback when Gemini output is not parseable json', () async {
      final repo = ReceiptRepository(
        _FakeGeminiService(text: 'hello not a json response'),
      );

      final result = await repo.parse(
        imageBytes: Uint8List.fromList([1, 2, 3]),
        mimeType: 'image/jpeg',
      );

      expect(result.source, ReceiptSource.fallback);
      expect(result.merchant, isNull);
      expect(result.total, isNull);
      expect(result.lines, isEmpty);
      expect(result.rawText, 'hello not a json response');
    });

    test('parses valid ai response', () async {
      final repo = ReceiptRepository(
        _FakeGeminiService(
          text:
              '{"merchant":"Migros","total":642.8,"currency":"TL","category":"Market","date":"17 May","lines":[{"name":"Sut","amount":42.5}]}',
        ),
      );

      final result = await repo.parse(
        imageBytes: Uint8List.fromList([1, 2, 3]),
        mimeType: 'image/jpeg',
      );

      expect(result.source, ReceiptSource.ai);
      expect(result.merchant, 'Migros');
      expect(result.total, 642.8);
      expect(result.category, 'Market');
      expect(result.lines, hasLength(1));
      expect(result.lines.first.name, 'Sut');
    });
  });

  group('StatementRepository', () {
    test('returns empty fallback when Gemini throws', () async {
      final repo =
          StatementRepository(_FakeGeminiService(error: Exception('boom')));

      final result = await repo.parse(
        bytes: Uint8List.fromList([1, 2, 3]),
        mimeType: 'application/pdf',
      );

      expect(result.source, StatementSource.fallback);
      expect(result.bank, isNull);
      expect(result.accountLast4, isNull);
      expect(result.closingBalance, isNull);
      expect(result.transactions, isEmpty);
    });

    test('returns empty fallback when Gemini output is not parseable json', () async {
      final repo = StatementRepository(
        _FakeGeminiService(text: 'plain text that cannot be parsed'),
      );

      final result = await repo.parse(
        bytes: Uint8List.fromList([1, 2, 3]),
        mimeType: 'application/pdf',
      );

      expect(result.source, StatementSource.fallback);
      expect(result.bank, isNull);
      expect(result.transactions, isEmpty);
      expect(result.rawText, 'plain text that cannot be parsed');
    });

    test('parses valid ai response', () async {
      final repo = StatementRepository(
        _FakeGeminiService(
          text:
              '{"bank":"Garanti","account_last4":"1234","period":"01.05 - 17.05.2026","opening_balance":1000,"closing_balance":850,"transactions":[{"date":"17.05","description":"Migros","amount":-150,"category":"Market"}]}',
        ),
      );

      final result = await repo.parse(
        bytes: Uint8List.fromList([1, 2, 3]),
        mimeType: 'application/pdf',
      );

      expect(result.source, StatementSource.ai);
      expect(result.bank, 'Garanti');
      expect(result.accountLast4, '1234');
      expect(result.closingBalance, 850);
      expect(result.transactions, hasLength(1));
      expect(result.transactions.first.description, 'Migros');
      expect(result.transactions.first.amount, -150);
    });
  });
}

class _FakeGeminiService implements GeminiService {
  _FakeGeminiService({this.text = '', this.error});

  final String text;
  final Object? error;

  @override
  bool get isAvailable => error == null;

  @override
  Future<String> analyzeImage({
    required Uint8List imageBytes,
    required String prompt,
    String mimeType = 'image/jpeg',
  }) async {
    if (error != null) throw error!;
    return text;
  }

  @override
  Future<String> generateText(String prompt) async => text;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
