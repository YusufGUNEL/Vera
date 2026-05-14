import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global net-worth balance. Uma chat'te "Buy Gold" onaylaninca buradan dusurulur,
/// home + uma chat ayni provider'i izledigi icin anlik guncellenir.
class BalanceController extends StateNotifier<double> {
  BalanceController() : super(347240);

  void debit(double amount) => state -= amount;
  void credit(double amount) => state += amount;
  void setBalance(double amount) => state = amount;
}

final balanceProvider = StateNotifierProvider<BalanceController, double>((ref) {
  return BalanceController();
});
