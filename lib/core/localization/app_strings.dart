import 'package:flutter/material.dart';

import 'app_locale.dart';

/// Holds every visible UI string. New strings: add a getter here, fill 6
/// values in [_strings], then read via `context.l10n.someKey`.
part 'features/tr.dart';
part 'features/en.dart';
part 'features/de.dart';
part 'features/ar.dart';
part 'features/ru.dart';
part 'features/zh.dart';

class AppStrings {
  AppStrings(this.locale);

  final AppLocale locale;

  String get localeCode => locale.code;

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
  String get emailField => _t('emailField');
  String get passwordField => _t('passwordField');
  String get loginTitle => _t('loginTitle');
  String get loginSubtitle => _t('loginSubtitle');
  String get loginEmailHint => _t('loginEmailHint');
  String get loginFooter => _t('loginFooter');
  String loginDemoHint(String email, String password) =>
      _t('loginDemoHint')
          .replaceAll('{email}', email)
          .replaceAll('{password}', password);

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
  String get umaVoiceStart => _t('umaVoiceStart');
  String get umaVoiceStop => _t('umaVoiceStop');
  String get umaVoiceListening => _t('umaVoiceListening');
  String get umaVoicePermissionDenied => _t('umaVoicePermissionDenied');
  String get umaVoiceUnavailable => _t('umaVoiceUnavailable');
  String umaToolGoalCreated(String target) =>
      _t('umaToolGoalCreated').replaceAll('{target}', target);
  String umaToolBillAdded(String name, int days) => _t('umaToolBillAdded')
      .replaceAll('{name}', name)
      .replaceAll('{days}', '$days');
  String umaToolExpenseAdded(String name, String amount) =>
      _t('umaToolExpenseAdded')
          .replaceAll('{name}', name)
          .replaceAll('{amount}', amount);
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
  String get receiptDefaultName => _t('receiptDefaultName');
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
  String get close => _t('close');

  // ---- Wealth insight (autonomy policy summary) ----
  String get wealthInsightAddPortfolio => _t('wealthInsightAddPortfolio');
  String get wealthInsightPaused => _t('wealthInsightPaused');
  String wealthInsightActive(String profile, String limit, int count) =>
      _t('wealthInsightActive')
          .replaceAll('{profile}', profile)
          .replaceAll('{limit}', limit)
          .replaceAll('{count}', '$count');

  // ---- Goal advisor narrative ----
  String get goalReached => _t('goalReached');
  String goalRemainingPlan(String remaining, int months, String monthly) =>
      _t('goalRemainingPlan')
          .replaceAll('{remaining}', remaining)
          .replaceAll('{months}', '$months')
          .replaceAll('{monthly}', monthly);
  String get goalNarrativeNewTarget => _t('goalNarrativeNewTarget');
  String get goalNarrativeNoData => _t('goalNarrativeNoData');
  String goalNarrativeTrim(String monthly, String topCategory) =>
      _t('goalNarrativeTrim')
          .replaceAll('{monthly}', monthly)
          .replaceAll('{topCategory}', topCategory);

  // ---- Transaction time labels ----
  String todayAt(String time) => _t('todayAt').replaceAll('{time}', time);

  // ---- Login screen ----
  String get loginContinueEmail => _t('loginContinueEmail');
  String get loginEmailPasswordRequired => _t('loginEmailPasswordRequired');
  String loginFirebaseError(String code) =>
      _t('loginFirebaseError').replaceAll('{code}', code);
  String get loginFirebaseReadyFooter => _t('loginFirebaseReadyFooter');
  String get loginCreateAccount => _t('loginCreateAccount');

  // ---- Signup screen ----
  String get signupTitle => _t('signupTitle');
  String get signupSubtitleFirebase => _t('signupSubtitleFirebase');
  String get signupSubtitleLocal => _t('signupSubtitleLocal');
  String get signupFieldFullName => _t('signupFieldFullName');
  String get signupFieldEmail => _t('signupFieldEmail');
  String get signupFieldPassword => _t('signupFieldPassword');
  String get signupFieldConfirmPassword => _t('signupFieldConfirmPassword');
  String get signupErrorNameRequired => _t('signupErrorNameRequired');
  String get signupErrorInvalidEmail => _t('signupErrorInvalidEmail');
  String get signupErrorShortPassword => _t('signupErrorShortPassword');
  String get signupErrorPasswordMismatch => _t('signupErrorPasswordMismatch');
  String get signupErrorAcceptTerms => _t('signupErrorAcceptTerms');
  String signupFailedTemplate(String code) =>
      _t('signupFailedTemplate').replaceAll('{code}', code);
  String get signupTerms => _t('signupTerms');
  String get signupStrengthWeak => _t('signupStrengthWeak');
  String get signupStrengthMedium => _t('signupStrengthMedium');
  String get signupStrengthStrong => _t('signupStrengthStrong');
  String get signupCtaCreate => _t('signupCtaCreate');
  String get signupCtaContinueLocal => _t('signupCtaContinueLocal');
  String get signupAlreadyHaveAccount => _t('signupAlreadyHaveAccount');
  String get signupSignIn => _t('signupSignIn');

  // ---- Sample / demo account ----
  String get demoSampleLoaded => _t('demoSampleLoaded');
  String get demoBankPrimary => _t('demoBankPrimary');
  String get demoBankSavings => _t('demoBankSavings');
  String get demoBillCreditCard => _t('demoBillCreditCard');
  String get demoBillElectric => _t('demoBillElectric');
  String get demoBillInternet => _t('demoBillInternet');
  String get demoTxnSalary => _t('demoTxnSalary');
  String get demoTxnGrocery => _t('demoTxnGrocery');
  String get demoTxnFuel => _t('demoTxnFuel');
  String get demoTxnRestaurant => _t('demoTxnRestaurant');
  String get demoTxnPharmacy => _t('demoTxnPharmacy');
  String get demoTxnRent => _t('demoTxnRent');
  String get demoTxnTransfer => _t('demoTxnTransfer');
  String get demoTxnFamilyIncoming => _t('demoTxnFamilyIncoming');
  String get demoTxnAtm => _t('demoTxnAtm');

  // ---- Recovered Subscriptions & Wealth ----
  String subscriptionsAttentionCount(int n) =>
      _t('subscriptionsAttentionCount').replaceAll('{n}', '$n');
      
  String get subsAlertPriceMetric => _t('subsAlertPriceMetric');
  String get subsAlertUnusedTitle => _t('subsAlertUnusedTitle');
  String get subsAlertUnusedMessageNone => _t('subsAlertUnusedMessageNone');
  
  String subsAlertUnusedMessageSome(int n) =>
      _t('subsAlertUnusedMessageSome').replaceAll('{n}', '$n');
      
  String get subsAlertUnusedMetric => _t('subsAlertUnusedMetric');
  String get subsInsightEmpty => _t('subsInsightEmpty');
  String get subsInsightHealthy => _t('subsInsightHealthy');
  
  String subsInsightNeedsAttention(int n, String amount) =>
      _t('subsInsightNeedsAttention')
          .replaceAll('{n}', '$n')
          .replaceAll('{amount}', amount);
          
  String get noSubscriptionsDetectedTitle => _t('noSubscriptionsDetectedTitle');
  String get noSubscriptionsForFilterTitle => _t('noSubscriptionsForFilterTitle');
  String get noSubscriptionsDetectedBody => _t('noSubscriptionsDetectedBody');
  String get noSubscriptionsForFilterBody => _t('noSubscriptionsForFilterBody');
  String get subsStatusActive => _t('subsStatusActive');
  String get subsStatusPriceUp => _t('subsStatusPriceUp');
  String get subsStatusUnused => _t('subsStatusUnused');
  String get subsStatusRenewsSoon => _t('subsStatusRenewsSoon');
  
  String get categoryEntertainment => _t('categoryEntertainment');
  String get categoryMusic => _t('categoryMusic');
  String get categoryVideo => _t('categoryVideo');
  String get categoryStorage => _t('categoryStorage');
  String get categoryDeveloper => _t('categoryDeveloper');
  String get categoryAi => _t('categoryAi');
  String get categorySubscription => _t('categorySubscription');
  
  String get removeHolding => _t('removeHolding');
  String get addHoldingTitle => _t('addHoldingTitle');
  String get addHoldingSubtitle => _t('addHoldingSubtitle');
  String get noWealthActionsTitle => _t('noWealthActionsTitle');
  String get startPortfolioTitle => _t('startPortfolioTitle');
  String get noWealthActionsBody => _t('noWealthActionsBody');
  String get startPortfolioBody => _t('startPortfolioBody');
  String get wealthActionReversed => _t('wealthActionReversed');
  String get wealthApprovalAuto => _t('wealthApprovalAuto');
  String get wealthApprovalHybrid => _t('wealthApprovalHybrid');
  
  String get fieldLabelOptional => _t('fieldLabelOptional');
  String get addHoldingHint => _t('addHoldingHint');
  String get holdingValueLabel => _t('holdingValueLabel');
  String get actionAdd => _t('actionAdd');
  String get holdingBucketEquity => _t('holdingBucketEquity');
  String get holdingBucketGold => _t('holdingBucketGold');
  String get holdingBucketCash => _t('holdingBucketCash');
  String get holdingBucketCrypto => _t('holdingBucketCrypto');
  String get holdingBucketFunds => _t('holdingBucketFunds');
  String get holdingBucketBonds => _t('holdingBucketBonds');

  // ---- Recovered Getters ----
  String get actionUpdate => _t('actionUpdate');
  String get goalEmptyHint => _t('goalEmptyHint');
  String get addManualTxnNameHint => _t('addManualTxnNameHint');
  String get noTransactionsBody => _t('noTransactionsBody');
  String get umaInsightNoData => _t('umaInsightNoData');
  String subsSeenInRecentTransactions(int n) => _t('subsSeenInRecentTransactions').replaceAll('{n}', '$n');
  String get statementFallbackWarning => _t('statementFallbackWarning');
  String get actionDelete => _t('actionDelete');
  String get proactiveHealthyCta => _t('proactiveHealthyCta');
  String get connectedAccountsEmptyBody => _t('connectedAccountsEmptyBody');
  String get scanFallbackAction => _t('scanFallbackAction');
  String get goalMonthsLabel => _t('goalMonthsLabel');
  String get umaInsightNoTransactions => _t('umaInsightNoTransactions');
  String get subsRecommendationDetected => _t('subsRecommendationDetected');
  String get noTrackedBillsTitle => _t('noTrackedBillsTitle');
  String get subsDetectedFromImport => _t('subsDetectedFromImport');
  String get billKindRent => _t('billKindRent');
  String get fieldCategory => _t('fieldCategory');
  String get onbBlankCanvasBody => _t('onbBlankCanvasBody');
  String get categorySalary => _t('categorySalary');
  String get categoryTransfer => _t('categoryTransfer');
  String get umaInsightNoPattern => _t('umaInsightNoPattern');
  String get goalCalculate => _t('goalCalculate');
  String get proactiveEmptyBody => _t('proactiveEmptyBody');
  String get homeFirstStepsBody => _t('homeFirstStepsBody');
  String goalMonthsOption(int n) => _t('goalMonthsOption').replaceAll('{n}', '$n');
  String get subsAlertSavingsTitle => _t('subsAlertSavingsTitle');
  String goalPresetEmergency(String amount) => _t('goalPresetEmergency').replaceAll('{amount}', amount);
  String get fieldDescription => _t('fieldDescription');
  String get subsKnownVendorLabel => _t('subsKnownVendorLabel');
  String get categoryFuel => _t('categoryFuel');
  String get proactiveEmptyTitle => _t('proactiveEmptyTitle');
  String get scanFallbackWarning => _t('scanFallbackWarning');

  String get statementFallbackAction => _t('statementFallbackAction');
  String get aiSuggestionLabel => _t('aiSuggestionLabel');
  String get subsAlertSavingsMessageActive => _t('subsAlertSavingsMessageActive');
  String get billKindOther => _t('billKindOther');
  String goalPresetCar(String amount) => _t('goalPresetCar').replaceAll('{amount}', amount);
  String get subsAlertPriceTitle => _t('subsAlertPriceTitle');
  String get noTransactionsTitle => _t('noTransactionsTitle');
  String get fieldDate => _t('fieldDate');
  String get billKindCard => _t('billKindCard');
  String get txnTypeIncome => _t('txnTypeIncome');
  String get addManualTxnTitle => _t('addManualTxnTitle');
  String get noTrackedBillsBody => _t('noTrackedBillsBody');
  String get onbPalettePreviewBody => _t('onbPalettePreviewBody');
  String get categoryMarket => _t('categoryMarket');
  String get actionManual => _t('actionManual');
  String get umaInsightAddFirstTxnCta => _t('umaInsightAddFirstTxnCta');
  String get umaInsightImportCta => _t('umaInsightImportCta');
  String get categoryFood => _t('categoryFood');
  String get txnTypeExpense => _t('txnTypeExpense');
  String get billKindGas => _t('billKindGas');
  String get categoryHealth => _t('categoryHealth');
  String get editBillTitle => _t('editBillTitle');
  String get billKindInternet => _t('billKindInternet');
  String get addBillTitle => _t('addBillTitle');
  String goalPresetVacation(String amount) => _t('goalPresetVacation').replaceAll('{amount}', amount);
  String get onbBlankCanvasTitle => _t('onbBlankCanvasTitle');
  String get dueDateLabel => _t('dueDateLabel');
  String get onbPalettePreviewTitle => _t('onbPalettePreviewTitle');
  String get addBillNameHint => _t('addBillNameHint');
  String get billKindWater => _t('billKindWater');
  String get proactiveEmptyCta => _t('proactiveEmptyCta');
  String get securityEmptyTitle => _t('securityEmptyTitle');
  String get fieldAmountTl => _t('fieldAmountTl');
  String get billKindElectric => _t('billKindElectric');
  String get subsAlertSavingsMetric => _t('subsAlertSavingsMetric');
  String get onbContinueWithoutImport => _t('onbContinueWithoutImport');
  String get homeFirstStepsTitle => _t('homeFirstStepsTitle');
  String get goalEmptyCta => _t('goalEmptyCta');
  String get connectedAccountsEmptyTitle => _t('connectedAccountsEmptyTitle');
  String goalAdviceSummary(String amount, int months) => _t('goalAdviceSummary').replaceAll('{amount}', amount).replaceAll('{months}', '$months');
  String get umaInsightDeepenCta => _t('umaInsightDeepenCta');
  String get addBillCta => _t('addBillCta');
  String get subsAlertPriceMessageSome => _t('subsAlertPriceMessageSome');
  String get fieldName => _t('fieldName');
  String get securityEmptyBody => _t('securityEmptyBody');
  String get proactiveHealthyTitle => _t('proactiveHealthyTitle');
  String get goalEmptyPrompt => _t('goalEmptyPrompt');
  String get categoryEducation => _t('categoryEducation');
  String get proactiveHealthyBody => _t('proactiveHealthyBody');
  String get categoryBill => _t('categoryBill');
  String get subsAlertPriceMessageNone => _t('subsAlertPriceMessageNone');
  String get acceptSuggestion => _t('acceptSuggestion');
  String get homeFirstStepsHint => _t('homeFirstStepsHint');
  String get subsAlertSavingsMessageEmpty => _t('subsAlertSavingsMessageEmpty');
  String umaInsightTopCategory(String category, String amount, int share, String total) => _t('umaInsightTopCategory').replaceAll('{category}', category).replaceAll('{amount}', amount).replaceAll('{share}', '$share').replaceAll('{total}', total);

}

// ---- Translations (6 locales) ----
const Map<AppLocale, Map<String, String>> _strings = {
  AppLocale.tr: _trStrings,
  AppLocale.en: _enStrings,
  AppLocale.de: _deStrings,
  AppLocale.ar: _arStrings,
  AppLocale.ru: _ruStrings,
  AppLocale.zh: _zhStrings,
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
