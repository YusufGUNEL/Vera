import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/autonomy_policy.dart';
import '../domain/portfolio_allocation.dart';
import '../domain/rebalance_action.dart';

class WealthRepository {
  const WealthRepository();

  AutonomyPolicy initialPolicy() {
    return const AutonomyPolicy(
      enabled: true,
      riskProfile: 'Balanced growth',
      monthlyMoveLimit: 25000,
      approvalMode: ApprovalMode.confirmLargeMoves,
    );
  }

  List<PortfolioAllocation> portfolio() {
    return const [
      PortfolioAllocation(
        label: 'Stocks',
        amount: 167400,
        weight: 48,
        paletteKey: 'brand',
      ),
      PortfolioAllocation(
        label: 'Gold',
        amount: 94200,
        weight: 27,
        paletteKey: 'gold',
      ),
      PortfolioAllocation(
        label: 'Cash',
        amount: 55800,
        weight: 16,
        paletteKey: 'blueSoft',
      ),
      PortfolioAllocation(
        label: 'Crypto',
        amount: 31400,
        weight: 9,
        paletteKey: 'uma',
      ),
    ];
  }

  List<RebalanceAction> actions() {
    return const [
      RebalanceAction(
        id: 'gold-shift',
        type: WealthActionType.rebalance,
        title: 'Moved TL 2.000 to Gold',
        detail: 'Tax-advantaged rebalance',
        why:
            'Cash weight drifted 3 points above target, so Uma redirected idle balance into a defensive gold position.',
        when: 'Today, 11:42',
        amount: 2000,
        undoable: true,
      ),
      RebalanceAction(
        id: 'thyao-dca',
        type: WealthActionType.buyEquity,
        title: 'Bought THYAO TL 5.000',
        detail: 'DCA scheduled buy',
        why:
            'Your equity bucket was slightly below target after last week\'s market move, so Uma kept the scheduled accumulation plan.',
        when: 'Yesterday',
        amount: 5000,
        undoable: false,
      ),
      RebalanceAction(
        id: 'cash-reserve',
        type: WealthActionType.topUpCash,
        title: 'Topped up cash reserve',
        detail: 'From idle Akbank balance',
        why:
            'Uma increased your liquid reserve to maintain 3 months of runway ahead of upcoming card and subscription payments.',
        when: 'May 10',
        amount: 3500,
        undoable: false,
      ),
    ];
  }

  String insightFor(AutonomyPolicy policy, List<RebalanceAction> actions) {
    final activeActions = actions.where((action) => !action.undone).length;

    if (!policy.enabled) {
      return 'Autonomous mode is paused. Vera is still monitoring drift, but it will wait for your confirmation before moving money.';
    }

    return 'Uma is active under a ${policy.riskProfile.toLowerCase()} policy. It has executed or prepared $activeActions portfolio adjustments while respecting your monthly move limit of TL ${policy.monthlyMoveLimit.round()}.';
  }
}

final wealthRepositoryProvider = Provider<WealthRepository>((ref) {
  return const WealthRepository();
});
