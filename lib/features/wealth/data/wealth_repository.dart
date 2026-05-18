import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../domain/autonomy_policy.dart';
import '../domain/portfolio_allocation.dart';
import '../domain/rebalance_action.dart';

/// Provides the initial wealth context for users who have not yet entered any
/// holdings or autonomous policy. We return empty portfolios — there are no
/// staged "demo trades" — so what the user sees is what the user actually has.
class WealthRepository {
  const WealthRepository();

  AutonomyPolicy initialPolicy() {
    return const AutonomyPolicy(
      enabled: false,
      riskProfile: 'Dengeli',
      monthlyMoveLimit: 0,
      approvalMode: ApprovalMode.confirmLargeMoves,
    );
  }

  List<PortfolioAllocation> portfolio() => const [];

  List<RebalanceAction> actions() => const [];

  String insightFor(
    AutonomyPolicy policy,
    List<RebalanceAction> actions,
    AppStrings l10n,
  ) {
    final activeActions = actions.where((action) => !action.undone).length;

    if (!policy.enabled) {
      if (actions.isEmpty) return l10n.wealthInsightAddPortfolio;
      return l10n.wealthInsightPaused;
    }

    return l10n.wealthInsightActive(
      policy.riskProfile.toLowerCase(),
      policy.monthlyMoveLimit.round().toString(),
      activeActions,
    );
  }
}

final wealthRepositoryProvider = Provider<WealthRepository>((ref) {
  return const WealthRepository();
});
