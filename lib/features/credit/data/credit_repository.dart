import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/credit_decision.dart';
import '../domain/loan_application.dart';
import 'credit_rule_engine.dart';

class CreditRepository {
  const CreditRepository(this._engine);

  final CreditRuleEngine _engine;

  CreditCalculation evaluate(LoanApplication application) {
    return _engine.evaluate(application);
  }
}

final creditRuleEngineProvider = Provider<CreditRuleEngine>(
  (ref) => const CreditRuleEngine(),
);

final creditRepositoryProvider = Provider<CreditRepository>((ref) {
  return CreditRepository(ref.watch(creditRuleEngineProvider));
});
