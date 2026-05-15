import 'package:flutter/material.dart';

import 'app_locale.dart';

/// Holds every visible UI string. New strings: add a getter here, fill 6
/// values in [_strings], then read via `context.l10n.someKey`.
class AppStrings {
  AppStrings(this.locale);

  final AppLocale locale;

  String _t(String key) {
    return _strings[locale]?[key] ?? _strings[AppLocale.en]?[key] ?? key;
  }

  // ---- Bottom nav ----
  String get navHome => _t('navHome');
  String get navWealth => _t('navWealth');
  String get navPlans => _t('navPlans');
  String get navSecurity => _t('navSecurity');
  String get navUma => _t('navUma');

  // ---- Top bar / Home greeting ----
  String get helloLabel => _t('helloLabel');
  String get defaultUserName => _t('defaultUserName');

  // ---- Net worth card ----
  String get totalNetWorth => _t('totalNetWorth');
  String get liveFeed => _t('liveFeed');
  String get syncing => _t('syncing');
  String get thisMonth => _t('thisMonth');
  String get actionSend => _t('actionSend');
  String get actionRequest => _t('actionRequest');
  String get actionTopUp => _t('actionTopUp');
  String get actionPay => _t('actionPay');

  // ---- Home sections ----
  String get connectedAccounts => _t('connectedAccounts');
  String get refresh => _t('refresh');
  String get syncingDots => _t('syncingDots');
  String get recentTransactions => _t('recentTransactions');
  String itemsCount(int n) => _t('itemsCount').replaceAll('{n}', '$n');
  String get itemsVisible => _t('itemsVisible');
  String get connectBank => _t('connectBank');
  String get umaInsight => _t('umaInsight');
  String get spent => _t('spent');
  String get incoming => _t('incoming');

  // ---- Credit card on home ----
  String get creditTitle => _t('creditTitle');
  String get creditSubtitle => _t('creditSubtitle');
  String get creditScoreLabel => _t('creditScoreLabel');
  String get openCredit => _t('openCredit');

  // ---- Wealth screen ----
  String get wealthTitle => _t('wealthTitle');
  String get wealthSubtitle => _t('wealthSubtitle');
  String get portfolio => _t('portfolio');
  String get ytd => _t('ytd');
  String get today => _t('today');
  String get autonomousWealth => _t('autonomousWealth');
  String get profile => _t('profile');
  String get moveLimit => _t('moveLimit');
  String get approval => _t('approval');
  String get activityFeed => _t('activityFeed');
  String get explainability => _t('explainability');
  String get undo => _t('undo');
  String get viewDetails => _t('viewDetails');

  // ---- Plans / Subscriptions ----
  String get plansTitle => _t('plansTitle');
  String get plansSubtitle => _t('plansSubtitle');
  String get subscriptionIntelligence => _t('subscriptionIntelligence');
  String get detectedPlans => _t('detectedPlans');
  String get filterAll => _t('filterAll');
  String get filterAttention => _t('filterAttention');
  String get filterUnused => _t('filterUnused');
  String get filterPriceChanges => _t('filterPriceChanges');
  String get freezePlan => _t('freezePlan');
  String get reviewPlan => _t('reviewPlan');
  String get askUma => _t('askUma');

  // ---- Security ----
  String get securityTitle => _t('securityTitle');
  String get securitySubtitle => _t('securitySubtitle');

  // ---- Profile sheet ----
  String get profileAndSettings => _t('profileAndSettings');
  String get sectionAppearance => _t('sectionAppearance');
  String get sectionAi => _t('sectionAi');
  String get sectionConnected => _t('sectionConnected');
  String get sectionAccount => _t('sectionAccount');
  String get sectionLanguage => _t('sectionLanguage');
  String get brandPalette => _t('brandPalette');
  String get mood => _t('mood');
  String get moodLight => _t('moodLight');
  String get moodDark => _t('moodDark');
  String get vibe => _t('vibe');
  String get vibeCalm => _t('vibeCalm');
  String get vibeStandard => _t('vibeStandard');
  String get vibeBold => _t('vibeBold');
  String get language => _t('language');
  String get signOut => _t('signOut');
  String get umaTone => _t('umaTone');
  String get toneConcise => _t('toneConcise');
  String get toneCoach => _t('toneCoach');
  String get toneProactive => _t('toneProactive');

  // ---- Receipt OCR ----
  String get scanReceipt => _t('scanReceipt');
  String get scanReceiptTitle => _t('scanReceiptTitle');
  String get scanReceiptSubtitle => _t('scanReceiptSubtitle');
  String get scanHint => _t('scanHint');
  String get takePhoto => _t('takePhoto');
  String get pickFromGallery => _t('pickFromGallery');
  String get scanReading => _t('scanReading');
  String get scanTotalLabel => _t('scanTotalLabel');
  String get scanAgain => _t('scanAgain');
  String get addToTransactions => _t('addToTransactions');
  String get addedToTransactions => _t('addedToTransactions');
  String get parsedByAi => _t('parsedByAi');
  String get parsedFallback => _t('parsedFallback');

  // ---- Savings story ----
  String get savingsStoryLabel => _t('savingsStoryLabel');
  String get savingsStoryFooter => _t('savingsStoryFooter');
  String savingsStoryDelta(String pct) =>
      _t('savingsStoryDelta').replaceAll('{pct}', pct);

  // ---- Upcoming bills ----
  String get upcomingBills => _t('upcomingBills');
  String get billPayViaUma => _t('billPayViaUma');
  String daysLeft(int n) => _t('daysLeft').replaceAll('{n}', '$n');

  // ---- Statement import ----
  String get statementImport => _t('statementImport');
  String get statementImportTitle => _t('statementImportTitle');
  String get statementImportSubtitle => _t('statementImportSubtitle');
  String get pickStatementFile => _t('pickStatementFile');
  String get statementImportHint => _t('statementImportHint');
  String get statementParsing => _t('statementParsing');
  String get closingBalance => _t('closingBalance');
  String detectedTransactions(int n) =>
      _t('detectedTransactions').replaceAll('{n}', '$n');
  String get statementImportAgain => _t('statementImportAgain');
  String get statementImported => _t('statementImported');
  String get importToVera => _t('importToVera');

  // ---- UMA forward to bank ----
  String openBankApp(String bank) =>
      _t('openBankApp').replaceAll('{bank}', bank);
  String get umaForwardNote => _t('umaForwardNote');
  String forwardedToBank(String bank) =>
      _t('forwardedToBank').replaceAll('{bank}', bank);
  String get keep => _t('keep');

  // ---- Wealth AI plan ----
  String get thisMonthsAiPlan => _t('thisMonthsAiPlan');
  String get aiPlanFooter => _t('aiPlanFooter');
  String get applyAtBank => _t('applyAtBank');

  // ---- Security framing ----
  String get securityVeraSideBanner => _t('securityVeraSideBanner');

  // ---- Security screen ----
  String get statusAllClear => _t('statusAllClear');
  String get statusMonitoring => _t('statusMonitoring');
  String get securityRecentActivity => _t('securityRecentActivity');
  String get securityScanning => _t('securityScanning');
  String get liveAnomalyDetected => _t('liveAnomalyDetected');
  String get highRiskConfidence => _t('highRiskConfidence');
  String get reviewedSignal => _t('reviewedSignal');
  String get keepBlocked => _t('keepBlocked');
  String get thisWasMe => _t('thisWasMe');

  // ---- Login ----
  String get continueWithDemo => _t('continueWithDemo');
  String get emailField => _t('emailField');
  String get passwordField => _t('passwordField');

  // ---- UMA chat ----
  String get umaSuggestionPay => _t('umaSuggestionPay');
  String get umaSuggestionSubs => _t('umaSuggestionSubs');
  String get umaSuggestionAnalyze => _t('umaSuggestionAnalyze');
  String get voiceCommandTooltip => _t('voiceCommandTooltip');
  String get requireConfirmation => _t('requireConfirmation');
  String get requireConfirmationDesc => _t('requireConfirmationDesc');

  // ---- UMA order card ----
  String get orderFrom => _t('orderFrom');
  String get orderTo => _t('orderTo');
  String get orderAmount => _t('orderAmount');

  // ---- Profile / account tiles ----
  String get accountTilePersonal => _t('accountTilePersonal');
  String get accountTileEmail => _t('accountTileEmail');
  String get accountTileSecurity => _t('accountTileSecurity');
  String get accountTileStorage => _t('accountTileStorage');
  String get accountTileHelp => _t('accountTileHelp');
  String get demoUser => _t('demoUser');

  // ---- UMA chat misc ----
  String get umaThinking => _t('umaThinking');
  String get umaAskHint => _t('umaAskHint');
  String get umaStatusOnline => _t('umaStatusOnline');
  String get umaSuggestionBuyGold => _t('umaSuggestionBuyGold');
  String get umaSuggestionMoveSavings => _t('umaSuggestionMoveSavings');
  String get umaActionPolicy => _t('umaActionPolicy');
  String get umaActionPolicyDesc => _t('umaActionPolicyDesc');

  // ---- Generic ----
  String get comingSoon => _t('comingSoon');
  String get close => _t('close');
}

// ---- Translations (6 locales) ----
const Map<AppLocale, Map<String, String>> _strings = {
  AppLocale.tr: {
    'navHome': 'Ana sayfa',
    'navWealth': 'Servet',
    'navPlans': 'Planlar',
    'navSecurity': 'Güvenlik',
    'navUma': 'UMA',
    'helloLabel': 'Merhaba,',
    'defaultUserName': 'Vera Kullanıcısı',
    'totalNetWorth': 'TOPLAM NET DEĞER',
    'liveFeed': 'CANLI',
    'syncing': 'EŞİTLENİYOR',
    'thisMonth': 'bu ay',
    'actionSend': 'Gönder',
    'actionRequest': 'İste',
    'actionTopUp': 'Yükle',
    'actionPay': 'Öde',
    'connectedAccounts': 'Bağlı hesaplar',
    'refresh': 'Yenile',
    'syncingDots': 'Eşitleniyor...',
    'recentTransactions': 'Son işlemler',
    'itemsCount': '{n} işlem',
    'itemsVisible': 'görünür',
    'connectBank': 'Banka ekle',
    'umaInsight': 'UMA İÇGÖRÜ',
    'spent': 'Harcanan',
    'incoming': 'Gelen',
    'creditTitle': 'Kredi',
    'creditSubtitle': 'Gerçek gelirine göre borçlanma.',
    'creditScoreLabel': 'KREDİ PUANI',
    'openCredit': 'Krediyi aç',
    'wealthTitle': 'Servet',
    'wealthSubtitle': 'Paranız otonom çalışıyor.',
    'portfolio': 'PORTFÖY',
    'ytd': 'YBB',
    'today': 'bugün',
    'autonomousWealth': 'Otonom Servet',
    'profile': 'PROFİL',
    'moveLimit': 'HAREKET LİMİTİ',
    'approval': 'ONAY',
    'activityFeed': 'Aktivite akışı',
    'explainability': 'Açıklanabilirlik',
    'undo': 'Geri al',
    'viewDetails': 'Detayları gör',
    'plansTitle': 'Planlar',
    'plansSubtitle': 'Sessiz para sızıntılarını yakala.',
    'subscriptionIntelligence': 'ABONELİK ZEKASI',
    'detectedPlans': 'Tespit edilen planlar',
    'filterAll': 'Tümü',
    'filterAttention': 'Dikkat gerek',
    'filterUnused': 'Kullanılmıyor',
    'filterPriceChanges': 'Fiyat değişimi',
    'freezePlan': 'Planı dondur',
    'reviewPlan': 'Planı incele',
    'askUma': "UMA'ya sor",
    'securityTitle': 'Güvenlik',
    'securitySubtitle': 'Hesabınızın canlı koruma katmanı.',
    'profileAndSettings': 'Profil & Ayarlar',
    'sectionAppearance': 'GÖRÜNÜM & TEMA',
    'sectionAi': 'YAPAY ZEKA TERCİHLERİ',
    'sectionConnected': 'BAĞLI KURUMLAR',
    'sectionAccount': 'HESAP',
    'sectionLanguage': 'DİL',
    'brandPalette': 'Marka paleti',
    'mood': 'Mod',
    'moodLight': 'Açık',
    'moodDark': 'Koyu',
    'vibe': 'Stil',
    'vibeCalm': 'Sakin',
    'vibeStandard': 'Standart',
    'vibeBold': 'Cesur',
    'language': 'Dil',
    'signOut': 'Çıkış yap',
    'umaTone': 'Uma tonu',
    'toneConcise': 'Kısa',
    'toneCoach': 'Koç',
    'toneProactive': 'Proaktif',
    'scanReceipt': 'Fiş tara',
    'scanReceiptTitle': 'Fiş veya ekran tara',
    'scanReceiptSubtitle': 'Fiş, fatura veya banka ekranını okutup işleme dönüştür.',
    'scanHint': 'AI fişi okur, kategori ve toplamı çıkarır, gerekirse onayına sunar.',
    'takePhoto': 'Fotoğraf çek',
    'pickFromGallery': 'Galeriden seç',
    'scanReading': 'AI okuyor...',
    'scanTotalLabel': 'Toplam',
    'scanAgain': 'Yeniden tara',
    'addToTransactions': 'İşlemlerime ekle',
    'addedToTransactions': 'İşlemlerine eklendi',
    'parsedByAi': 'AI',
    'parsedFallback': 'DEMO',
    'savingsStoryLabel': 'BU AY TASARRUF',
    'savingsStoryFooter': "Uma'nın 3 önerisiyle",
    'savingsStoryDelta': 'Geçen aya göre %{pct} daha az',
    'upcomingBills': 'Yaklaşan ödemeler',
    'billPayViaUma': 'Uma ile öde',
    'daysLeft': '{n} gün kaldı',
    'statementImport': 'Ekstre yükle',
    'statementImportTitle': 'Banka ekstresini yükle',
    'statementImportSubtitle': 'PDF veya görsel olarak ekstreni yükle, AI işlemleri çıkarsın.',
    'pickStatementFile': 'Dosya seç (PDF / görsel)',
    'statementImportHint': 'Bankan ekstreyi PDF olarak indirir; Vera bunu Açık Bankacılık olmadan da okur.',
    'statementParsing': 'AI ekstreyi okuyor...',
    'closingBalance': 'Kapanış bakiyesi',
    'detectedTransactions': '{n} işlem tespit edildi',
    'statementImportAgain': 'Yeniden yükle',
    'statementImported': 'Ekstre işlemlerine eklendi',
    'importToVera': "Vera'ya aktar",
    'openBankApp': '{bank} uygulamasını aç',
    'umaForwardNote': 'İşlem bankanda tamamlanır. Vera SMS veya ekstreyle sonucu yakalar.',
    'forwardedToBank': "{bank}'a yönlendirildi · Vera takip ediyor",
    'keep': 'Vazgeç',
    'thisMonthsAiPlan': 'Bu ayın AI önerisi',
    'aiPlanFooter': "Uma'nın önerisi — bankanda uygula, Vera kaydını tutar.",
    'applyAtBank': 'Bankamda uygula',
    'securityVeraSideBanner': 'Vera bankanın güvenlik katmanı değil. Verilerinde anomali görürse uyarır; engellemeyi sen ve bankan birlikte yaparsınız.',
    'statusAllClear': 'Her şey temiz',
    'statusMonitoring': 'İzleniyor',
    'securityRecentActivity': 'Son aktivite',
    'securityScanning': 'Tarama...',
    'liveAnomalyDetected': 'Canlı anomali tespit edildi',
    'highRiskConfidence': 'Yüksek risk',
    'reviewedSignal': 'İncelendi',
    'keepBlocked': 'Bloklu kalsın',
    'thisWasMe': 'Bu bendim',
    'continueWithDemo': 'Demo hesabıyla devam et',
    'emailField': 'E-posta',
    'passwordField': 'Şifre',
    'umaSuggestionPay': 'Kredi kartımı öde',
    'umaSuggestionSubs': 'Aboneliklerimi göster',
    'umaSuggestionAnalyze': 'Harcamalarımı analiz et',
    'voiceCommandTooltip': 'Sesli komut',
    'requireConfirmation': 'Onayımı iste',
    'requireConfirmationDesc': 'Eyleme geçmeden önce her zaman bir onay kartı göster',
    'orderFrom': 'Kimden',
    'orderTo': 'Kime',
    'orderAmount': 'Tutar',
    'accountTilePersonal': 'Kişisel bilgiler',
    'accountTileEmail': 'E-posta',
    'accountTileSecurity': 'Güvenlik & PIN',
    'accountTileStorage': 'Veri saklama',
    'accountTileHelp': 'Yardım & destek',
    'demoUser': 'Demo kullanıcı',
    'umaThinking': 'Uma düşünüyor...',
    'umaAskHint': "Uma'ya sor...",
    'umaStatusOnline': 'AI asistan · çevrimiçi',
    'umaSuggestionBuyGold': '10g altın al',
    'umaSuggestionMoveSavings': "2500 TL'yi birikime aktar",
    'umaActionPolicy': 'EYLEM POLİTİKASI',
    'umaActionPolicyDesc': 'Vera para hareketini bankanda yapar; sen her zaman onay verirsin.',
    'comingSoon': 'Yakında',
    'close': 'Kapat',
  },
  AppLocale.en: {
    'navHome': 'Home',
    'navWealth': 'Wealth',
    'navPlans': 'Plans',
    'navSecurity': 'Security',
    'navUma': 'UMA',
    'helloLabel': 'Hello,',
    'defaultUserName': 'Vera User',
    'totalNetWorth': 'TOTAL NET WORTH',
    'liveFeed': 'LIVE FEED',
    'syncing': 'SYNCING',
    'thisMonth': 'this month',
    'actionSend': 'Send',
    'actionRequest': 'Request',
    'actionTopUp': 'Top up',
    'actionPay': 'Pay',
    'connectedAccounts': 'Connected accounts',
    'refresh': 'Refresh',
    'syncingDots': 'Syncing...',
    'recentTransactions': 'Recent transactions',
    'itemsCount': '{n} items',
    'itemsVisible': 'visible',
    'connectBank': 'Connect bank',
    'umaInsight': 'UMA INSIGHT',
    'spent': 'Spent',
    'incoming': 'In',
    'creditTitle': 'Credit',
    'creditSubtitle': 'Borrowing built around your real income.',
    'creditScoreLabel': 'CREDIT SCORE',
    'openCredit': 'Open credit',
    'wealthTitle': 'Wealth',
    'wealthSubtitle': 'Your money, working autonomously.',
    'portfolio': 'PORTFOLIO',
    'ytd': 'YTD',
    'today': 'today',
    'autonomousWealth': 'Autonomous Wealth',
    'profile': 'PROFILE',
    'moveLimit': 'MOVE LIMIT',
    'approval': 'APPROVAL',
    'activityFeed': 'Activity feed',
    'explainability': 'Explainability',
    'undo': 'Undo',
    'viewDetails': 'View details',
    'plansTitle': 'Plans',
    'plansSubtitle': 'Catch silent money leaks before they stack up.',
    'subscriptionIntelligence': 'SUBSCRIPTION INTELLIGENCE',
    'detectedPlans': 'Detected plans',
    'filterAll': 'All',
    'filterAttention': 'Needs attention',
    'filterUnused': 'Unused',
    'filterPriceChanges': 'Price changes',
    'freezePlan': 'Freeze plan',
    'reviewPlan': 'Review plan',
    'askUma': 'Ask Uma',
    'securityTitle': 'Security',
    'securitySubtitle': 'Your live protection layer.',
    'profileAndSettings': 'Profile & Settings',
    'sectionAppearance': 'APPEARANCE & THEMING',
    'sectionAi': 'AI PREFERENCES',
    'sectionConnected': 'CONNECTED INSTITUTIONS',
    'sectionAccount': 'ACCOUNT',
    'sectionLanguage': 'LANGUAGE',
    'brandPalette': 'Brand palette',
    'mood': 'Mood',
    'moodLight': 'Light',
    'moodDark': 'Dark',
    'vibe': 'Vibe',
    'vibeCalm': 'Calm',
    'vibeStandard': 'Standard',
    'vibeBold': 'Bold',
    'language': 'Language',
    'signOut': 'Sign out',
    'umaTone': 'Uma tone',
    'toneConcise': 'Concise',
    'toneCoach': 'Coach',
    'toneProactive': 'Proactive',
    'scanReceipt': 'Scan',
    'scanReceiptTitle': 'Scan receipt or screen',
    'scanReceiptSubtitle': 'Capture a receipt, bill, or bank screen and turn it into a transaction.',
    'scanHint': 'AI reads the receipt, extracts category and total, then asks for your approval.',
    'takePhoto': 'Take photo',
    'pickFromGallery': 'Pick from gallery',
    'scanReading': 'AI is reading...',
    'scanTotalLabel': 'Total',
    'scanAgain': 'Scan again',
    'addToTransactions': 'Add to transactions',
    'addedToTransactions': 'Added to your transactions',
    'parsedByAi': 'AI',
    'parsedFallback': 'DEMO',
    'savingsStoryLabel': 'SAVED THIS MONTH',
    'savingsStoryFooter': "With Uma's 3 suggestions",
    'savingsStoryDelta': '{pct}% less than last month',
    'upcomingBills': 'Upcoming bills',
    'billPayViaUma': 'Pay with Uma',
    'daysLeft': '{n} days left',
    'statementImport': 'Import statement',
    'statementImportTitle': 'Import a bank statement',
    'statementImportSubtitle': 'Upload a PDF or image of your statement; AI extracts the transactions.',
    'pickStatementFile': 'Pick file (PDF / image)',
    'statementImportHint': 'Your bank exports statements as PDF — Vera reads them without Open Banking access.',
    'statementParsing': 'AI is reading the statement...',
    'closingBalance': 'Closing balance',
    'detectedTransactions': '{n} transactions detected',
    'statementImportAgain': 'Import again',
    'statementImported': 'Added to your transactions',
    'importToVera': 'Import to Vera',
    'openBankApp': 'Open {bank}',
    'umaForwardNote': 'The action completes inside your bank app. Vera tracks the outcome via SMS or statement.',
    'forwardedToBank': 'Sent to {bank} · Vera is watching',
    'keep': 'Keep',
    'thisMonthsAiPlan': "This month's AI plan",
    'aiPlanFooter': "Uma's suggestion — apply it inside your bank; Vera keeps the record.",
    'applyAtBank': 'Apply at my bank',
    'securityVeraSideBanner': "Vera is not a bank's security layer. It spots anomalies in your data and warns you; blocking happens together with you and your bank.",
    'statusAllClear': 'All clear',
    'statusMonitoring': 'Monitoring',
    'securityRecentActivity': 'Recent activity',
    'securityScanning': 'Scanning...',
    'liveAnomalyDetected': 'Live anomaly detected',
    'highRiskConfidence': 'High risk confidence',
    'reviewedSignal': 'Reviewed signal',
    'keepBlocked': 'Keep blocked',
    'thisWasMe': 'This was me',
    'continueWithDemo': 'Continue with demo account',
    'emailField': 'Email',
    'passwordField': 'Password',
    'umaSuggestionPay': 'Pay my credit card',
    'umaSuggestionSubs': 'Show my subscriptions',
    'umaSuggestionAnalyze': 'Analyze my spending',
    'voiceCommandTooltip': 'Voice command',
    'requireConfirmation': 'Require my confirmation',
    'requireConfirmationDesc': 'Always show a confirmation card first',
    'orderFrom': 'From',
    'orderTo': 'To',
    'orderAmount': 'Amount',
    'accountTilePersonal': 'Personal info',
    'accountTileEmail': 'Email',
    'accountTileSecurity': 'Security & PIN',
    'accountTileStorage': 'Storage policy',
    'accountTileHelp': 'Help & support',
    'demoUser': 'Demo user',
    'umaThinking': 'Uma is thinking...',
    'umaAskHint': 'Ask Uma anything...',
    'umaStatusOnline': 'AI assistant · online',
    'umaSuggestionBuyGold': 'Buy 10g of gold',
    'umaSuggestionMoveSavings': 'Move 2500 TL to savings',
    'umaActionPolicy': 'ACTION POLICY',
    'umaActionPolicyDesc': 'Vera never moves money itself; every action opens your bank app for your approval.',
    'comingSoon': 'Coming soon',
    'close': 'Close',
  },
  AppLocale.de: {
    'navHome': 'Start',
    'navWealth': 'Vermögen',
    'navPlans': 'Pläne',
    'navSecurity': 'Sicherheit',
    'navUma': 'UMA',
    'helloLabel': 'Hallo,',
    'defaultUserName': 'Vera Nutzer',
    'totalNetWorth': 'GESAMTVERMÖGEN',
    'liveFeed': 'LIVE',
    'syncing': 'SYNCHRO',
    'thisMonth': 'diesen Monat',
    'actionSend': 'Senden',
    'actionRequest': 'Anfordern',
    'actionTopUp': 'Aufladen',
    'actionPay': 'Zahlen',
    'connectedAccounts': 'Verbundene Konten',
    'refresh': 'Aktualisieren',
    'syncingDots': 'Synchronisieren...',
    'recentTransactions': 'Letzte Transaktionen',
    'itemsCount': '{n} Einträge',
    'itemsVisible': 'sichtbar',
    'connectBank': 'Bank verbinden',
    'umaInsight': 'UMA EINBLICK',
    'spent': 'Ausgegeben',
    'incoming': 'Eingang',
    'creditTitle': 'Kredit',
    'creditSubtitle': 'Kreditaufnahme nach echtem Einkommen.',
    'creditScoreLabel': 'KREDITPUNKTE',
    'openCredit': 'Kredit öffnen',
    'wealthTitle': 'Vermögen',
    'wealthSubtitle': 'Ihr Geld arbeitet autonom.',
    'portfolio': 'PORTFOLIO',
    'ytd': 'JTD',
    'today': 'heute',
    'autonomousWealth': 'Autonomes Vermögen',
    'profile': 'PROFIL',
    'moveLimit': 'BEWEGUNGSLIMIT',
    'approval': 'FREIGABE',
    'activityFeed': 'Aktivitäten',
    'explainability': 'Erklärbarkeit',
    'undo': 'Rückgängig',
    'viewDetails': 'Details ansehen',
    'plansTitle': 'Pläne',
    'plansSubtitle': 'Stillen Geldverlust frühzeitig erkennen.',
    'subscriptionIntelligence': 'ABONNEMENT-INTELLIGENZ',
    'detectedPlans': 'Erkannte Pläne',
    'filterAll': 'Alle',
    'filterAttention': 'Achtung nötig',
    'filterUnused': 'Ungenutzt',
    'filterPriceChanges': 'Preisänderung',
    'freezePlan': 'Plan einfrieren',
    'reviewPlan': 'Plan prüfen',
    'askUma': 'Uma fragen',
    'securityTitle': 'Sicherheit',
    'securitySubtitle': 'Ihre Live-Schutzschicht.',
    'profileAndSettings': 'Profil & Einstellungen',
    'sectionAppearance': 'DESIGN & THEMA',
    'sectionAi': 'KI-EINSTELLUNGEN',
    'sectionConnected': 'VERBUNDENE INSTITUTE',
    'sectionAccount': 'KONTO',
    'sectionLanguage': 'SPRACHE',
    'brandPalette': 'Markenpalette',
    'mood': 'Stimmung',
    'moodLight': 'Hell',
    'moodDark': 'Dunkel',
    'vibe': 'Vibe',
    'vibeCalm': 'Ruhig',
    'vibeStandard': 'Standard',
    'vibeBold': 'Mutig',
    'language': 'Sprache',
    'signOut': 'Abmelden',
    'umaTone': 'Uma-Ton',
    'toneConcise': 'Kompakt',
    'toneCoach': 'Coach',
    'toneProactive': 'Proaktiv',
    'scanReceipt': 'Scannen',
    'scanReceiptTitle': 'Beleg oder Bildschirm scannen',
    'scanReceiptSubtitle': 'Beleg, Rechnung oder Bank-Screen erfassen und in eine Buchung umwandeln.',
    'scanHint': 'KI liest den Beleg, erkennt Kategorie und Summe und fragt nach Bestätigung.',
    'takePhoto': 'Foto aufnehmen',
    'pickFromGallery': 'Aus Galerie wählen',
    'scanReading': 'KI liest...',
    'scanTotalLabel': 'Summe',
    'scanAgain': 'Erneut scannen',
    'addToTransactions': 'Zu Buchungen',
    'addedToTransactions': 'Hinzugefügt',
    'parsedByAi': 'KI',
    'parsedFallback': 'DEMO',
    'savingsStoryLabel': 'DIESEN MONAT GESPART',
    'savingsStoryFooter': 'Dank 3 Uma-Tipps',
    'savingsStoryDelta': '{pct}% weniger als letzten Monat',
    'upcomingBills': 'Anstehende Rechnungen',
    'billPayViaUma': 'Mit Uma zahlen',
    'daysLeft': 'noch {n} Tage',
    'statementImport': 'Auszug importieren',
    'statementImportTitle': 'Kontoauszug importieren',
    'statementImportSubtitle': 'PDF oder Bild deines Auszugs hochladen; KI extrahiert die Buchungen.',
    'pickStatementFile': 'Datei wählen (PDF / Bild)',
    'statementImportHint': 'Deine Bank exportiert Auszüge als PDF — Vera liest sie ohne Open-Banking-Zugang.',
    'statementParsing': 'KI liest den Auszug...',
    'closingBalance': 'Schlussbestand',
    'detectedTransactions': '{n} Buchungen erkannt',
    'statementImportAgain': 'Erneut importieren',
    'statementImported': 'Zu deinen Buchungen hinzugefügt',
    'importToVera': 'Zu Vera importieren',
    'openBankApp': '{bank} öffnen',
    'umaForwardNote': 'Die Aktion wird in deiner Bank-App abgeschlossen. Vera verfolgt das Ergebnis per SMS oder Auszug.',
    'forwardedToBank': 'An {bank} weitergeleitet · Vera beobachtet',
    'keep': 'Abbrechen',
    'thisMonthsAiPlan': 'KI-Plan für diesen Monat',
    'aiPlanFooter': 'Uma-Vorschlag — in deiner Bank umsetzen; Vera führt das Protokoll.',
    'applyAtBank': 'In meiner Bank umsetzen',
    'securityVeraSideBanner': 'Vera ist nicht die Sicherheitsschicht der Bank. Sie erkennt Anomalien in deinen Daten und warnt dich; das Blockieren entscheidest du gemeinsam mit deiner Bank.',
    'statusAllClear': 'Alles in Ordnung',
    'statusMonitoring': 'Überwachung',
    'securityRecentActivity': 'Letzte Aktivität',
    'securityScanning': 'Scannen...',
    'liveAnomalyDetected': 'Anomalie erkannt',
    'highRiskConfidence': 'Hohes Risiko',
    'reviewedSignal': 'Geprüft',
    'keepBlocked': 'Blockiert lassen',
    'thisWasMe': 'Das war ich',
    'continueWithDemo': 'Mit Demo-Konto fortfahren',
    'emailField': 'E-Mail',
    'passwordField': 'Passwort',
    'umaSuggestionPay': 'Kreditkarte bezahlen',
    'umaSuggestionSubs': 'Abos anzeigen',
    'umaSuggestionAnalyze': 'Ausgaben analysieren',
    'voiceCommandTooltip': 'Sprachbefehl',
    'requireConfirmation': 'Bestätigung verlangen',
    'requireConfirmationDesc': 'Vor jeder Aktion eine Bestätigungskarte zeigen',
    'orderFrom': 'Von',
    'orderTo': 'An',
    'orderAmount': 'Betrag',
    'accountTilePersonal': 'Persönliche Daten',
    'accountTileEmail': 'E-Mail',
    'accountTileSecurity': 'Sicherheit & PIN',
    'accountTileStorage': 'Datenspeicherung',
    'accountTileHelp': 'Hilfe & Support',
    'demoUser': 'Demo-Nutzer',
    'umaThinking': 'Uma denkt nach...',
    'umaAskHint': 'Frag Uma...',
    'umaStatusOnline': 'KI-Assistent · online',
    'umaSuggestionBuyGold': '10g Gold kaufen',
    'umaSuggestionMoveSavings': '2500 TL ins Sparen',
    'umaActionPolicy': 'AKTIONSREGEL',
    'umaActionPolicyDesc': 'Vera bewegt nie selbst Geld; jede Aktion öffnet deine Bank-App zur Bestätigung.',
    'comingSoon': 'Demnächst',
    'close': 'Schließen',
  },
  AppLocale.ar: {
    'navHome': 'الرئيسية',
    'navWealth': 'الثروة',
    'navPlans': 'الخطط',
    'navSecurity': 'الأمان',
    'navUma': 'UMA',
    'helloLabel': 'مرحبًا،',
    'defaultUserName': 'مستخدم فيرا',
    'totalNetWorth': 'إجمالي صافي الثروة',
    'liveFeed': 'مباشر',
    'syncing': 'مزامنة',
    'thisMonth': 'هذا الشهر',
    'actionSend': 'إرسال',
    'actionRequest': 'طلب',
    'actionTopUp': 'شحن',
    'actionPay': 'دفع',
    'connectedAccounts': 'الحسابات المتصلة',
    'refresh': 'تحديث',
    'syncingDots': 'جارٍ المزامنة...',
    'recentTransactions': 'المعاملات الأخيرة',
    'itemsCount': '{n} عناصر',
    'itemsVisible': 'مرئية',
    'connectBank': 'ربط بنك',
    'umaInsight': 'رؤية UMA',
    'spent': 'منفق',
    'incoming': 'وارد',
    'creditTitle': 'الائتمان',
    'creditSubtitle': 'اقتراض مبني على دخلك الفعلي.',
    'creditScoreLabel': 'درجة الائتمان',
    'openCredit': 'فتح الائتمان',
    'wealthTitle': 'الثروة',
    'wealthSubtitle': 'أموالك تعمل باستقلالية.',
    'portfolio': 'المحفظة',
    'ytd': 'من بداية السنة',
    'today': 'اليوم',
    'autonomousWealth': 'ثروة ذاتية',
    'profile': 'الملف',
    'moveLimit': 'حد التحويل',
    'approval': 'الموافقة',
    'activityFeed': 'سجل النشاط',
    'explainability': 'القابلية للشرح',
    'undo': 'تراجع',
    'viewDetails': 'عرض التفاصيل',
    'plansTitle': 'الخطط',
    'plansSubtitle': 'اكتشف تسريبات المال الصامتة.',
    'subscriptionIntelligence': 'ذكاء الاشتراكات',
    'detectedPlans': 'الخطط المكتشفة',
    'filterAll': 'الكل',
    'filterAttention': 'تحتاج انتباه',
    'filterUnused': 'غير مستخدمة',
    'filterPriceChanges': 'تغير السعر',
    'freezePlan': 'تجميد الخطة',
    'reviewPlan': 'مراجعة الخطة',
    'askUma': 'اسأل UMA',
    'securityTitle': 'الأمان',
    'securitySubtitle': 'طبقة حمايتك المباشرة.',
    'profileAndSettings': 'الملف والإعدادات',
    'sectionAppearance': 'المظهر والتصميم',
    'sectionAi': 'تفضيلات الذكاء',
    'sectionConnected': 'المؤسسات المتصلة',
    'sectionAccount': 'الحساب',
    'sectionLanguage': 'اللغة',
    'brandPalette': 'لوحة الألوان',
    'mood': 'الوضع',
    'moodLight': 'فاتح',
    'moodDark': 'داكن',
    'vibe': 'الأجواء',
    'vibeCalm': 'هادئ',
    'vibeStandard': 'قياسي',
    'vibeBold': 'جريء',
    'language': 'اللغة',
    'signOut': 'تسجيل الخروج',
    'umaTone': 'نبرة UMA',
    'toneConcise': 'مختصر',
    'toneCoach': 'مدرب',
    'toneProactive': 'استباقي',
    'scanReceipt': 'مسح',
    'scanReceiptTitle': 'مسح إيصال أو شاشة',
    'scanReceiptSubtitle': 'التقط إيصالاً أو فاتورة أو شاشة بنك وحوّلها إلى معاملة.',
    'scanHint': 'يقرأ الذكاء الاصطناعي الإيصال، يستخرج الفئة والإجمالي ويطلب موافقتك.',
    'takePhoto': 'التقاط صورة',
    'pickFromGallery': 'اختيار من المعرض',
    'scanReading': 'يقرأ الذكاء الاصطناعي...',
    'scanTotalLabel': 'الإجمالي',
    'scanAgain': 'مسح مجددًا',
    'addToTransactions': 'أضف إلى المعاملات',
    'addedToTransactions': 'تمت الإضافة',
    'parsedByAi': 'ذكاء',
    'parsedFallback': 'تجريبي',
    'savingsStoryLabel': 'وفّرت هذا الشهر',
    'savingsStoryFooter': 'بفضل 3 اقتراحات من UMA',
    'savingsStoryDelta': '{pct}% أقل من الشهر الماضي',
    'upcomingBills': 'الفواتير القادمة',
    'billPayViaUma': 'الدفع عبر UMA',
    'daysLeft': 'متبقي {n} يوم',
    'statementImport': 'استيراد كشف',
    'statementImportTitle': 'استيراد كشف الحساب',
    'statementImportSubtitle': 'حمّل كشفك بصيغة PDF أو صورة، وسيستخرج الذكاء الاصطناعي المعاملات.',
    'pickStatementFile': 'اختر ملفًا (PDF / صورة)',
    'statementImportHint': 'بنكك يصدّر الكشف بصيغة PDF — تقرؤه Vera دون الحاجة إلى الخدمات المصرفية المفتوحة.',
    'statementParsing': 'يقرأ الذكاء الاصطناعي الكشف...',
    'closingBalance': 'الرصيد الختامي',
    'detectedTransactions': 'تم اكتشاف {n} معاملة',
    'statementImportAgain': 'استيراد مجددًا',
    'statementImported': 'تمت الإضافة إلى معاملاتك',
    'importToVera': 'استيراد إلى Vera',
    'openBankApp': 'فتح {bank}',
    'umaForwardNote': 'تكتمل العملية داخل تطبيق بنكك. تتابع Vera النتيجة عبر الرسائل أو الكشف.',
    'forwardedToBank': 'أُرسل إلى {bank} · Vera تراقب',
    'keep': 'إبقاء',
    'thisMonthsAiPlan': 'خطة الذكاء الاصطناعي لهذا الشهر',
    'aiPlanFooter': 'اقتراح Uma — طبّقه عبر بنكك، وVera تحتفظ بالسجل.',
    'applyAtBank': 'تطبيق عبر بنكي',
    'securityVeraSideBanner': 'Vera ليست طبقة الأمان للبنك. ترصد الشذوذ في بياناتك وتنبهك؛ القرار يكون بينك وبنكك.',
    'statusAllClear': 'كل شيء آمن',
    'statusMonitoring': 'مراقبة',
    'securityRecentActivity': 'النشاط الأخير',
    'securityScanning': 'جارٍ المسح...',
    'liveAnomalyDetected': 'تم رصد حالة شاذة',
    'highRiskConfidence': 'مخاطر عالية',
    'reviewedSignal': 'تمت المراجعة',
    'keepBlocked': 'إبقاء الحظر',
    'thisWasMe': 'كنت أنا',
    'continueWithDemo': 'متابعة بحساب تجريبي',
    'emailField': 'البريد الإلكتروني',
    'passwordField': 'كلمة المرور',
    'umaSuggestionPay': 'ادفع بطاقتي الائتمانية',
    'umaSuggestionSubs': 'عرض اشتراكاتي',
    'umaSuggestionAnalyze': 'حلّل مصروفاتي',
    'voiceCommandTooltip': 'أمر صوتي',
    'requireConfirmation': 'اطلب موافقتي',
    'requireConfirmationDesc': 'أظهر بطاقة تأكيد قبل أي إجراء',
    'orderFrom': 'من',
    'orderTo': 'إلى',
    'orderAmount': 'المبلغ',
    'accountTilePersonal': 'المعلومات الشخصية',
    'accountTileEmail': 'البريد الإلكتروني',
    'accountTileSecurity': 'الأمان وPIN',
    'accountTileStorage': 'سياسة التخزين',
    'accountTileHelp': 'مساعدة ودعم',
    'demoUser': 'مستخدم تجريبي',
    'umaThinking': 'Uma تفكر...',
    'umaAskHint': 'اسأل Uma...',
    'umaStatusOnline': 'مساعد ذكاء · متصل',
    'umaSuggestionBuyGold': 'اشترِ 10 جرام ذهب',
    'umaSuggestionMoveSavings': 'حوّل 2500 ليرة إلى الادخار',
    'umaActionPolicy': 'سياسة الإجراء',
    'umaActionPolicyDesc': 'Vera لا تحرّك الأموال بنفسها؛ كل إجراء يفتح تطبيق بنكك لتأكيدك.',
    'comingSoon': 'قريباً',
    'close': 'إغلاق',
  },
  AppLocale.ru: {
    'navHome': 'Главная',
    'navWealth': 'Капитал',
    'navPlans': 'Планы',
    'navSecurity': 'Защита',
    'navUma': 'UMA',
    'helloLabel': 'Привет,',
    'defaultUserName': 'Пользователь Vera',
    'totalNetWorth': 'ОБЩИЙ КАПИТАЛ',
    'liveFeed': 'ОНЛАЙН',
    'syncing': 'СИНХРО',
    'thisMonth': 'в этом месяце',
    'actionSend': 'Отправить',
    'actionRequest': 'Запросить',
    'actionTopUp': 'Пополнить',
    'actionPay': 'Оплатить',
    'connectedAccounts': 'Подключённые счета',
    'refresh': 'Обновить',
    'syncingDots': 'Синхронизация...',
    'recentTransactions': 'Последние операции',
    'itemsCount': '{n} операций',
    'itemsVisible': 'видно',
    'connectBank': 'Подключить банк',
    'umaInsight': 'ИНСАЙТ UMA',
    'spent': 'Расход',
    'incoming': 'Доход',
    'creditTitle': 'Кредит',
    'creditSubtitle': 'Кредит на основе реального дохода.',
    'creditScoreLabel': 'КРЕДИТНЫЙ РЕЙТИНГ',
    'openCredit': 'Открыть кредит',
    'wealthTitle': 'Капитал',
    'wealthSubtitle': 'Ваши деньги работают сами.',
    'portfolio': 'ПОРТФЕЛЬ',
    'ytd': 'С НГ',
    'today': 'сегодня',
    'autonomousWealth': 'Автономный капитал',
    'profile': 'ПРОФИЛЬ',
    'moveLimit': 'ЛИМИТ',
    'approval': 'УТВЕРЖД.',
    'activityFeed': 'Активность',
    'explainability': 'Объяснимость',
    'undo': 'Отменить',
    'viewDetails': 'Подробнее',
    'plansTitle': 'Планы',
    'plansSubtitle': 'Ловите тихие утечки денег.',
    'subscriptionIntelligence': 'АНАЛИЗ ПОДПИСОК',
    'detectedPlans': 'Найденные планы',
    'filterAll': 'Все',
    'filterAttention': 'Нужно внимание',
    'filterUnused': 'Неиспользуемые',
    'filterPriceChanges': 'Изменение цены',
    'freezePlan': 'Заморозить план',
    'reviewPlan': 'Проверить план',
    'askUma': 'Спросить UMA',
    'securityTitle': 'Защита',
    'securitySubtitle': 'Активный уровень защиты.',
    'profileAndSettings': 'Профиль и настройки',
    'sectionAppearance': 'ВНЕШНИЙ ВИД',
    'sectionAi': 'НАСТРОЙКИ ИИ',
    'sectionConnected': 'ПОДКЛЮЧЁННЫЕ ОРГАНИЗАЦИИ',
    'sectionAccount': 'АККАУНТ',
    'sectionLanguage': 'ЯЗЫК',
    'brandPalette': 'Палитра бренда',
    'mood': 'Тема',
    'moodLight': 'Светлая',
    'moodDark': 'Тёмная',
    'vibe': 'Стиль',
    'vibeCalm': 'Спокойный',
    'vibeStandard': 'Стандартный',
    'vibeBold': 'Яркий',
    'language': 'Язык',
    'signOut': 'Выйти',
    'umaTone': 'Тон Uma',
    'toneConcise': 'Кратко',
    'toneCoach': 'Коуч',
    'toneProactive': 'Проактивно',
    'scanReceipt': 'Сканер',
    'scanReceiptTitle': 'Сканировать чек или экран',
    'scanReceiptSubtitle': 'Снимите чек, счёт или экран банка — ИИ превратит его в операцию.',
    'scanHint': 'ИИ читает чек, выделяет категорию и сумму, спрашивает подтверждение.',
    'takePhoto': 'Сделать фото',
    'pickFromGallery': 'Из галереи',
    'scanReading': 'ИИ читает...',
    'scanTotalLabel': 'Итого',
    'scanAgain': 'Сканировать снова',
    'addToTransactions': 'Добавить к операциям',
    'addedToTransactions': 'Добавлено',
    'parsedByAi': 'ИИ',
    'parsedFallback': 'DEMO',
    'savingsStoryLabel': 'СБЕРЕЖЕНО ЗА МЕСЯЦ',
    'savingsStoryFooter': 'Благодаря 3 советам Uma',
    'savingsStoryDelta': 'На {pct}% меньше, чем в прошлом месяце',
    'upcomingBills': 'Предстоящие платежи',
    'billPayViaUma': 'Оплатить через Uma',
    'daysLeft': 'осталось {n} дн.',
    'statementImport': 'Импорт выписки',
    'statementImportTitle': 'Импорт банковской выписки',
    'statementImportSubtitle': 'Загрузите PDF или скриншот выписки; ИИ извлечёт операции.',
    'pickStatementFile': 'Выбрать файл (PDF / изображение)',
    'statementImportHint': 'Банк отдаёт выписку в PDF — Vera читает её без подключения к Open Banking.',
    'statementParsing': 'ИИ читает выписку...',
    'closingBalance': 'Остаток',
    'detectedTransactions': 'Найдено {n} операций',
    'statementImportAgain': 'Импорт ещё раз',
    'statementImported': 'Добавлено в ваши операции',
    'importToVera': 'Импорт в Vera',
    'openBankApp': 'Открыть {bank}',
    'umaForwardNote': 'Действие завершается в банковском приложении. Vera отслеживает результат по SMS или выписке.',
    'forwardedToBank': 'Передано в {bank} · Vera следит',
    'keep': 'Отмена',
    'thisMonthsAiPlan': 'План ИИ на этот месяц',
    'aiPlanFooter': 'Совет Uma — выполните в своём банке; Vera ведёт учёт.',
    'applyAtBank': 'Сделать в банке',
    'securityVeraSideBanner': 'Vera не является службой безопасности банка. Она замечает аномалии в ваших данных и предупреждает вас; блокировку вы решаете вместе с банком.',
    'statusAllClear': 'Всё чисто',
    'statusMonitoring': 'Наблюдение',
    'securityRecentActivity': 'Недавняя активность',
    'securityScanning': 'Сканирование...',
    'liveAnomalyDetected': 'Аномалия обнаружена',
    'highRiskConfidence': 'Высокий риск',
    'reviewedSignal': 'Проверено',
    'keepBlocked': 'Оставить заблокированным',
    'thisWasMe': 'Это был я',
    'continueWithDemo': 'Войти с демо-аккаунтом',
    'emailField': 'E-mail',
    'passwordField': 'Пароль',
    'umaSuggestionPay': 'Оплатить мою карту',
    'umaSuggestionSubs': 'Показать подписки',
    'umaSuggestionAnalyze': 'Анализировать траты',
    'voiceCommandTooltip': 'Голосовая команда',
    'requireConfirmation': 'Требовать подтверждение',
    'requireConfirmationDesc': 'Показывать карточку подтверждения перед действием',
    'orderFrom': 'От',
    'orderTo': 'Кому',
    'orderAmount': 'Сумма',
    'accountTilePersonal': 'Личные данные',
    'accountTileEmail': 'E-mail',
    'accountTileSecurity': 'Безопасность и PIN',
    'accountTileStorage': 'Политика хранения',
    'accountTileHelp': 'Помощь и поддержка',
    'demoUser': 'Демо-пользователь',
    'umaThinking': 'Uma думает...',
    'umaAskHint': 'Спросите Uma...',
    'umaStatusOnline': 'ИИ-ассистент · онлайн',
    'umaSuggestionBuyGold': 'Купить 10 г золота',
    'umaSuggestionMoveSavings': 'Перевести 2500 TL в сбережения',
    'umaActionPolicy': 'ПОЛИТИКА ДЕЙСТВИЙ',
    'umaActionPolicyDesc': 'Vera не двигает деньги сама; каждое действие открывает банковское приложение для вашего подтверждения.',
    'comingSoon': 'Скоро',
    'close': 'Закрыть',
  },
  AppLocale.zh: {
    'navHome': '首页',
    'navWealth': '财富',
    'navPlans': '订阅',
    'navSecurity': '安全',
    'navUma': 'UMA',
    'helloLabel': '你好，',
    'defaultUserName': 'Vera 用户',
    'totalNetWorth': '净资产总额',
    'liveFeed': '实时',
    'syncing': '同步中',
    'thisMonth': '本月',
    'actionSend': '发送',
    'actionRequest': '请求',
    'actionTopUp': '充值',
    'actionPay': '支付',
    'connectedAccounts': '已连接账户',
    'refresh': '刷新',
    'syncingDots': '同步中...',
    'recentTransactions': '最近交易',
    'itemsCount': '{n} 笔',
    'itemsVisible': '显示',
    'connectBank': '连接银行',
    'umaInsight': 'UMA 洞察',
    'spent': '支出',
    'incoming': '收入',
    'creditTitle': '信贷',
    'creditSubtitle': '基于您真实收入的借贷。',
    'creditScoreLabel': '信用评分',
    'openCredit': '打开信贷',
    'wealthTitle': '财富',
    'wealthSubtitle': '您的资金自主运作。',
    'portfolio': '投资组合',
    'ytd': '年初至今',
    'today': '今日',
    'autonomousWealth': '自主财富',
    'profile': '档案',
    'moveLimit': '操作上限',
    'approval': '审批',
    'activityFeed': '动态',
    'explainability': '可解释性',
    'undo': '撤销',
    'viewDetails': '查看详情',
    'plansTitle': '订阅',
    'plansSubtitle': '提前发现隐性支出。',
    'subscriptionIntelligence': '订阅智能',
    'detectedPlans': '已识别订阅',
    'filterAll': '全部',
    'filterAttention': '需关注',
    'filterUnused': '未使用',
    'filterPriceChanges': '价格变动',
    'freezePlan': '冻结订阅',
    'reviewPlan': '查看订阅',
    'askUma': '问 UMA',
    'securityTitle': '安全',
    'securitySubtitle': '您的实时防护层。',
    'profileAndSettings': '档案与设置',
    'sectionAppearance': '外观与主题',
    'sectionAi': 'AI 偏好',
    'sectionConnected': '已连接机构',
    'sectionAccount': '账户',
    'sectionLanguage': '语言',
    'brandPalette': '品牌色',
    'mood': '模式',
    'moodLight': '浅色',
    'moodDark': '深色',
    'vibe': '风格',
    'vibeCalm': '安静',
    'vibeStandard': '标准',
    'vibeBold': '大胆',
    'language': '语言',
    'signOut': '退出登录',
    'umaTone': 'Uma 语气',
    'toneConcise': '简洁',
    'toneCoach': '教练',
    'toneProactive': '主动',
    'scanReceipt': '扫描',
    'scanReceiptTitle': '扫描收据或屏幕',
    'scanReceiptSubtitle': '拍摄收据、账单或银行屏幕，AI 自动转为一笔交易。',
    'scanHint': 'AI 阅读凭据，识别类别和金额，并请求您确认。',
    'takePhoto': '拍照',
    'pickFromGallery': '从相册选择',
    'scanReading': 'AI 正在识别...',
    'scanTotalLabel': '合计',
    'scanAgain': '重新扫描',
    'addToTransactions': '加入交易',
    'addedToTransactions': '已加入您的交易',
    'parsedByAi': 'AI',
    'parsedFallback': '演示',
    'savingsStoryLabel': '本月节省',
    'savingsStoryFooter': '基于 Uma 的 3 条建议',
    'savingsStoryDelta': '比上月少 {pct}%',
    'upcomingBills': '即将到期账单',
    'billPayViaUma': '通过 Uma 支付',
    'daysLeft': '剩余 {n} 天',
    'statementImport': '导入对账单',
    'statementImportTitle': '导入银行对账单',
    'statementImportSubtitle': '上传 PDF 或截图，AI 自动提取交易。',
    'pickStatementFile': '选择文件（PDF / 图片）',
    'statementImportHint': '银行可导出 PDF 对账单——无需开放银行接口，Vera 即可识别。',
    'statementParsing': 'AI 正在阅读对账单...',
    'closingBalance': '期末余额',
    'detectedTransactions': '识别到 {n} 笔交易',
    'statementImportAgain': '重新导入',
    'statementImported': '已加入您的交易',
    'importToVera': '导入到 Vera',
    'openBankApp': '打开 {bank}',
    'umaForwardNote': '交易将在您的银行应用内完成。Vera 通过短信或对账单跟踪结果。',
    'forwardedToBank': '已转交 {bank} · Vera 正在跟踪',
    'keep': '取消',
    'thisMonthsAiPlan': '本月 AI 计划',
    'aiPlanFooter': 'Uma 建议——在您的银行执行，Vera 会记录结果。',
    'applyAtBank': '在我的银行执行',
    'securityVeraSideBanner': 'Vera 并非银行的安全层。它在您的数据中识别异常并提醒您；拦截由您和银行共同决定。',
    'statusAllClear': '一切正常',
    'statusMonitoring': '监控中',
    'securityRecentActivity': '近期活动',
    'securityScanning': '正在扫描...',
    'liveAnomalyDetected': '检测到异常',
    'highRiskConfidence': '高风险',
    'reviewedSignal': '已复核',
    'keepBlocked': '保持拦截',
    'thisWasMe': '这是我本人',
    'continueWithDemo': '使用演示账户继续',
    'emailField': '电子邮箱',
    'passwordField': '密码',
    'umaSuggestionPay': '支付我的信用卡',
    'umaSuggestionSubs': '查看我的订阅',
    'umaSuggestionAnalyze': '分析我的消费',
    'voiceCommandTooltip': '语音指令',
    'requireConfirmation': '需要我的确认',
    'requireConfirmationDesc': '执行前先显示确认卡片',
    'orderFrom': '来自',
    'orderTo': '到',
    'orderAmount': '金额',
    'accountTilePersonal': '个人信息',
    'accountTileEmail': '电子邮箱',
    'accountTileSecurity': '安全和 PIN',
    'accountTileStorage': '数据存储',
    'accountTileHelp': '帮助与支持',
    'demoUser': '演示用户',
    'umaThinking': 'Uma 思考中...',
    'umaAskHint': '问 Uma 任何事...',
    'umaStatusOnline': 'AI 助理 · 在线',
    'umaSuggestionBuyGold': '买 10 克黄金',
    'umaSuggestionMoveSavings': '把 2500 TL 转到储蓄',
    'umaActionPolicy': '操作政策',
    'umaActionPolicyDesc': 'Vera 不直接转账；每个动作都会打开您的银行应用让您确认。',
    'comingSoon': '即将推出',
    'close': '关闭',
  },
};

/// InheritedWidget for ergonomic `context.l10n.someKey` access.
class StringsProvider extends InheritedWidget {
  const StringsProvider({
    required this.strings,
    required super.child,
    super.key,
  });

  final AppStrings strings;

  static AppStrings of(BuildContext context) {
    final p = context.dependOnInheritedWidgetOfExactType<StringsProvider>();
    assert(p != null, 'StringsProvider not found in widget tree');
    return p!.strings;
  }

  @override
  bool updateShouldNotify(StringsProvider old) =>
      strings.locale != old.strings.locale;
}

extension StringsX on BuildContext {
  AppStrings get l10n => StringsProvider.of(this);
}
