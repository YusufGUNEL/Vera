/// Banka ekstresinden cikan structured veri.
class ParsedStatement {
  const ParsedStatement({
    this.bank,
    this.accountLast4,
    this.period,
    this.openingBalance,
    this.closingBalance,
    this.transactions = const [],
    this.rawText,
    required this.source,
  });

  final String? bank;
  final String? accountLast4;
  final String? period;
  final double? openingBalance;
  final double? closingBalance;
  final List<ParsedStatementTxn> transactions;
  final String? rawText;
  final StatementSource source;
}

class ParsedStatementTxn {
  const ParsedStatementTxn({
    required this.date,
    required this.description,
    required this.amount,
    this.category,
  });

  final String date;
  final String description;
  final double amount;
  final String? category;

  bool get isCredit => amount > 0;
}

enum StatementSource { ai, fallback }
