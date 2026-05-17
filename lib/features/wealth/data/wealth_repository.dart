import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  String insightFor(AutonomyPolicy policy, List<RebalanceAction> actions) {
    final activeActions = actions.where((action) => !action.undone).length;

    if (!policy.enabled) {
      if (actions.isEmpty) {
        return 'Otonom mod kapalı. Portföyünü ekle, Uma sapmayı izlesin ve önerilerini sunsun.';
      }
      return 'Otonom mod duraklatıldı. Vera sapmayı izliyor ama para hareketi için onayını bekleyecek.';
    }

    return 'Uma "${policy.riskProfile.toLowerCase()}" politikasıyla aktif. Aylık ${policy.monthlyMoveLimit.round()} TL limitine sadık kalarak $activeActions portföy ayarlaması yaptı veya hazırladı.';
  }
}

final wealthRepositoryProvider = Provider<WealthRepository>((ref) {
  return const WealthRepository();
});
