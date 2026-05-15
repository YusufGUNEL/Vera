import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/autonomy_policy.dart';
import '../domain/portfolio_allocation.dart';
import '../domain/rebalance_action.dart';

class WealthRepository {
  const WealthRepository();

  AutonomyPolicy initialPolicy() {
    return const AutonomyPolicy(
      enabled: true,
      riskProfile: 'Dengeli',
      monthlyMoveLimit: 25000,
      approvalMode: ApprovalMode.confirmLargeMoves,
    );
  }

  List<PortfolioAllocation> portfolio() {
    return const [
      PortfolioAllocation(
        label: 'Hisse',
        amount: 167400,
        weight: 48,
        paletteKey: 'brand',
      ),
      PortfolioAllocation(
        label: 'Altın',
        amount: 94200,
        weight: 27,
        paletteKey: 'gold',
      ),
      PortfolioAllocation(
        label: 'Nakit',
        amount: 55800,
        weight: 16,
        paletteKey: 'blueSoft',
      ),
      PortfolioAllocation(
        label: 'Kripto',
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
        title: 'Altına 2.000 TL aktarıldı',
        detail: 'Vergi avantajlı rebalans',
        why:
            'Nakit ağırlığı hedefin 3 puan üstüne sapmıştı, Uma boş bakiyeyi savunma amaçlı altın pozisyonuna yönlendirdi.',
        when: 'Bugün, 11:42',
        amount: 2000,
        undoable: true,
      ),
      RebalanceAction(
        id: 'thyao-dca',
        type: WealthActionType.buyEquity,
        title: 'THYAO 5.000 TL alındı',
        detail: 'DCA planlı alım',
        why:
            'Geçen haftaki piyasa hareketinden sonra hisse kovan biraz hedefin altındaydı; Uma planlı birikim alımını sürdürdü.',
        when: 'Dün',
        amount: 5000,
        undoable: false,
      ),
      RebalanceAction(
        id: 'cash-reserve',
        type: WealthActionType.topUpCash,
        title: 'Nakit rezervi takviye edildi',
        detail: 'Boş Akbank bakiyesinden',
        why:
            'Yaklaşan kart ve abonelik ödemeleri öncesi Uma 3 aylık likit rezervi korumak için bakiyeyi artırdı.',
        when: '10 Mayıs',
        amount: 3500,
        undoable: false,
      ),
    ];
  }

  String insightFor(AutonomyPolicy policy, List<RebalanceAction> actions) {
    final activeActions = actions.where((action) => !action.undone).length;

    if (!policy.enabled) {
      return 'Otonom mod duraklatıldı. Vera sapmayı izliyor ama para hareketi için onayını bekleyecek.';
    }

    return 'Uma "${policy.riskProfile.toLowerCase()}" politikasıyla aktif. Aylık ${policy.monthlyMoveLimit.round()} TL limitine sadık kalarak $activeActions portföy ayarlaması yaptı veya hazırladı.';
  }
}

final wealthRepositoryProvider = Provider<WealthRepository>((ref) {
  return const WealthRepository();
});
