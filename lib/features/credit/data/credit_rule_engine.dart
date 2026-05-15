import '../domain/credit_decision.dart';
import '../domain/loan_application.dart';
import '../domain/offer_option.dart';
import '../domain/risk_factor.dart';

class CreditRuleEngine {
  const CreditRuleEngine();

  CreditDecision evaluate(LoanApplication application) {
    final dti = application.debtToIncome;
    final monthlyPayment = _estimatedMonthlyPayment(application);
    final paymentLoad = application.monthlyIncome == 0
        ? 1.0
        : monthlyPayment / application.monthlyIncome;

    var score = 600;
    score +=
        ((application.monthlyIncome - 20000) / 1500).round().clamp(-40, 90);
    score -= (dti * 170).round();
    score -= (paymentLoad * 140).round();
    score += application.months >= 24 ? 18 : 5;
    score = score.clamp(420, 820);

    final riskFactors = <RiskFactor>[
      RiskFactor(
        title: 'Gelir istikrarı',
        detail: application.monthlyIncome >= 45000
            ? 'Doğrulanmış aylık geliriniz daha büyük bir ödeme zarfını destekliyor.'
            : 'Geliriniz talebi karşılıyor ancak agresif bir teklif için manevra alanı bırakmıyor.',
        impact: application.monthlyIncome >= 45000
            ? RiskImpact.positive
            : RiskImpact.caution,
      ),
      RiskFactor(
        title: 'Borç yükü',
        detail: dti <= 0.2
            ? 'Mevcut yükümlülükler sağlıklı borç/gelir eşiğinin oldukça altında.'
            : dti <= 0.35
                ? 'Aylık borç yönetilebilir ama mevcut teklifi daraltıyor.'
                : 'Aylık borç bu talep için yüksek ve ödeme riskini artırıyor.',
        impact: dti <= 0.2
            ? RiskImpact.positive
            : dti <= 0.35
                ? RiskImpact.caution
                : RiskImpact.negative,
      ),
      RiskFactor(
        title: 'Aylık ödeme yükü',
        detail: paymentLoad <= 0.18
            ? 'Öngörülen taksit gelir profilinizin içinde rahatça kalıyor.'
            : paymentLoad <= 0.28
                ? 'Öngörülen taksit kabul edilebilir ancak ideal değil.'
                : 'Öngörülen taksit aylık nakit akışınızın çok büyük bir kısmını alıyor.',
        impact: paymentLoad <= 0.18
            ? RiskImpact.positive
            : paymentLoad <= 0.28
                ? RiskImpact.caution
                : RiskImpact.negative,
      ),
    ];

    if (score >= 740 && dti <= 0.28 && paymentLoad <= 0.24) {
      return CreditDecision(
        status: CreditDecisionStatus.approved,
        score: score,
        apr: 2.08,
        summary: 'En iyi faiz oranıyla onaylandı',
        insight:
            'Hızla onaylandı: gelir profiliniz güçlü, mevcut borcunuz hafif ve öngörülen taksit sağlıklı aralıkta.',
        riskFactors: riskFactors,
        offers: const [
          OfferOption(
              name: 'İhtiyaç kredisi',
              rateLabel: '%2,08 faizden başlayan',
              tag: 'En iyi faiz'),
          OfferOption(
              name: 'Taşıt kredisi',
              rateLabel: '%2,21 faizden başlayan',
              tag: 'Ön onaylı'),
          OfferOption(
              name: 'Kart limit artışı',
              rateLabel: '35.000 TL\'ye kadar',
              tag: 'Anında'),
        ],
        recommendedAmount: application.amount,
        recommendedMonths: application.months,
        decisionTimeSeconds: 4,
      );
    }

    if (score >= 650 && dti <= 0.4 && paymentLoad <= 0.33) {
      final adjustedAmount = application.amount * 0.8;
      final adjustedMonths = application.months < 24 ? 24 : application.months;
      return CreditDecision(
        status: CreditDecisionStatus.review,
        score: score,
        apr: 2.56,
        summary: 'Daha güvenli koşullarla şartlı uygun',
        insight:
            'Onaya yakınsın ama mevcut talep aylık nakit akışını zorluyor. Tutarı düşürmek veya vadeyi uzatmak teklifi iyileştirir.',
        riskFactors: riskFactors,
        offers: [
          OfferOption(
            name: 'Düzeltilmiş ihtiyaç kredisi',
            rateLabel: '${adjustedAmount.round()} TL · $adjustedMonths ay',
            tag: 'Güvenli',
          ),
          const OfferOption(
              name: 'Taşıt kredisi',
              rateLabel: '%2,34 faizden başlayan',
              tag: 'İnceleme'),
          const OfferOption(
              name: 'Teminatlı kredi hattı',
              rateLabel: '%1,98 faizden başlayan',
              tag: 'Alternatif'),
        ],
        recommendedAmount: adjustedAmount,
        recommendedMonths: adjustedMonths,
        decisionTimeSeconds: 6,
      );
    }

    return CreditDecision(
      status: CreditDecisionStatus.declined,
      score: score,
      apr: 3.04,
      summary: 'Talep şimdilik reddedildi',
      insight:
          'Talep edilen ödeme, mevcut borç yükümlülükleri göz önüne alındığında aylık gelirinize fazla baskı uyguluyor. Tutarı azaltmak veya borç oranını iyileştirmek onay şansını ciddi artırır.',
      riskFactors: riskFactors,
      offers: const [
        OfferOption(
            name: 'Acil nakit tampon planı',
            rateLabel: '3 aylık tampon oluştur',
            tag: 'Önerilen'),
        OfferOption(
            name: 'Borç yapılandırma incelemesi',
            rateLabel: 'Aylık yükü azalt',
            tag: 'Koçluk'),
        OfferOption(
            name: 'Küçük tutarlı kredi hattı',
            rateLabel: '20.000 TL\'ye kadar',
            tag: 'Alternatif'),
      ],
      recommendedAmount: application.amount * 0.55,
      recommendedMonths: application.months < 24 ? 24 : application.months,
      decisionTimeSeconds: 7,
    );
  }

  double _estimatedMonthlyPayment(LoanApplication application) {
    final interestMultiplier = 1.16 + (application.months / 100);
    return (application.amount * interestMultiplier) / application.months;
  }
}
