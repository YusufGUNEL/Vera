/// Receipt/screen OCR'dan cikan structured veri.
///
/// Gemini multimodal cikti format'ini bekledigimiz minimum sema:
///   merchant, total, currency, category, date, lines[].
/// Hatali parse'i guvenli birakmak icin tum alanlar nullable.
class ParsedReceipt {
  const ParsedReceipt({
    this.merchant,
    this.total,
    this.currency = 'TL',
    this.category,
    this.date,
    this.lines = const [],
    this.rawText,
    required this.source,
  });

  final String? merchant;
  final double? total;
  final String currency;
  final String? category;
  final String? date;
  final List<ParsedReceiptLine> lines;
  final String? rawText;
  final ReceiptSource source;

  bool get hasTotal => total != null && total! > 0;
}

class ParsedReceiptLine {
  const ParsedReceiptLine({
    required this.name,
    required this.amount,
  });

  final String name;
  final double amount;
}

enum ReceiptSource { ai, fallback }
