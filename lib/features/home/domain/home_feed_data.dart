import '../data/bank.dart';
import '../data/transaction.dart';

class HomeFeedData {
  const HomeFeedData({
    required this.banks,
    required this.transactions,
    required this.insight,
    required this.lastUpdated,
  });

  final List<Bank> banks;
  final List<Txn> transactions;
  final String insight;
  final DateTime lastUpdated;

  double get totalBalance =>
      banks.fold<double>(0, (sum, bank) => sum + bank.balance);

  Map<String, dynamic> toMap() {
    return {
      'banks': banks.map((bank) => bank.toMap()).toList(),
      'transactions': transactions.map((txn) => txn.toMap()).toList(),
      'insight': insight,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory HomeFeedData.fromMap(Map<String, dynamic> map) {
    return HomeFeedData(
      banks: (map['banks'] as List<dynamic>)
          .map((item) => Bank.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList(),
      transactions: (map['transactions'] as List<dynamic>)
          .map((item) => Txn.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList(),
      insight: map['insight'] as String,
      lastUpdated: DateTime.parse(map['lastUpdated'] as String),
    );
  }
}
