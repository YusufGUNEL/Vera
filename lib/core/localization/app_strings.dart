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
  String get firstSyncPending => _t('firstSyncPending');
  String updatedAt(String time) =>
      _t('updatedAt').replaceAll('{time}', time);
  String get firstScanPending => _t('firstScanPending');
  String lastScanAt(String time) =>
      _t('lastScanAt').replaceAll('{time}', time);
  String get recentTransactions => _t('recentTransactions');
  String itemsCount(int n) => _t('itemsCount').replaceAll('{n}', '$n');
  String get itemsVisible => _t('itemsVisible');
  String get connectBank => _t('connectBank');
  String get addBankTitle => _t('addBankTitle');
  String get addBankSubtitle => _t('addBankSubtitle');
  String get addBankName => _t('addBankName');
  String get addBankLast4 => _t('addBankLast4');
  String get addBankBalance => _t('addBankBalance');
  String get addBankColor => _t('addBankColor');
  String get addBankSave => _t('addBankSave');
  String get addBankNameRequired => _t('addBankNameRequired');
  String bankAdded(String name) =>
      _t('bankAdded').replaceAll('{name}', name);
  String get umaInsight => _t('umaInsight');
  String get spent => _t('spent');
  String get incoming => _t('incoming');

  // ---- Credit screen ----
  String get creditHealthScore => _t('creditHealthScore');
  String get creditStatIncome => _t('creditStatIncome');
  String get creditStatDti => _t('creditStatDti');
  String get creditStatTerm => _t('creditStatTerm');
  String creditTermMo(int n) =>
      _t('creditTermMo').replaceAll('{n}', '$n');
  String creditTermMonths(int n) =>
      _t('creditTermMonths').replaceAll('{n}', '$n');
  String get creditRunSimulation => _t('creditRunSimulation');
  String get creditCurrentDecision => _t('creditCurrentDecision');
  String creditPersonalLoan(String amount) =>
      _t('creditPersonalLoan').replaceAll('{amount}', amount);
  String creditMonthsApr(int n, String apr) =>
      _t('creditMonthsApr').replaceAll('{n}', '$n').replaceAll('{apr}', apr);
  String get creditUmaInsight => _t('creditUmaInsight');
  String get creditEligibleProducts => _t('creditEligibleProducts');
  String get creditLoanSimulation => _t('creditLoanSimulation');
  String get creditLoanSimulationSubtitle => _t('creditLoanSimulationSubtitle');
  String get creditFieldLoanAmount => _t('creditFieldLoanAmount');
  String get creditFieldTerm => _t('creditFieldTerm');
  String get creditFieldIncome => _t('creditFieldIncome');
  String get creditFieldDebt => _t('creditFieldDebt');

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

  // ---- Subscriptions detail ----
  String get subsRenewalLabel => _t('subsRenewalLabel');
  String get subsActivityLabel => _t('subsActivityLabel');

  // ---- Profile (AI / Sync / Auto / Notifications) ----
  String get profileDailyBriefing => _t('profileDailyBriefing');
  String get profileDailyBriefingSub => _t('profileDailyBriefingSub');
  String get profileLiveSync => _t('profileLiveSync');
  String get profileLiveSyncLive => _t('profileLiveSyncLive');
  String get profileLiveSyncBalanced => _t('profileLiveSyncBalanced');
  String get profileLiveSyncSaver => _t('profileLiveSyncSaver');
  String get profileAutoApprove => _t('profileAutoApprove');
  String get profileAutoApproveOff => _t('profileAutoApproveOff');
  String get profileSmartNotif => _t('profileSmartNotif');
  String get profileSmartNotifSub => _t('profileSmartNotifSub');
  String get profileFaceId => _t('profileFaceId');
  String get profileFaceIdSub => _t('profileFaceIdSub');
  String get profileFraudHigh => _t('profileFraudHigh');
  String get profileFraudHighSub => _t('profileFraudHighSub');
  String get profileVaultTitle => _t('profileVaultTitle');
  String get profileVaultSubtitle => _t('profileVaultSubtitle');
  String get profileVaultSignIn => _t('profileVaultSignIn');
  String get profileVaultProtectedSince => _t('profileVaultProtectedSince');
  String get profileVaultSyncMode => _t('profileVaultSyncMode');
  String get profileVaultApproval => _t('profileVaultApproval');
  String get profileVaultThisDevice => _t('profileVaultThisDevice');
  String get profileVaultManualOnly => _t('profileVaultManualOnly');
  String get profileVaultSyncLive => _t('profileVaultSyncLive');
  String get profileVaultSyncBalanced => _t('profileVaultSyncBalanced');
  String get profileVaultSyncSaver => _t('profileVaultSyncSaver');
  String profileAiToneBadge(String tone) =>
      _t('profileAiToneBadge').replaceAll('{tone}', tone);
  String profileConnectedTitle(int n) =>
      _t('profileConnectedTitle').replaceAll('{n}', '$n');
  String get profileConnectedSubtitle => _t('profileConnectedSubtitle');
  String profileConnectedAccount(String last4) =>
      _t('profileConnectedAccount').replaceAll('{last4}', last4);

  // ---- UMA order card titles ----
  String get orderTitleBuyGold => _t('orderTitleBuyGold');
  String get orderTitlePayCard => _t('orderTitlePayCard');
  String get orderTitleGoldRate => _t('orderTitleGoldRate');
  String get orderTitleDue => _t('orderTitleDue');
  String get orderTitleDueToday => _t('orderTitleDueToday');

  // ---- UMA order card ----
  String get orderPillReady => _t('orderPillReady');
  String get orderPillSent => _t('orderPillSent');
  String get orderPillDismissed => _t('orderPillDismissed');

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
  String get securityStatBlockedLabel => _t('securityStatBlockedLabel');
  String get securityStatBlockedSub => _t('securityStatBlockedSub');
  String get securityStatReviewedLabel => _t('securityStatReviewedLabel');
  String get securityStatReviewedSub => _t('securityStatReviewedSub');
  String get securityStatDevicesLabel => _t('securityStatDevicesLabel');
  String get securityStatDevicesSub => _t('securityStatDevicesSub');
  String get securityAccountSection => _t('securityAccountSection');
  String get securityClearBody => _t('securityClearBody');
  String securityActiveBody(int n) =>
      _t('securityActiveBody').replaceAll('{n}', '$n');
  String get securityViewReport => _t('securityViewReport');
  String get securityDecisionKept => _t('securityDecisionKept');
  String get securityDecisionApproved => _t('securityDecisionApproved');
  String get securityPillBlocked => _t('securityPillBlocked');
  String get securityPillKept => _t('securityPillKept');
  String get securityPillApproved => _t('securityPillApproved');

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
  String get scanNoTotal => _t('scanNoTotal');
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
  String get statementNoTransactions => _t('statementNoTransactions');
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
  String get loginTitle => _t('loginTitle');
  String get loginSubtitle => _t('loginSubtitle');
  String get loginDisplayName => _t('loginDisplayName');
  String get loginDisplayNameHint => _t('loginDisplayNameHint');
  String get loginEmailHint => _t('loginEmailHint');
  String get loginFooter => _t('loginFooter');

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
  String get infoDisplayName => _t('infoDisplayName');
  String get infoMember => _t('infoMember');
  String get infoMemberDescription => _t('infoMemberDescription');
  String get infoEmailLabel => _t('infoEmailLabel');
  String get infoEmailUsage => _t('infoEmailUsage');
  String get infoEmailDescription => _t('infoEmailDescription');
  String get infoSessionVault => _t('infoSessionVault');
  String get infoSessionVaultDescription => _t('infoSessionVaultDescription');
  String get infoFaceId => _t('infoFaceId');
  String get infoFaceIdOn => _t('infoFaceIdOn');
  String get infoFaceIdOff => _t('infoFaceIdOff');
  String get infoFraudAlerts => _t('infoFraudAlerts');
  String get infoFraudAlertsOn => _t('infoFraudAlertsOn');
  String get infoFraudAlertsOff => _t('infoFraudAlertsOff');
  String get infoSyncMode => _t('infoSyncMode');
  String get infoLocalData => _t('infoLocalData');
  String get infoLocalDataDescription => _t('infoLocalDataDescription');
  String get helpFaqQ1 => _t('helpFaqQ1');
  String get helpFaqA1 => _t('helpFaqA1');
  String get helpFaqQ2 => _t('helpFaqQ2');
  String get helpFaqA2 => _t('helpFaqA2');
  String get helpFaqQ3 => _t('helpFaqQ3');
  String get helpFaqA3 => _t('helpFaqA3');
  String get helpContact => _t('helpContact');
  String get demoUser => _t('demoUser');

  // ---- UMA greeting ----
  String umaGreeting(String name) =>
      _t('umaGreeting').replaceAll('{name}', name);

  // ---- UMA fallback replies ----
  String umaReplyBuyGold(String bank) =>
      _t('umaReplyBuyGold').replaceAll('{bank}', bank);
  String umaReplyPayCard(String bank) =>
      _t('umaReplyPayCard').replaceAll('{bank}', bank);
  String umaReplyMoveSavings(int pct) =>
      _t('umaReplyMoveSavings').replaceAll('{pct}', '$pct');
  String umaReplySubscriptions(int n, String total) => _t('umaReplySubscriptions')
      .replaceAll('{n}', '$n')
      .replaceAll('{total}', total);
  String umaReplySubscriptionsEmpty() => _t('umaReplySubscriptionsEmpty');
  String umaReplyAnalyze(String top, String topAmount, String spending) =>
      _t('umaReplyAnalyze')
          .replaceAll('{top}', top)
          .replaceAll('{topAmount}', topAmount)
          .replaceAll('{spending}', spending);
  String umaReplyAnalyzeEmpty() => _t('umaReplyAnalyzeEmpty');
  String get umaReplyExplainWealth => _t('umaReplyExplainWealth');
  String get umaReplyLoan => _t('umaReplyLoan');
  String get umaReplySecurity => _t('umaReplySecurity');
  String get umaReplyFallback => _t('umaReplyFallback');

  // ---- UMA chat misc ----
  String get umaThinking => _t('umaThinking');
  String get umaAskHint => _t('umaAskHint');
  String get umaStatusOnline => _t('umaStatusOnline');
  String get umaSuggestionBuyGold => _t('umaSuggestionBuyGold');
  String get umaSuggestionMoveSavings => _t('umaSuggestionMoveSavings');
  String get umaActionPolicy => _t('umaActionPolicy');
  String get umaActionPolicyDesc => _t('umaActionPolicyDesc');
  String get umaFeedbackLabel => _t('umaFeedbackLabel');
  String get umaFeedbackHelpful => _t('umaFeedbackHelpful');
  String get umaFeedbackNotHelpful => _t('umaFeedbackNotHelpful');
  String get umaFeedbackAddNote => _t('umaFeedbackAddNote');
  String get umaFeedbackEditNote => _t('umaFeedbackEditNote');
  String get umaFeedbackHelpfulTitle => _t('umaFeedbackHelpfulTitle');
  String get umaFeedbackNotHelpfulTitle => _t('umaFeedbackNotHelpfulTitle');
  String get umaFeedbackNoteHint => _t('umaFeedbackNoteHint');
  String get umaFeedbackPlaceholder => _t('umaFeedbackPlaceholder');
  String get umaFeedbackSave => _t('umaFeedbackSave');
  String get umaFeedbackSkipNote => _t('umaFeedbackSkipNote');
  String get umaFeedbackSaved => _t('umaFeedbackSaved');
  String get umaFeedbackSavedWithNote => _t('umaFeedbackSavedWithNote');

  // ---- Category budget ----
  String get categoryBudgetLabel => _t('categoryBudgetLabel');
  String get categoryOther => _t('categoryOther');
  String categoryBudgetTopHint(String category, String pct) => _t(
        'categoryBudgetTopHint',
      ).replaceAll('{category}', category).replaceAll('{pct}', pct);
  String categoryRemaining(String amount) =>
      _t('categoryRemaining').replaceAll('{amount}', amount);
  String categoryOver(String amount) =>
      _t('categoryOver').replaceAll('{amount}', amount);
  String get categoryNoLimit => _t('categoryNoLimit');
  String get categoryLimitEditTitle => _t('categoryLimitEditTitle');
  String categoryLimitEditSubtitle(String category) =>
      _t('categoryLimitEditSubtitle').replaceAll('{category}', category);
  String get categoryLimitField => _t('categoryLimitField');
  String get categoryLimitSave => _t('categoryLimitSave');
  String get categoryLimitClear => _t('categoryLimitClear');

  // ---- Goals (emergency fund) ----
  String get goalsSectionTitle => _t('goalsSectionTitle');
  String get goalEmergencyFund => _t('goalEmergencyFund');
  String goalProgress(String pct) =>
      _t('goalProgress').replaceAll('{pct}', pct);
  String goalRemaining(String amount) =>
      _t('goalRemaining').replaceAll('{amount}', amount);
  String get goalEditTitle => _t('goalEditTitle');
  String get goalEditTarget => _t('goalEditTarget');
  String get goalEditSaved => _t('goalEditSaved');
  String get goalEditSave => _t('goalEditSave');
  String get goalEditFooter => _t('goalEditFooter');
  String goalEtaMonths(int n) =>
      _t('goalEtaMonths').replaceAll('{n}', '$n');
  String get goalEtaReached => _t('goalEtaReached');

  // ---- Bank actions / delete ----
  String get bankActionsTitle => _t('bankActionsTitle');
  String get bankActionsDelete => _t('bankActionsDelete');
  String get bankActionsCancel => _t('bankActionsCancel');
  String get bankActionsConfirmTitle => _t('bankActionsConfirmTitle');
  String bankActionsConfirmBody(String name) =>
      _t('bankActionsConfirmBody').replaceAll('{name}', name);
  String bankDeleted(String name) =>
      _t('bankDeleted').replaceAll('{name}', name);
  String get bankActionsFeedNote => _t('bankActionsFeedNote');

  // ---- UMA prompts (quick actions on home) ----
  String get umaPromptSend => _t('umaPromptSend');
  String get umaPromptRequest => _t('umaPromptRequest');
  String get umaPromptTopUp => _t('umaPromptTopUp');
  String get umaPromptPay => _t('umaPromptPay');
  String get umaPromptAnalyze => _t('umaPromptAnalyze');

  // ---- Transaction detail ----
  String get txnDetailWhen => _t('txnDetailWhen');
  String get txnDetailCategory => _t('txnDetailCategory');
  String get txnDetailDirection => _t('txnDetailDirection');
  String get txnDetailIncoming => _t('txnDetailIncoming');
  String get txnDetailOutgoing => _t('txnDetailOutgoing');
  String txnDetailAskPrompt(String name, String amount) =>
      _t('txnDetailAskPrompt')
          .replaceAll('{name}', name)
          .replaceAll('{amount}', amount);
  String billDetailPrompt(String name, String amount, int days) =>
      _t('billDetailPrompt')
          .replaceAll('{name}', name)
          .replaceAll('{amount}', amount)
          .replaceAll('{days}', '$days');

  // ---- Notification center ----
  String get notifTitle => _t('notifTitle');
  String notifSubtitle(int n) =>
      _t('notifSubtitle').replaceAll('{n}', '$n');
  String get notifEmpty => _t('notifEmpty');
  String get notifBlockedDefault => _t('notifBlockedDefault');
  String notifPriceIncreaseTitle(String name) =>
      _t('notifPriceIncreaseTitle').replaceAll('{name}', name);
  String notifPriceIncreaseBody(String delta, String price) =>
      _t('notifPriceIncreaseBody')
          .replaceAll('{delta}', delta)
          .replaceAll('{price}', price);
  String notifUnusedTitle(String name) =>
      _t('notifUnusedTitle').replaceAll('{name}', name);
  String notifUnusedBody(String last) =>
      _t('notifUnusedBody').replaceAll('{last}', last);
  String notifBillTitle(String name) =>
      _t('notifBillTitle').replaceAll('{name}', name);
  String notifBillBody(String amount) =>
      _t('notifBillBody').replaceAll('{amount}', amount);

  // ---- Proactive insight ----
  String get proactiveBadge => _t('proactiveBadge');
  String proactiveBillTitle(String name) =>
      _t('proactiveBillTitle').replaceAll('{name}', name);
  String proactiveBillBody(String amount, int days) =>
      _t('proactiveBillBody')
          .replaceAll('{amount}', amount)
          .replaceAll('{days}', '$days');
  String get proactiveBillCta => _t('proactiveBillCta');
  String proactiveBillPrompt(String name) =>
      _t('proactiveBillPrompt').replaceAll('{name}', name);
  String proactivePriceTitle(String name) =>
      _t('proactivePriceTitle').replaceAll('{name}', name);
  String proactivePriceBody(String delta) =>
      _t('proactivePriceBody').replaceAll('{delta}', delta);
  String get proactivePriceCta => _t('proactivePriceCta');
  String proactiveUnusedTitle(String name) =>
      _t('proactiveUnusedTitle').replaceAll('{name}', name);
  String proactiveUnusedBody(String last) =>
      _t('proactiveUnusedBody').replaceAll('{last}', last);
  String get proactiveUnusedCta => _t('proactiveUnusedCta');

  // ---- Data export ----
  String get exportTile => _t('exportTile');
  String get exportTileValue => _t('exportTileValue');
  String get exportTitle => _t('exportTitle');
  String get exportSubtitle => _t('exportSubtitle');
  String get exportCopy => _t('exportCopy');
  String get exportCopied => _t('exportCopied');

  // ---- Onboarding ----
  String get onbStep1Title => _t('onbStep1Title');
  String get onbStep1Subtitle => _t('onbStep1Subtitle');
  String get onbStep2Title => _t('onbStep2Title');
  String get onbStep2Subtitle => _t('onbStep2Subtitle');
  String get onbStep3Title => _t('onbStep3Title');
  String get onbStep3Subtitle => _t('onbStep3Subtitle');
  String get onbContinue => _t('onbContinue');
  String get onbStart => _t('onbStart');
  String get onbSkip => _t('onbSkip');
  String get onbBack => _t('onbBack');
  String get onbImportNow => _t('onbImportNow');
  String get onbScanNow => _t('onbScanNow');

  // ---- Demo replay ----
  String get demoResetTile => _t('demoResetTile');
  String get demoResetTileValue => _t('demoResetTileValue');
  String get demoResetTitle => _t('demoResetTitle');
  String get demoResetBody => _t('demoResetBody');
  String get demoResetConfirm => _t('demoResetConfirm');
  String get demoResetCancel => _t('demoResetCancel');
  String get demoResetDone => _t('demoResetDone');

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
    'firstSyncPending': 'İlk senkron bekleniyor',
    'updatedAt': 'Güncellendi {time}',
    'firstScanPending': 'İlk tarama bekleniyor',
    'lastScanAt': 'Son tarama {time}',
    'recentTransactions': 'Son işlemler',
    'itemsCount': '{n} işlem',
    'itemsVisible': 'görünür',
    'connectBank': 'Banka ekle',
    'addBankTitle': 'Banka ekle',
    'addBankSubtitle':
        'Vera bankaya bağlanmıyor — sen ekliyorsun, bakiyeyi takip ediyor.',
    'addBankName': 'Banka adı',
    'addBankLast4': 'Son 4 hane',
    'addBankBalance': 'Bakiye (TL)',
    'addBankColor': 'Renk',
    'addBankSave': 'Bankayı ekle',
    'addBankNameRequired': 'Banka adı gerekli.',
    'bankAdded': '{name} eklendi',
    'umaInsight': 'UMA İÇGÖRÜ',
    'spent': 'Harcanan',
    'incoming': 'Gelen',
    'creditHealthScore': 'Kredi sağlık skoru',
    'creditStatIncome': 'GELİR',
    'creditStatDti': 'BORÇ/GELİR',
    'creditStatTerm': 'VADE',
    'creditTermMo': '{n} ay',
    'creditTermMonths': '{n} ay',
    'creditRunSimulation': 'Kredi simülasyonunu çalıştır',
    'creditCurrentDecision': 'Geçerli karar',
    'creditPersonalLoan': 'Kişisel kredi · {amount}',
    'creditMonthsApr': '{n} ay · %{apr} APR',
    'creditUmaInsight': 'UMA İÇGÖRÜ',
    'creditEligibleProducts': 'Uygun ürünler',
    'creditLoanSimulation': 'Kredi simülasyonu',
    'creditLoanSimulationSubtitle':
        'İstediğin değerleri ayarla, Vera kararı anlık günceller.',
    'creditFieldLoanAmount': 'Kredi tutarı',
    'creditFieldTerm': 'Vade',
    'creditFieldIncome': 'Aylık gelir',
    'creditFieldDebt': 'Aylık borç',
    'subsRenewalLabel': 'Yenileme',
    'subsActivityLabel': 'Aktivite',
    'profileDailyBriefing': 'Günlük AI özeti',
    'profileDailyBriefingSub':
        'Hesap durumu, şüpheli aktivite ve tasarruf önerileriyle güne başla',
    'profileLiveSync': 'Canlı veri senkronu',
    'profileLiveSyncLive': 'Canlı',
    'profileLiveSyncBalanced': 'Dengeli',
    'profileLiveSyncSaver': 'Tasarruflu',
    'profileAutoApprove': 'Otomatik onay limiti',
    'profileAutoApproveOff': 'Kapalı',
    'profileSmartNotif': 'Akıllı bildirimler',
    'profileSmartNotifSub':
        'Fraud, yenileme ve onay değişiklikleri için uyarılar',
    'profileFaceId': 'Face ID kilidi',
    'profileFaceIdSub':
        'Hassas aksiyonlardan önce biyometrik kilit iste',
    'profileFraudHigh': 'Yüksek hassasiyetli fraud uyarıları',
    'profileFraudHighSub':
        "Vera'nın olağandışı cihaz ve ödeme örüntülerini daha erken yakalamasına izin ver",
    'profileVaultTitle': 'Korumalı oturum kasası',
    'profileVaultSubtitle':
        'Kimlik bilgisi yerel tercihlerden ayrı şekilde saklanır.',
    'profileVaultSignIn': 'Giriş',
    'profileVaultProtectedSince': 'Korunma başlangıcı',
    'profileVaultSyncMode': 'Senkron modu',
    'profileVaultApproval': 'Onay kuralı',
    'profileVaultThisDevice': 'Bu cihaz',
    'profileVaultManualOnly': 'Yalnızca manuel',
    'profileVaultSyncLive': 'Canlı senkron',
    'profileVaultSyncBalanced': 'Dengeli senkron',
    'profileVaultSyncSaver': 'Pil tasarruflu senkron',
    'profileAiToneBadge': 'AI TONU / {tone}',
    'profileConnectedTitle': '{n} bağlı kurum',
    'profileConnectedSubtitle':
        'Canlı bakiyeler mevcut senkron politikası ve feed cache üzerinden tazelenir.',
    'profileConnectedAccount': 'Hesap {last4}',
    'orderTitleBuyGold': '10g altın alımı',
    'orderTitlePayCard': 'Kredi kartı ekstresini öde',
    'orderTitleGoldRate': 'Fiyat',
    'orderTitleDue': 'Vade',
    'orderTitleDueToday': 'Bugün',
    'orderPillReady': 'HAZIR',
    'orderPillSent': 'BANKADA',
    'orderPillDismissed': 'İPTAL',
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
    'securityStatBlockedLabel': 'BLOKE',
    'securityStatBlockedSub': 'aktif',
    'securityStatReviewedLabel': 'İNCELENEN',
    'securityStatReviewedSub': 'bu hafta',
    'securityStatDevicesLabel': 'CİHAZ',
    'securityStatDevicesSub': 'güvenilir',
    'securityAccountSection': 'HESAP GÜVENLİĞİ',
    'securityClearBody': 'Son taramada çözülmemiş fraud uyarısı yok.',
    'securityActiveBody': 'Fraud Radar şu an {n} aktif uyarı izliyor.',
    'securityViewReport': 'UMA RAPORUNU GÖR',
    'securityDecisionKept':
        'Bu olayı bloke olarak işaretledin. Fraud Radar benzer örüntüleri yüksek risk olarak izlemeye devam edecek.',
    'securityDecisionApproved':
        'Bu olayı güvenli olarak işaretledin. Fraud Radar benzer false positive\'leri azaltmak için bunu kullanacak.',
    'securityPillBlocked': 'AI BLOKE ETTİ',
    'securityPillKept': 'BLOKE TUTULDU',
    'securityPillApproved': 'SEN ONAYLADIN',
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
    'scanNoTotal': 'Tutar okunamadı, fişi tekrar tara.',
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
    'statementNoTransactions': 'Ekstreden işlem çıkarılamadı.',
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
    'loginTitle': "Vera'ya giriş yap",
    'loginSubtitle':
        'Demo oturum kimliği cihaz kasasında korunur; profil tercihleri ve AI aksiyonları çıkış yapana kadar yerelde kalır.',
    'loginDisplayName': 'Görünen ad',
    'loginDisplayNameHint': 'Adın',
    'loginEmailHint': 'demo@vera.app',
    'loginFooter': 'Sonraki adım: gerçek auth, banka kimliği ve biyometrik kilit.',
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
    'infoDisplayName': 'Görünen ad',
    'infoMember': 'Üyelik',
    'infoMemberDescription':
        'Vera demo hesabı. Backend bağlandığında gerçek üyelik tarihi ve plan bilgisi burada görünür.',
    'infoEmailLabel': 'E-posta adresi',
    'infoEmailUsage': 'Nerede kullanılır',
    'infoEmailDescription':
        'Demo oturumu için kullanılıyor. Veriler cihazda kalır, sunucuya gönderilmez.',
    'infoSessionVault': 'Oturum kasası',
    'infoSessionVaultDescription':
        'Oturum verisi flutter_secure_storage ile cihazda şifreli saklanır. Yalnızca bu cihazda erişilebilir.',
    'infoFaceId': 'Face ID',
    'infoFaceIdOn':
        'Etkin · oturum açıldığında biyometrik doğrulama istenir.',
    'infoFaceIdOff': 'Kapalı · sadece şifre / demo girişi yeterli.',
    'infoFraudAlerts': 'Fraud uyarıları',
    'infoFraudAlertsOn':
        'Etkin · şüpheli işlem tespit edilince yerel bildirim gönderir.',
    'infoFraudAlertsOff':
        'Kapalı · uyarılar sadece uygulama içinde görünür.',
    'infoSyncMode': 'Senkron modu',
    'infoLocalData': 'Yerel veri',
    'infoLocalDataDescription':
        'OCR fişleri ve banka eklemeleri SharedPreferences\'ta tutuluyor. "Verileri dışa aktar" P1 backlog\'unda.',
    'helpFaqQ1': 'Vera bankama bağlanır mı?',
    'helpFaqA1':
        'Hayır. Vera AISP/PSP lisansı taşımıyor. Veriyi sen getiriyorsun: PDF ekstre, fiş fotoğrafı, ekran görüntüsü ya da manuel giriş. Vera AI ile birleştirip yorumluyor ve doğru bankaya yönlendiriyor.',
    'helpFaqQ2': 'Verim nerede saklanıyor?',
    'helpFaqA2':
        'Hassas oturum bilgisi flutter_secure_storage ile şifreli yerel kasada; OCR ve ekleme işlemleri SharedPreferences\'ta. Sunucu yok, üçüncü tarafa veri gitmiyor.',
    'helpFaqQ3': 'Gemini API key yoksa ne olur?',
    'helpFaqA3':
        'OCR ve ekstre import deterministic fallback ile çalışır (DEMO rozeti görünür). UMA chat heuristic intent router ile cevap verir. Tüm akış çalışır, sadece AI parsing canlı değildir.',
    'helpContact': 'İletişim',
    'demoUser': 'Demo kullanıcı',
    'umaGreeting':
        'Merhaba {name}. İçe aktardığın işlemleri okudum. Kart faturası ödeyebilir, transfer hazırlayabilir veya altın fiyatına bakabiliriz. Para hareketi hep senin bankanda olur; ben hazırlığı yapar, sonucu takip ederim.',
    'umaReplyBuyGold':
        '{bank} üzerinden 10 gram altın alım planını hazırladım. Uygulamayı açıp onayla; SMS\'ten sonucu takip ederim.',
    'umaReplyPayCard':
        '{bank} ekstresi ödemeye hazır. Uygulamayı doğrudan ödeme ekranında açacağım.',
    'umaReplyMoveSavings':
        'Acil durum fonu planın hazır. Bankanı aç ve transferi orada onayla. Bu transferden sonra hedefe %{pct} ulaşıyorsun.',
    'umaReplySubscriptions':
        'Bakmaya değer {n} planın var. Aylık abonelik toplamın {total} civarında.',
    'umaReplySubscriptionsEmpty':
        'Şu an aktif abonelik tespit etmedim. Bir ekstre yüklersen Vera tekrarlayan ödemeleri bulup listeye ekler.',
    'umaReplyAnalyze':
        'Bu ay en çok {top} kategorisinde {topAmount} harcadın. Toplam çıkış {spending}. İstersen kategori limitleri ayarlayabiliriz.',
    'umaReplyAnalyzeEmpty':
        'Henüz analiz edebileceğim işlem yok. Fiş tara veya bir ekstre yükle, sonra harcamayı parçalayalım.',
    'umaReplyExplainWealth':
        'Vera portföyünü içe aktardığın hesaplar üzerinden takip ediyor. Bu ay hisse kovan biraz yüksek görünüyor; bir sonraki bankayı açtığında altın veya nakide takviye önerim olacak.',
    'umaReplyLoan':
        'İçe aktardığın ekstrelerdeki gelir ve borç verisine göre orta tutarda kişisel kredi için güçlü görünüyorsun. Kredi simülasyonunu açarsan tutar ve vadeyi güvenli bir aralığa birlikte ayarlayabiliriz.',
    'umaReplySecurity':
        'O transferi işaretledim çünkü alıcı bir kez daha görünmüştü ve cihaz konumu olağan örüntünle eşleşmedi. Vera bankanı bloklamaz — uyarır, kararı sen verirsin.',
    'umaReplyFallback':
        'Bunu da yapabilirim. İstersen kısa bir finansal değerlendirme veya güvenli bir sonraki adım hazırlayayım.',
    'umaThinking': 'Uma düşünüyor...',
    'umaAskHint': "Uma'ya sor...",
    'umaStatusOnline': 'AI asistan · çevrimiçi',
    'umaSuggestionBuyGold': '10g altın al',
    'umaSuggestionMoveSavings': "2500 TL'yi birikime aktar",
    'umaActionPolicy': 'EYLEM POLİTİKASI',
    'umaActionPolicyDesc': 'Vera para hareketini bankanda yapar; sen her zaman onay verirsin.',
    'categoryBudgetLabel': 'BU AYKİ HARCAMALAR',
    'categoryOther': 'Diğer',
    'categoryBudgetTopHint': 'En çok {category} · %{pct}',
    'categoryRemaining': 'kalan {amount}',
    'categoryOver': 'limit aşıldı · {amount}',
    'categoryNoLimit': 'limit yok',
    'categoryLimitEditTitle': 'Kategori limiti',
    'categoryLimitEditSubtitle':
        '{category} için aylık limiti belirle. Vera her harcamada kalan tutarı gösterir.',
    'categoryLimitField': 'Aylık limit (TL)',
    'categoryLimitSave': 'Kaydet',
    'categoryLimitClear': 'Limiti kaldır',
    'goalsSectionTitle': 'Hedeflerin',
    'goalEmergencyFund': 'Acil durum fonu',
    'goalProgress': '%{pct} yolda',
    'goalRemaining': '{amount} kaldı',
    'goalEditTitle': 'Hedefini düzenle',
    'goalEditTarget': 'Hedef tutar (TL)',
    'goalEditSaved': 'Biriken tutar (TL)',
    'goalEditSave': 'Kaydet',
    'goalEditFooter': 'Vera hedef paranı izler; Uma her ay yeni öneri yapar.',
    'goalEtaMonths': '{n} ayda tamam',
    'goalEtaReached': 'Hedefe ulaştın 🎯',
    'bankActionsTitle': 'Banka seçenekleri',
    'bankActionsDelete': 'Bankayı sil',
    'bankActionsCancel': 'Vazgeç',
    'bankActionsConfirmTitle': 'Silinsin mi?',
    'bankActionsConfirmBody':
        '{name} listeden silinecek. Bakiye toplamından çıkarılır.',
    'bankDeleted': '{name} silindi',
    'bankActionsFeedNote':
        'Bu banka demo verisinde geliyor — silinemez. Kendi eklediklerini silebilirsin.',
    'umaPromptSend': 'Bir arkadaşa para göndermek istiyorum.',
    'umaPromptRequest': 'Bir arkadaştan para iste.',
    'umaPromptTopUp': 'Hesabıma yükleme yapmak istiyorum.',
    'umaPromptPay': 'Kredi kartı faturamı ödemek istiyorum.',
    'umaPromptAnalyze': 'Bu ay harcamalarımı analiz et.',
    'txnDetailWhen': 'Zaman',
    'txnDetailCategory': 'Kategori',
    'txnDetailDirection': 'Yön',
    'txnDetailIncoming': 'Gelen',
    'txnDetailOutgoing': 'Giden',
    'txnDetailAskPrompt': '{name} işlemini değerlendir, {amount} normal mi?',
    'billDetailPrompt': '{name} faturası {amount}, {days} gün kaldı. Ne yapayım?',
    'notifTitle': 'Bildirimler',
    'notifSubtitle': '{n} sinyal Uma tarafından izleniyor',
    'notifEmpty': 'Her şey yolunda. Uma sessizce izlemeye devam ediyor.',
    'notifBlockedDefault': 'Vera bu işlemi anomali olarak işaretledi.',
    'notifPriceIncreaseTitle': '{name} zamlandı',
    'notifPriceIncreaseBody': 'Aylık +{delta} · şimdi {price}. Plans ekranında dondurabilirsin.',
    'notifUnusedTitle': '{name} kullanılmıyor',
    'notifUnusedBody': 'Son kullanım: {last}. Vera bunu sessiz para sızıntısı olarak işaretledi.',
    'notifBillTitle': '{name} faturası yaklaşıyor',
    'notifBillBody': 'Ödenecek tutar {amount}. Uma ile öde veya bankan üzerinden tamamla.',
    'proactiveBadge': 'VERA FARK ETTİ',
    'proactiveBillTitle': '{name} faturası yaklaşıyor',
    'proactiveBillBody': '{amount} · {days} gün kaldı. Uma ödeme planını hazırlasın mı?',
    'proactiveBillCta': 'Uma ile öde',
    'proactiveBillPrompt': '{name} faturamı ödemek için yardım et.',
    'proactivePriceTitle': '{name} bu ay zamlandı',
    'proactivePriceBody': 'Aylık +{delta} artış. Aboneliği dondurmak ister misin?',
    'proactivePriceCta': 'Aboneliklere git',
    'proactiveUnusedTitle': '{name} kullanılmıyor',
    'proactiveUnusedBody': 'Son kullanım: {last}. Sessiz para sızıntısı olabilir.',
    'proactiveUnusedCta': 'Aboneliklere git',
    'exportTile': 'Verilerimi dışa aktar',
    'exportTileValue': 'JSON · cihaza özel',
    'exportTitle': 'Vera verilerin',
    'exportSubtitle': 'İçe aktarılan işlemler, eklediğin bankalar, hedefin ve abonelik listen. Cihazından dışarı bilgi göndermeden kopyalanabilir.',
    'exportCopy': 'JSON kopyala',
    'exportCopied': 'Pano\'ya kopyalandı',
    'onbStep1Title': "Vera'ya hoş geldin",
    'onbStep1Subtitle': 'Önce kullanmak istediğin dili seç. Dil her zaman ayarlardan değiştirilebilir.',
    'onbStep2Title': 'Görünüşünü ayarla',
    'onbStep2Subtitle': 'Markanın paletini ve modunu seç. Tema daha sonra da değiştirilebilir.',
    'onbStep3Title': 'Verini getir',
    'onbStep3Subtitle': 'Vera bankana bağlanmaz — sen ekstreni getirirsin, Vera anlamlandırır. Şimdi başla veya sonra ekle.',
    'onbContinue': 'Devam et',
    'onbStart': 'Veraya başla',
    'onbSkip': 'Atla',
    'onbBack': 'Geri',
    'onbImportNow': 'Ekstre yükle',
    'onbScanNow': 'Fiş tara',
    'demoResetTile': 'Demo verisini sıfırla',
    'demoResetTileValue': 'İçe aktarılanları ve eklemeleri temizle',
    'demoResetTitle': 'Demo verisini sıfırla?',
    'demoResetBody':
        'İçe aktarılan işlemler, eklediğin bankalar ve hedef ilerlemen başlangıç durumuna döner.',
    'demoResetConfirm': 'Sıfırla',
    'demoResetCancel': 'Vazgeç',
    'demoResetDone': 'Demo durumuna döndü',
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
    'firstSyncPending': 'Awaiting first sync',
    'updatedAt': 'Updated {time}',
    'firstScanPending': 'Awaiting first scan',
    'lastScanAt': 'Last scan {time}',
    'recentTransactions': 'Recent transactions',
    'itemsCount': '{n} items',
    'itemsVisible': 'visible',
    'connectBank': 'Connect bank',
    'addBankTitle': 'Add a bank',
    'addBankSubtitle':
        "Vera doesn't connect to banks — you add them and track the balance.",
    'addBankName': 'Bank name',
    'addBankLast4': 'Last 4 digits',
    'addBankBalance': 'Balance (TL)',
    'addBankColor': 'Color',
    'addBankSave': 'Add bank',
    'addBankNameRequired': 'Bank name is required.',
    'bankAdded': '{name} added',
    'umaInsight': 'UMA INSIGHT',
    'spent': 'Spent',
    'incoming': 'In',
    'creditHealthScore': 'Credit Health Score',
    'creditStatIncome': 'INCOME',
    'creditStatDti': 'DTI',
    'creditStatTerm': 'TERM',
    'creditTermMo': '{n} mo',
    'creditTermMonths': '{n} months',
    'creditRunSimulation': 'Run loan simulation',
    'creditCurrentDecision': 'Current decision',
    'creditPersonalLoan': 'Personal loan · {amount}',
    'creditMonthsApr': '{n} months · {apr}% APR',
    'creditUmaInsight': 'UMA INSIGHT',
    'creditEligibleProducts': 'Eligible products',
    'creditLoanSimulation': 'Loan simulation',
    'creditLoanSimulationSubtitle':
        'Tune the request and Vera will refresh the decision in real time.',
    'creditFieldLoanAmount': 'Loan amount',
    'creditFieldTerm': 'Term',
    'creditFieldIncome': 'Monthly income',
    'creditFieldDebt': 'Monthly debt',
    'subsRenewalLabel': 'Renewal',
    'subsActivityLabel': 'Activity',
    'profileDailyBriefing': 'Daily AI briefing',
    'profileDailyBriefingSub':
        'Start the day with account health, suspicious activity, and savings prompts',
    'profileLiveSync': 'Live data sync',
    'profileLiveSyncLive': 'Live',
    'profileLiveSyncBalanced': 'Balanced',
    'profileLiveSyncSaver': 'Saver',
    'profileAutoApprove': 'Auto-approve limit',
    'profileAutoApproveOff': 'Off',
    'profileSmartNotif': 'Smart notifications',
    'profileSmartNotifSub':
        'Alerts for fraud, renewals, and approval changes',
    'profileFaceId': 'Face ID relock',
    'profileFaceIdSub':
        'Require biometric unlock before sensitive actions',
    'profileFraudHigh': 'High-sensitivity fraud alerts',
    'profileFraudHighSub':
        'Let Vera flag unusual device and payment patterns earlier',
    'profileVaultTitle': 'Protected session vault',
    'profileVaultSubtitle':
        'Identity is persisted separately from local preferences.',
    'profileVaultSignIn': 'Sign-in',
    'profileVaultProtectedSince': 'Protected since',
    'profileVaultSyncMode': 'Sync mode',
    'profileVaultApproval': 'Approval guardrail',
    'profileVaultThisDevice': 'This device',
    'profileVaultManualOnly': 'Manual only',
    'profileVaultSyncLive': 'Live sync',
    'profileVaultSyncBalanced': 'Balanced sync',
    'profileVaultSyncSaver': 'Battery saver sync',
    'profileAiToneBadge': 'AI TONE / {tone}',
    'profileConnectedTitle': '{n} connected institutions',
    'profileConnectedSubtitle':
        'Live balances refresh through the current sync policy and feed cache.',
    'profileConnectedAccount': 'Account {last4}',
    'orderTitleBuyGold': 'Buy 10g of Gold',
    'orderTitlePayCard': 'Pay credit card statement',
    'orderTitleGoldRate': 'Rate',
    'orderTitleDue': 'Due',
    'orderTitleDueToday': 'Today',
    'orderPillReady': 'READY',
    'orderPillSent': 'AT BANK',
    'orderPillDismissed': 'DISMISSED',
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
    'securityStatBlockedLabel': 'BLOCKED',
    'securityStatBlockedSub': 'active',
    'securityStatReviewedLabel': 'REVIEWED',
    'securityStatReviewedSub': 'this week',
    'securityStatDevicesLabel': 'DEVICES',
    'securityStatDevicesSub': 'trusted',
    'securityAccountSection': 'ACCOUNT SECURITY',
    'securityClearBody': 'No unresolved fraud alerts in the latest scan.',
    'securityActiveBody': 'Fraud Radar is tracking {n} active alerts.',
    'securityViewReport': 'VIEW UMA REPORT',
    'securityDecisionKept':
        'You kept this event blocked. Fraud Radar will continue treating similar patterns as high risk.',
    'securityDecisionApproved':
        "You marked this event as safe. Fraud Radar will use that feedback to reduce similar false positives.",
    'securityPillBlocked': 'BLOCKED BY AI',
    'securityPillKept': 'KEPT BLOCKED',
    'securityPillApproved': 'APPROVED BY YOU',
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
    'scanNoTotal': "Couldn't read the amount, scan again.",
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
    'statementNoTransactions': 'No transactions could be extracted.',
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
    'loginTitle': 'Sign in to Vera',
    'loginSubtitle':
        'Demo session identity is protected in the device vault, while profile preferences and AI actions stay local until you sign out.',
    'loginDisplayName': 'Display name',
    'loginDisplayNameHint': 'Your name',
    'loginEmailHint': 'demo@vera.app',
    'loginFooter':
        'Next step: real auth, connected bank identity, and biometric relock.',
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
    'infoDisplayName': 'Display name',
    'infoMember': 'Membership',
    'infoMemberDescription':
        'Vera demo account. Once a backend is wired in, real membership date and plan show up here.',
    'infoEmailLabel': 'Email address',
    'infoEmailUsage': 'Where it is used',
    'infoEmailDescription':
        'Used for the demo session. Data stays on device; nothing is sent to a server.',
    'infoSessionVault': 'Session vault',
    'infoSessionVaultDescription':
        'Session data is encrypted via flutter_secure_storage and stored locally on this device only.',
    'infoFaceId': 'Face ID',
    'infoFaceIdOn':
        'On — biometric verification is requested when you sign in.',
    'infoFaceIdOff':
        'Off — password / demo sign-in is enough.',
    'infoFraudAlerts': 'Fraud alerts',
    'infoFraudAlertsOn':
        'On — sends a local notification when a suspicious event is detected.',
    'infoFraudAlertsOff':
        'Off — alerts only show inside the app.',
    'infoSyncMode': 'Sync mode',
    'infoLocalData': 'Local data',
    'infoLocalDataDescription':
        'OCR receipts and added banks live in SharedPreferences. "Export your data" is in the P1 backlog.',
    'helpFaqQ1': 'Does Vera connect to my bank?',
    'helpFaqA1':
        'No. Vera does not hold an AISP/PSP license. You bring the data: PDF statements, receipt photos, screenshots, or manual entries. Vera combines and interprets it with AI and forwards real actions to your bank app.',
    'helpFaqQ2': 'Where is my data stored?',
    'helpFaqA2':
        'Sensitive session info goes to flutter_secure_storage (encrypted, on-device). OCR and add-bank entries go to SharedPreferences. No server, no third-party data sharing.',
    'helpFaqQ3': 'What if I do not have a Gemini API key?',
    'helpFaqA3':
        'OCR and statement import run a deterministic fallback (DEMO badge appears). UMA chat replies via a heuristic intent router. The whole flow still works — only the live AI parsing is off.',
    'helpContact': 'Contact',
    'demoUser': 'Demo user',
    'umaGreeting':
        "Hi {name}. I read your imported statements. I can help you pay a card bill, plan a transfer, or look at gold pricing. The action happens in your bank app; I prepare it and track the result.",
    'umaReplyBuyGold':
        'I prepared a 10g gold purchase plan via {bank}. Open the app and confirm — I will track it from the SMS.',
    'umaReplyPayCard':
        'Your {bank} statement is ready to pay. I will open the app directly on the payment screen.',
    'umaReplyMoveSavings':
        'Your emergency fund plan is ready. Open your bank and confirm the transfer there. After this transfer you will be {pct}% of the way to the goal.',
    'umaReplySubscriptions':
        'You have {n} plans worth reviewing. Your monthly subscription total is around {total}.',
    'umaReplySubscriptionsEmpty':
        'I do not see any active subscriptions yet. Import a statement and Vera will detect recurring charges.',
    'umaReplyAnalyze':
        'Your top spending this month is {top} at {topAmount}. Total outflow {spending}. We can set per-category limits if you want.',
    'umaReplyAnalyzeEmpty':
        'No transactions to analyze yet. Scan a receipt or import a statement and we will break the spending down together.',
    'umaReplyExplainWealth':
        'Vera tracks your portfolio across the accounts you imported. Equities look slightly over-allocated this month; my suggestion is to top up gold or cash next time you open your bank.',
    'umaReplyLoan':
        'Based on the income and debt I see in your imported statements, you look strong for mid-sized personal loans. Open the credit simulation and I can help tune the amount and term for a safer fit.',
    'umaReplySecurity':
        'I flagged that transfer because the recipient appeared once before and the device location did not match your usual pattern. Vera does not block at your bank — it warns you and you decide together.',
    'umaReplyFallback':
        'I can help with that. If you want, I can give you a quick financial read or prepare a safe next step.',
    'umaThinking': 'Uma is thinking...',
    'umaAskHint': 'Ask Uma anything...',
    'umaStatusOnline': 'AI assistant · online',
    'umaSuggestionBuyGold': 'Buy 10g of gold',
    'umaSuggestionMoveSavings': 'Move 2500 TL to savings',
    'umaActionPolicy': 'ACTION POLICY',
    'umaActionPolicyDesc': 'Vera never moves money itself; every action opens your bank app for your approval.',
    'categoryBudgetLabel': 'SPENDING THIS MONTH',
    'categoryOther': 'Other',
    'categoryBudgetTopHint': 'Most on {category} · {pct}%',
    'categoryRemaining': '{amount} left',
    'categoryOver': 'over by {amount}',
    'categoryNoLimit': 'no limit',
    'categoryLimitEditTitle': 'Category limit',
    'categoryLimitEditSubtitle':
        'Set a monthly budget for {category}. Vera shows the remainder on every spend.',
    'categoryLimitField': 'Monthly limit (TL)',
    'categoryLimitSave': 'Save',
    'categoryLimitClear': 'Remove limit',
    'goalsSectionTitle': 'Your goals',
    'goalEmergencyFund': 'Emergency fund',
    'goalProgress': '{pct}% there',
    'goalRemaining': '{amount} to go',
    'goalEditTitle': 'Edit your goal',
    'goalEditTarget': 'Target amount (TL)',
    'goalEditSaved': 'Saved so far (TL)',
    'goalEditSave': 'Save',
    'goalEditFooter':
        "Vera tracks the balance; Uma checks in every month with a new nudge.",
    'goalEtaMonths': '{n} months to finish',
    'goalEtaReached': 'You reached it 🎯',
    'bankActionsTitle': 'Bank options',
    'bankActionsDelete': 'Delete bank',
    'bankActionsCancel': 'Cancel',
    'bankActionsConfirmTitle': 'Delete this bank?',
    'bankActionsConfirmBody':
        '{name} will be removed and stop counting toward your total balance.',
    'bankDeleted': '{name} deleted',
    'bankActionsFeedNote':
        'This bank ships with the demo data and cannot be deleted. You can remove the ones you added.',
    'umaPromptSend': 'I want to send money to a friend.',
    'umaPromptRequest': 'Help me request money from a friend.',
    'umaPromptTopUp': 'I want to top up my account.',
    'umaPromptPay': 'I want to pay my credit card bill.',
    'umaPromptAnalyze': 'Analyze my spending this month.',
    'umaFeedbackLabel': 'WAS THIS HELPFUL?',
    'umaFeedbackHelpful': 'Helpful',
    'umaFeedbackNotHelpful': 'Needs work',
    'umaFeedbackAddNote': 'Add note',
    'umaFeedbackEditNote': 'Edit note',
    'umaFeedbackHelpfulTitle': 'What made this answer useful?',
    'umaFeedbackNotHelpfulTitle': 'What should Uma improve here?',
    'umaFeedbackNoteHint':
        'Leave an optional note. Uma will use it to improve future free-form replies.',
    'umaFeedbackPlaceholder':
        'Example: be shorter, give clearer next steps, explain the risk more directly...',
    'umaFeedbackSave': 'Save note',
    'umaFeedbackSkipNote': 'Skip note',
    'umaFeedbackSaved': 'Your feedback was saved for Uma.',
    'umaFeedbackSavedWithNote': 'Your feedback and note were saved for Uma.',
    'txnDetailWhen': 'When',
    'txnDetailCategory': 'Category',
    'txnDetailDirection': 'Direction',
    'txnDetailIncoming': 'Incoming',
    'txnDetailOutgoing': 'Outgoing',
    'txnDetailAskPrompt': 'Look at the {name} transaction — is {amount} normal?',
    'billDetailPrompt': 'My {name} bill is {amount}, {days} days left. What should I do?',
    'notifTitle': 'Notifications',
    'notifSubtitle': '{n} signals Uma is watching',
    'notifEmpty': 'You\'re all clear. Uma keeps watching quietly.',
    'notifBlockedDefault': 'Vera flagged this transaction as an anomaly.',
    'notifPriceIncreaseTitle': '{name} just raised the price',
    'notifPriceIncreaseBody': 'Monthly +{delta} · now {price}. You can freeze it from Plans.',
    'notifUnusedTitle': '{name} is going unused',
    'notifUnusedBody': 'Last seen: {last}. Vera flagged this as a silent leak.',
    'notifBillTitle': '{name} bill is approaching',
    'notifBillBody': 'Amount {amount}. Pay through Uma or your bank.',
    'proactiveBadge': 'VERA SPOTTED',
    'proactiveBillTitle': '{name} bill is approaching',
    'proactiveBillBody': '{amount} · {days} days left. Want Uma to prepare the payment plan?',
    'proactiveBillCta': 'Pay with Uma',
    'proactiveBillPrompt': 'Help me pay my {name} bill.',
    'proactivePriceTitle': '{name} got more expensive',
    'proactivePriceBody': '+{delta} monthly increase. Want to freeze the subscription?',
    'proactivePriceCta': 'Open subscriptions',
    'proactiveUnusedTitle': '{name} is unused',
    'proactiveUnusedBody': 'Last seen: {last}. Could be a silent money leak.',
    'proactiveUnusedCta': 'Open subscriptions',
    'exportTile': 'Export my data',
    'exportTileValue': 'JSON · device-only',
    'exportTitle': 'Your Vera data',
    'exportSubtitle': 'Imported transactions, banks you added, your goal and the detected subscriptions. Copy without leaving the device.',
    'exportCopy': 'Copy JSON',
    'exportCopied': 'Copied to clipboard',
    'onbStep1Title': 'Welcome to Vera',
    'onbStep1Subtitle': 'Pick your language. You can change it anytime in settings.',
    'onbStep2Title': 'Make it yours',
    'onbStep2Subtitle': 'Choose the brand palette and mood. Theme is editable later.',
    'onbStep3Title': 'Bring your data',
    'onbStep3Subtitle': "Vera doesn't connect to your bank — you bring statements, Vera makes sense of them. Start now or add later.",
    'onbContinue': 'Continue',
    'onbStart': 'Start Vera',
    'onbSkip': 'Skip',
    'onbBack': 'Back',
    'onbImportNow': 'Import a statement',
    'onbScanNow': 'Scan a receipt',
    'demoResetTile': 'Reset demo data',
    'demoResetTileValue': 'Clear imports and additions',
    'demoResetTitle': 'Reset demo data?',
    'demoResetBody':
        'Imported transactions, banks you added, and goal progress return to the starting state.',
    'demoResetConfirm': 'Reset',
    'demoResetCancel': 'Cancel',
    'demoResetDone': 'Back to demo state',
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
    'addBankTitle': 'Bank hinzufügen',
    'addBankSubtitle':
        'Vera verbindet sich nicht — du fügst hinzu, der Saldo wird mitgeführt.',
    'addBankName': 'Bankname',
    'addBankLast4': 'Letzte 4 Ziffern',
    'addBankBalance': 'Saldo (TL)',
    'addBankColor': 'Farbe',
    'addBankSave': 'Bank hinzufügen',
    'addBankNameRequired': 'Bankname erforderlich.',
    'bankAdded': '{name} hinzugefügt',
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
    'scanNoTotal': 'Betrag nicht erkannt, bitte erneut scannen.',
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
    'statementNoTransactions': 'Keine Buchungen erkannt.',
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
    'infoDisplayName': 'Anzeigename',
    'infoMember': 'Mitgliedschaft',
    'infoMemberDescription':
        'Vera-Demo-Konto. Sobald ein Backend angeschlossen ist, erscheinen hier echtes Beitrittsdatum und Plan.',
    'infoEmailLabel': 'E-Mail-Adresse',
    'infoEmailUsage': 'Wofür sie verwendet wird',
    'infoEmailDescription':
        'Für die Demo-Sitzung verwendet. Daten bleiben auf dem Gerät, nichts geht an einen Server.',
    'infoSessionVault': 'Session-Vault',
    'infoSessionVaultDescription':
        'Sitzungsdaten werden via flutter_secure_storage verschlüsselt und nur lokal auf diesem Gerät gespeichert.',
    'infoFaceId': 'Face ID',
    'infoFaceIdOn':
        'An — beim Anmelden wird biometrische Bestätigung verlangt.',
    'infoFaceIdOff':
        'Aus — Passwort / Demo-Login genügt.',
    'infoFraudAlerts': 'Fraud-Warnungen',
    'infoFraudAlertsOn':
        'An — sendet eine lokale Benachrichtigung bei verdächtigen Ereignissen.',
    'infoFraudAlertsOff':
        'Aus — Warnungen erscheinen nur in der App.',
    'infoSyncMode': 'Sync-Modus',
    'infoLocalData': 'Lokale Daten',
    'infoLocalDataDescription':
        'OCR-Belege und hinzugefügte Banken liegen in SharedPreferences. "Daten exportieren" ist im P1-Backlog.',
    'helpFaqQ1': 'Verbindet Vera sich mit meiner Bank?',
    'helpFaqA1':
        'Nein. Vera hat keine AISP/PSP-Lizenz. Du bringst die Daten: PDF-Auszüge, Belegfotos, Screenshots oder manuelle Einträge. Vera fügt sie mit KI zusammen und leitet reale Aktionen an deine Bank-App weiter.',
    'helpFaqQ2': 'Wo werden meine Daten gespeichert?',
    'helpFaqA2':
        'Sensible Sitzungsdaten im flutter_secure_storage (verschlüsselt, auf dem Gerät). OCR und Bankeinträge in SharedPreferences. Kein Server, keine Datenweitergabe an Dritte.',
    'helpFaqQ3': 'Was passiert ohne Gemini API-Key?',
    'helpFaqA3':
        'OCR und Statement-Import laufen mit deterministischem Fallback (DEMO-Badge erscheint). UMA-Chat antwortet über einen heuristischen Intent-Router. Der gesamte Flow funktioniert — nur das Live-AI-Parsing ist aus.',
    'helpContact': 'Kontakt',
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
    'addBankTitle': 'إضافة بنك',
    'addBankSubtitle': 'Vera لا تتصل بالبنوك — تضيفها وتتابع الرصيد.',
    'addBankName': 'اسم البنك',
    'addBankLast4': 'آخر 4 أرقام',
    'addBankBalance': 'الرصيد (TL)',
    'addBankColor': 'اللون',
    'addBankSave': 'إضافة بنك',
    'addBankNameRequired': 'اسم البنك مطلوب.',
    'bankAdded': 'تمت إضافة {name}',
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
    'scanNoTotal': 'تعذرت قراءة المبلغ، أعد المسح.',
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
    'statementNoTransactions': 'لم يتم استخراج أي معاملات.',
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
    'infoDisplayName': 'الاسم المعروض',
    'infoMember': 'العضوية',
    'infoMemberDescription':
        'حساب تجريبي في Vera. عند ربط الواجهة الخلفية ستظهر هنا بيانات العضوية الحقيقية والخطة.',
    'infoEmailLabel': 'البريد الإلكتروني',
    'infoEmailUsage': 'مكان الاستخدام',
    'infoEmailDescription':
        'يُستخدم في الجلسة التجريبية. البيانات تبقى على الجهاز ولا تُرسل لأي خادم.',
    'infoSessionVault': 'خزينة الجلسة',
    'infoSessionVaultDescription':
        'بيانات الجلسة مشفّرة عبر flutter_secure_storage وتُحفظ محلياً على هذا الجهاز فقط.',
    'infoFaceId': 'Face ID',
    'infoFaceIdOn':
        'مفعل · يُطلب التحقق البيومتري عند تسجيل الدخول.',
    'infoFaceIdOff': 'مغلق · يكفي كلمة المرور / الدخول التجريبي.',
    'infoFraudAlerts': 'تنبيهات الاحتيال',
    'infoFraudAlertsOn':
        'مفعل · يرسل إشعاراً محلياً عند رصد عملية مشبوهة.',
    'infoFraudAlertsOff': 'مغلق · التنبيهات تظهر داخل التطبيق فقط.',
    'infoSyncMode': 'وضع المزامنة',
    'infoLocalData': 'البيانات المحلية',
    'infoLocalDataDescription':
        'فواتير OCR والبنوك المُضافة تُحفظ في SharedPreferences. "تصدير البيانات" ضمن خطط P1.',
    'helpFaqQ1': 'هل تتصل Vera بمصرفي؟',
    'helpFaqA1':
        'لا. Vera لا تحمل ترخيص AISP/PSP. أنت تجلب البيانات: كشوف PDF، صور إيصالات، لقطات شاشة، أو إدخال يدوي. Vera تجمعها بالذكاء الاصطناعي وتمرر الإجراءات إلى تطبيق مصرفك.',
    'helpFaqQ2': 'أين تُحفظ بياناتي؟',
    'helpFaqA2':
        'بيانات الجلسة الحساسة في flutter_secure_storage (مشفّرة، على الجهاز). إدخالات OCR والبنوك في SharedPreferences. لا خادم ولا مشاركة مع أطراف ثالثة.',
    'helpFaqQ3': 'ماذا يحدث بدون مفتاح Gemini API؟',
    'helpFaqA3':
        'OCR واستيراد الكشوف يعملان عبر بدائل ثابتة (شارة DEMO تظهر). UMA يرد عبر موجه نوايا استدلالي. كل التدفق يعمل — فقط التحليل المباشر بالذكاء الاصطناعي معطل.',
    'helpContact': 'تواصل',
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
    'addBankTitle': 'Добавить банк',
    'addBankSubtitle':
        'Vera не подключается к банкам — вы добавляете и отслеживаете баланс.',
    'addBankName': 'Название банка',
    'addBankLast4': 'Последние 4 цифры',
    'addBankBalance': 'Баланс (TL)',
    'addBankColor': 'Цвет',
    'addBankSave': 'Добавить банк',
    'addBankNameRequired': 'Название банка обязательно.',
    'bankAdded': '{name} добавлен',
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
    'scanNoTotal': 'Сумма не распознана, отсканируйте снова.',
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
    'statementNoTransactions': 'Не удалось извлечь операции.',
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
    'infoDisplayName': 'Отображаемое имя',
    'infoMember': 'Членство',
    'infoMemberDescription':
        'Демо-аккаунт Vera. После подключения бэкенда здесь появятся дата регистрации и план.',
    'infoEmailLabel': 'Адрес электронной почты',
    'infoEmailUsage': 'Где используется',
    'infoEmailDescription':
        'Используется для демо-сессии. Данные остаются на устройстве, на сервер ничего не отправляется.',
    'infoSessionVault': 'Хранилище сессии',
    'infoSessionVaultDescription':
        'Данные сессии шифруются через flutter_secure_storage и хранятся только на этом устройстве.',
    'infoFaceId': 'Face ID',
    'infoFaceIdOn':
        'Вкл. — при входе требуется биометрическая проверка.',
    'infoFaceIdOff':
        'Выкл. — достаточно пароля / демо-входа.',
    'infoFraudAlerts': 'Оповещения о мошенничестве',
    'infoFraudAlertsOn':
        'Вкл. — при подозрительной операции отправляется локальное уведомление.',
    'infoFraudAlertsOff':
        'Выкл. — оповещения показываются только в приложении.',
    'infoSyncMode': 'Режим синхронизации',
    'infoLocalData': 'Локальные данные',
    'infoLocalDataDescription':
        'OCR-чеки и добавленные банки хранятся в SharedPreferences. "Экспорт данных" — в P1-бэклоге.',
    'helpFaqQ1': 'Vera подключается к моему банку?',
    'helpFaqA1':
        'Нет. У Vera нет лицензии AISP/PSP. Данные приносите вы: PDF-выписки, фото чеков, скриншоты или ручной ввод. Vera объединяет их с помощью ИИ и направляет действия в ваше банковское приложение.',
    'helpFaqQ2': 'Где хранятся мои данные?',
    'helpFaqA2':
        'Чувствительные данные сессии — flutter_secure_storage (шифрование, на устройстве). OCR и записи о банках — SharedPreferences. Сервера нет, третьим лицам данные не передаются.',
    'helpFaqQ3': 'Что если нет ключа Gemini API?',
    'helpFaqA3':
        'OCR и импорт выписок работают через детерминированный fallback (появляется бейдж DEMO). UMA отвечает через эвристический intent-роутер. Весь поток работает — отключён только live-парсинг ИИ.',
    'helpContact': 'Контакт',
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
    'addBankTitle': '添加银行',
    'addBankSubtitle': 'Vera 不连接银行——你来添加并跟踪余额。',
    'addBankName': '银行名称',
    'addBankLast4': '最后4位',
    'addBankBalance': '余额 (TL)',
    'addBankColor': '颜色',
    'addBankSave': '添加银行',
    'addBankNameRequired': '请填写银行名称。',
    'bankAdded': '已添加 {name}',
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
    'scanNoTotal': '无法读取金额，请重新扫描。',
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
    'statementNoTransactions': '未能提取交易。',
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
    'infoDisplayName': '显示名称',
    'infoMember': '会员',
    'infoMemberDescription': 'Vera 演示账号。后端接入后，这里将显示真实的注册日期和套餐。',
    'infoEmailLabel': '电子邮箱',
    'infoEmailUsage': '用途',
    'infoEmailDescription': '用于演示会话。数据保存在本地设备，不会上传到服务器。',
    'infoSessionVault': '会话保险箱',
    'infoSessionVaultDescription': '会话数据通过 flutter_secure_storage 加密，仅在本机存储。',
    'infoFaceId': 'Face ID',
    'infoFaceIdOn': '启用 · 登录时需要生物识别验证。',
    'infoFaceIdOff': '关闭 · 仅需密码 / 演示登录。',
    'infoFraudAlerts': '欺诈提醒',
    'infoFraudAlertsOn': '启用 · 检测到可疑活动时发送本地通知。',
    'infoFraudAlertsOff': '关闭 · 提醒仅在应用内显示。',
    'infoSyncMode': '同步模式',
    'infoLocalData': '本地数据',
    'infoLocalDataDescription':
        'OCR 收据和已添加的银行保存在 SharedPreferences。"导出数据"已列入 P1 计划。',
    'helpFaqQ1': 'Vera 会连接我的银行吗？',
    'helpFaqA1':
        '不会。Vera 没有 AISP/PSP 许可证。数据由你提供：PDF 账单、收据照片、截图或手动输入。Vera 用 AI 进行整合并把真实操作转发到你的银行 App。',
    'helpFaqQ2': '我的数据保存在哪里？',
    'helpFaqA2':
        '敏感会话信息存储于 flutter_secure_storage（设备端加密）。OCR 和银行记录存储于 SharedPreferences。无服务器，无第三方共享。',
    'helpFaqQ3': '没有 Gemini API key 会怎样？',
    'helpFaqA3':
        'OCR 和账单导入使用确定性回退（出现 DEMO 标签）。UMA 通过启发式意图路由器回复。整套流程仍可运行——仅关闭实时 AI 解析。',
    'helpContact': '联系',
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
