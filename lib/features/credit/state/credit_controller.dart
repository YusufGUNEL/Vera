import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/locale_controller.dart';
import '../data/credit_repository.dart';
import '../data/credit_score_estimator.dart';
import '../domain/bank_loan_offer.dart';
import '../domain/credit_decision.dart';
import '../domain/loan_application.dart';

class CreditState {
  const CreditState({
    required this.application,
    required this.calculation,
    this.estimate,
    this.estimateLoading = false,
    this.estimateError = false,
  });

  final LoanApplication application;
  final CreditCalculation calculation;
  final CreditEstimate? estimate;
  final bool estimateLoading;
  final bool estimateError;

  CreditState copyWith({
    LoanApplication? application,
    CreditCalculation? calculation,
    CreditEstimate? estimate,
    bool clearEstimate = false,
    bool? estimateLoading,
    bool? estimateError,
  }) {
    return CreditState(
      application: application ?? this.application,
      calculation: calculation ?? this.calculation,
      estimate: clearEstimate ? null : (estimate ?? this.estimate),
      estimateLoading: estimateLoading ?? this.estimateLoading,
      estimateError: estimateError ?? this.estimateError,
    );
  }
}

class CreditController extends StateNotifier<CreditState> {
  CreditController(this._repository, this._estimator, this._ref)
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
  final CreditScoreEstimator _estimator;
  final Ref _ref;

  bool get geminiAvailable => _estimator.isAvailable;

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
      // Sliders moved — last estimate no longer matches the inputs.
      clearEstimate: true,
      estimateError: false,
    );
  }

  Future<void> requestEstimate() async {
    if (state.estimateLoading) return;
    state = state.copyWith(estimateLoading: true, estimateError: false);
    final locale = _ref.read(localeControllerProvider);
    final result = await _estimator.estimate(
      application: state.application,
      locale: locale,
    );
    state = state.copyWith(
      estimate: result,
      estimateLoading: false,
      estimateError: result == null,
    );
  }
}

final creditControllerProvider =
    StateNotifierProvider<CreditController, CreditState>((ref) {
  return CreditController(
    ref.watch(creditRepositoryProvider),
    ref.watch(creditScoreEstimatorProvider),
    ref,
  );
});
