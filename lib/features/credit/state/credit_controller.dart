import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/credit_repository.dart';
import '../domain/credit_decision.dart';
import '../domain/loan_application.dart';

class CreditState {
  const CreditState({
    required this.application,
    required this.decision,
  });

  final LoanApplication application;
  final CreditDecision decision;

  CreditState copyWith({
    LoanApplication? application,
    CreditDecision? decision,
  }) {
    return CreditState(
      application: application ?? this.application,
      decision: decision ?? this.decision,
    );
  }
}

class CreditController extends StateNotifier<CreditState> {
  CreditController(this._repository)
      : super(
          CreditState(
            application: const LoanApplication(
              amount: 0,
              months: 12,
              monthlyIncome: 0,
              monthlyDebt: 0,
            ),
            decision: _repository.evaluate(
              const LoanApplication(
                amount: 0,
                months: 12,
                monthlyIncome: 0,
                monthlyDebt: 0,
              ),
            ),
          ),
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
      decision: _repository.evaluate(application),
    );
  }
}

final creditControllerProvider =
    StateNotifierProvider<CreditController, CreditState>((ref) {
  return CreditController(ref.watch(creditRepositoryProvider));
});
