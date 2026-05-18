import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/credit_repository.dart';
import '../domain/credit_decision.dart';
import '../domain/loan_application.dart';

class CreditState {
  const CreditState({
    required this.application,
    required this.calculation,
  });

  final LoanApplication application;
  final CreditCalculation calculation;

  CreditState copyWith({
    LoanApplication? application,
    CreditCalculation? calculation,
  }) {
    return CreditState(
      application: application ?? this.application,
      calculation: calculation ?? this.calculation,
    );
  }
}

class CreditController extends StateNotifier<CreditState> {
  CreditController(this._repository)
      : super(
          CreditState(
            application: _initial,
            calculation: _repository.evaluate(_initial),
          ),
        );

  static const LoanApplication _initial = LoanApplication(
    amount: 50000,
    months: 24,
    monthlyIncome: 35000,
    monthlyDebt: 0,
  );

  final CreditRepository _repository;

  void setAmount(double amount) {
    _update(state.application.copyWith(amount: amount));
  }

  void setMonths(int months) {
    _update(state.application.copyWith(months: months));
  }

  void setIncome(double income) {
    _update(state.application.copyWith(monthlyIncome: income));
  }

  void setDebt(double debt) {
    _update(state.application.copyWith(monthlyDebt: debt));
  }

  void _update(LoanApplication application) {
    state = state.copyWith(
      application: application,
      calculation: _repository.evaluate(application),
    );
  }
}

final creditControllerProvider =
    StateNotifierProvider<CreditController, CreditState>((ref) {
  return CreditController(ref.watch(creditRepositoryProvider));
});
