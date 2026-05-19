import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/gemini_service.dart';
import '../domain/investment_recommendation.dart';
import 'wealth_controller.dart';

final investmentRecommendationsProvider =
    FutureProvider<List<InvestmentRecommendation>>((ref) async {
  final gemini = ref.watch(geminiServiceProvider);
  final wealthState = ref.watch(wealthControllerProvider);
  final allocations = wealthState.allocations;

  if (gemini.isAvailable) {
    try {
      final allocationsStr = allocations.isEmpty
          ? 'No current assets. The portfolio is empty.'
          : allocations
              .map((a) =>
                  '- ${a.label}: ${a.amount} TL (${(a.weight * 100).toStringAsFixed(1)}%)')
              .join('\n');

      final prompt = '''
You are a financial advisor assistant for the Vera app.
The user has the following asset allocations:
$allocationsStr

Generate exactly 10 diverse investment recommendations matching these conditions or balancing their portfolio (mix of Turkish stocks/mutual funds, precious metals/commodities, crypto/stablecoins, index funds, global equities). Ensure a balanced mix with at least 3 equities, 3 commodities (precious metals/commodities), and 3 crypto/stablecoins.

Output a valid JSON array of exactly 10 recommendations. Each recommendation must have:
- "title": a human readable title in Turkish (e.g. "BIST 100 Temettü Endeksi" or "Altın Hesabı")
- "symbol": a short ticker or asset symbol (e.g. "EREGL", "GOLD", "BTC", "USDT")
- "type": exactly one of "equity", "commodity", or "crypto"
- "trend": "Yükseliş Beklentisi" / "Pozitif" / "Dengeli"
- "returnRate": Expected annual/periodic yield estimate (e.g. "%28 Yıllık", "%15 Yıllık")
- "explanation": A detailed explanation in Turkish why this asset is recommended and what it represents.
- "reason": A short reason/signal in Turkish.

Respond ONLY with the raw JSON array. Do not wrap in markdown or anything else.
''';

      final responseText = await gemini.generateText(prompt);
      final cleanText = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final List<dynamic> list = jsonDecode(cleanText);
      return list.map((x) => InvestmentRecommendation.fromMap(x)).toList();
    } catch (_) {
      // Fallback below
    }
  }

  // Fallback data
  return const [
    InvestmentRecommendation(
      title: 'Gram Altın',
      symbol: 'ALTIN',
      type: 'commodity',
      trend: 'Yükseliş Beklentisi',
      returnRate: '%22 Yıllık',
      explanation: 'Enflasyona karşı koruma sağlayan ve küresel risk dönemlerinde güvenli liman olarak kabul edilen gram altın, portföy dengesi için önerilmektedir.',
      reason: 'Küresel faiz indirim döngüsü ve jeopolitik riskler.',
    ),
    InvestmentRecommendation(
      title: 'Türk Hava Yolları',
      symbol: 'THYAO',
      type: 'equity',
      trend: 'Pozitif',
      returnRate: '%35 Yıllık',
      explanation: 'Güçlü kargo geliri, uçuş ağının genişliği ve turizm sezonundaki güçlü yolcu trafiği beklentisiyle BIST\'in öncü sanayi şirketidir.',
      reason: 'Yüksek kârlılık oranları ve artan global uçuş trafiği.',
    ),
    InvestmentRecommendation(
      title: 'Bitcoin',
      symbol: 'BTC',
      type: 'crypto',
      trend: 'Pozitif',
      returnRate: '%40 Yıllık',
      explanation: 'Kripto para piyasasının lider varlığı olan Bitcoin, kurumsal benimsenmenin artması ve halving sonrası arz daralması nedeniyle portföyde risk toleransına göre yer alabilir.',
      reason: 'Spot ETF onayları ve kurumsal fon girişleri.',
    ),
    InvestmentRecommendation(
      title: 'Koç Holding',
      symbol: 'KCHOL',
      type: 'equity',
      trend: 'Dengeli',
      returnRate: '%28 Yıllık',
      explanation: 'Enerji, otomotiv, finans ve dayanıklı tüketim sektörlerinde lider iştirakleri bulunan holding, dengeli ve güçlü portföy yapısı sunar.',
      reason: 'Güçlü döviz cinsi gelirler ve yüksek net aktif değer iskontosu.',
    ),
    InvestmentRecommendation(
      title: 'Gümüş',
      symbol: 'GUMUS',
      type: 'commodity',
      trend: 'Yükseliş Beklentisi',
      returnRate: '%25 Yıllık',
      explanation: 'Endüstriyel kullanımı (güneş panelleri, elektronik) ve kıymetli maden kimliğiyle gümüş, altına alternatif bir emtia olarak güçlü bir potansiyele sahiptir.',
      reason: 'Endüstriyel talep artışı ve altın/gümüş rasyosu dengelenmesi.',
    ),
    InvestmentRecommendation(
      title: 'Ereğli Demir Çelik',
      symbol: 'EREGL',
      type: 'equity',
      trend: 'Dengeli',
      returnRate: '%20 Yıllık',
      explanation: 'Türkiye\'nin en büyük entegre demir-çelik üreticisi, uzun vadeli temettü verimliliği ve kapasite artış yatırımlarıyla öne çıkmaktadır.',
      reason: 'Küresel çelik fiyatlarında toparlanma ve temettü beklentisi.',
    ),
    InvestmentRecommendation(
      title: 'Ethereum',
      symbol: 'ETH',
      type: 'crypto',
      trend: 'Pozitif',
      returnRate: '%38 Yıllık',
      explanation: 'Akıllı sözleşmelerin ve merkeziyetsiz finansın (DeFi) omurgası olan Ethereum, ağ güncellemeleri ve ETF potansiyeliyle büyümesini sürdürmektedir.',
      reason: 'Katman-2 çözümlerinin yaygınlaşması ve azalan arz.',
    ),
    InvestmentRecommendation(
      title: 'Teknoloji Fonu',
      symbol: 'TECD',
      type: 'equity',
      trend: 'Yükseliş Beklentisi',
      returnRate: '%32 Yıllık',
      explanation: 'Yapay zeka, bulut bilişim ve yarı iletken sektörlerindeki global devlere yatırım yapan bu yatırım fonu, yüksek büyüme odaklıdır.',
      reason: 'Yapay zeka devrimi ve Nasdaq borsalarındaki teknoloji rallisi.',
    ),
    InvestmentRecommendation(
      title: 'Eurobond Yatırım Fonu',
      symbol: 'DBH',
      type: 'commodity',
      trend: 'Dengeli',
      returnRate: '%8 Dövizli',
      explanation: 'Dolar cinsinden devlet ve özel sektör tahvillerine yatırım yaparak, döviz bazında düzenli kupon getirisi elde etmeyi hedefler.',
      reason: 'Döviz bazlı getiri arayışı ve düşük risk profili.',
    ),
    InvestmentRecommendation(
      title: 'Solana',
      symbol: 'SOL',
      type: 'crypto',
      trend: 'Pozitif',
      returnRate: '%45 Yıllık',
      explanation: 'Yüksek işlem hızı ve düşük işlem ücretleriyle öne çıkan Solana, NFT ve mikro-ödeme ekosistemlerinde pazar payını artırmaktadır.',
      reason: 'Ağ kullanımındaki rekor artış ve yeni proje entegrasyonları.',
    ),
  ];
});
