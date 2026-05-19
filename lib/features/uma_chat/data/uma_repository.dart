import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/analytics_service.dart';
import '../../../core/firebase/remote_config_service.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/orchestration/user_readiness.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/utils/formatters.dart';
import '../../home/data/category_summary.dart';
import '../../home/state/goals_controller.dart';
import '../../home/state/home_controller.dart';
import '../../home/state/upcoming_bills_controller.dart';
import '../../subscriptions/state/subscriptions_controller.dart';
import '../../wealth/state/wealth_controller.dart';
import '../domain/uma_audit_event.dart';
import '../domain/uma_feedback.dart';
import '../domain/uma_intent.dart';
import '../domain/uma_memory.dart';
import '../domain/uma_message.dart';
import '../domain/uma_response.dart';
import 'firebase_uma_audit_store.dart';
import 'firebase_uma_feedback_store.dart';
import 'firebase_uma_memory_store.dart';
import 'intent_router.dart';
import 'uma_tools.dart';

class UmaRepository {
  UmaRepository(
    this._gemini,
    this._router,
    this._feedbackStore,
    this._auditStore,
    this._memoryStore,
    this._remoteConfig,
    this._analytics,
    this._ref,
  );

  final GeminiService _gemini;
  final IntentRouter _router;
  final FirebaseUmaFeedbackStore _feedbackStore;
  final FirebaseUmaAuditStore _auditStore;
  final FirebaseUmaMemoryStore _memoryStore;
  final RemoteConfigService _remoteConfig;
  final AnalyticsService _analytics;
  final Ref _ref;

  AppStrings get _strings => AppStrings(_ref.read(localeControllerProvider));

  Future<UmaMessage> handle(
    String userText, {
    bool requireConfirmation = true,
  }) async {
    final intent = _router.parse(userText);
    final l10n = _strings;
    final readiness = _ref.read(userReadinessProvider);
    final memory = await _memoryStore.loadProfile();
    final summary = await _memoryStore.loadConversationSummary();
    final deterministic = _deterministicReply(
      intent: intent,
      readiness: readiness,
      memory: memory,
      summary: summary,
      l10n: l10n,
    );
    if (deterministic != null) {
      await _updateConversationSummary(
        previous: summary,
        topic: intent.type.name,
      );
      return deterministic;
    }

    if (!readiness.geminiReady) {
      final fallback = _buildFallbackEnvelope(
        readiness: readiness,
        memory: memory,
        l10n: l10n,
      );
      await _appendConfidenceAudit(
        envelope: fallback,
        intent: intent.type.name,
      );
      return _reply(
        intent: intent.type.name,
        envelope: fallback,
        kind: UmaMessageKind.fallback,
      );
    }

    try {
      UmaResponseEnvelope? toolProposal;
      UmaResponseEnvelope? toolCompletion;
      final result = await _gemini.runAgent(
        prompt: await buildPrompt(
          userText,
          readiness: readiness,
          memory: memory,
          summary: summary,
        ),
        tools: umaTools,
        onCall: (name, args) async {
          final policy = evaluateUmaToolPolicy(
            name: name,
            args: args,
            l10n: l10n,
            requireConfirmation: requireConfirmation,
            strictness: _remoteConfig.umaToolPolicyStrictness,
          );
          switch (policy.status) {
            case UmaToolPolicyStatus.allowed:
              final res = await executeUmaTool(
                name: name,
                args: args,
                ref: _ref,
                l10n: l10n,
              );
              toolCompletion = _toolSuccessEnvelope(
                text: res.outcome.confirmation,
                policy: policy,
                sources: _buildSourcesForIntent(intent, readiness, memory),
                l10n: l10n,
              );
              await _recordMemoryFromTool(name: name, memory: memory, summary: summary);
              return res.response;
            case UmaToolPolicyStatus.needsConfirmation:
              toolProposal = _toolProposalEnvelope(
                policy: policy,
                pendingToolCall: UmaPendingToolCall(
                  name: name,
                  args: args,
                  summary: policy.summary,
                ),
                sources: _buildSourcesForIntent(intent, readiness, memory),
                l10n: l10n,
              );
              return {
                'policy': 'needs_confirmation',
                'reason': policy.reason,
                'summary': policy.summary,
              };
            case UmaToolPolicyStatus.missingContext:
            case UmaToolPolicyStatus.blocked:
              toolProposal = _toolFailureEnvelope(
                text: policy.reason,
                policy: policy,
                sources: _buildSourcesForIntent(intent, readiness, memory),
                l10n: l10n,
              );
              return {
                'policy': policy.status.name,
                'reason': policy.reason,
              };
          }
        },
      );

      final envelope =
          toolCompletion ??
          toolProposal ??
          _structuredAgentEnvelope(
            result: result,
            intent: intent.type.name,
            readiness: readiness,
            memory: memory,
            l10n: l10n,
          );
      await _analytics.logUmaIntent(
        intent: intent.type.name,
        resolvedByGemini: true,
      );
      await _updateConversationSummary(
        previous: summary,
        topic: intent.type.name,
      );
      await _appendConfidenceAudit(
        envelope: envelope,
        intent: intent.type.name,
      );
      return _reply(
        intent: intent.type.name,
        envelope: envelope,
        kind: _kindForEnvelope(envelope),
      );
    } catch (_) {
      final fallback = _buildFallbackEnvelope(
        readiness: readiness,
        memory: memory,
        l10n: l10n,
      );
      await _appendConfidenceAudit(
        envelope: fallback,
        intent: intent.type.name,
      );
      return _reply(
        intent: intent.type.name,
        envelope: fallback,
        kind: UmaMessageKind.fallback,
      );
    }
  }

  Future<UmaMessage> confirmPendingToolCall(
    UmaPendingToolCall call, {
    required String messageId,
    String? intent,
  }) async {
    final l10n = _strings;
    final memory = await _memoryStore.loadProfile();
    final summary = await _memoryStore.loadConversationSummary();
    final res = await executeUmaTool(
      name: call.name,
      args: call.args,
      ref: _ref,
      l10n: l10n,
    );
    await _recordMemoryFromTool(name: call.name, memory: memory, summary: summary);
    final envelope = UmaResponseEnvelope(
      kind: UmaResponseKind.toolSuccess,
      text: res.outcome.confirmation,
      confidence: 0.94,
      why: l10n.umaToolExecutedWhy,
      toolOutcome: res.outcome.toolName,
      sources: _buildSourcesForExecution(call.name),
      nextStep: _defaultNextStep(_ref.read(userReadinessProvider), l10n),
    );
    await appendAuditEvent(
      messageId: messageId,
      action: UmaAuditAction.orderForwarded,
      summary: call.summary,
      intent: intent,
      metadata: {
        'toolName': call.name,
        'confirmedInChat': true,
      },
    );
    return _reply(
      intent: intent,
      envelope: envelope,
      kind: UmaMessageKind.toolSuccess,
    );
  }

  Future<void> saveFeedback({
    required String messageId,
    required String responseText,
    required UmaFeedbackVote vote,
    String? note,
  }) {
    return _feedbackStore.save(
      UmaFeedbackEntry(
        messageId: messageId,
        vote: vote,
        responseText: responseText,
        createdAt: DateTime.now(),
        note: note,
      ),
    );
  }

  Future<void> rememberFeedback({
    required UmaFeedbackVote vote,
    String? note,
  }) async {
    if (!_remoteConfig.umaMemoryWriteEnabled) return;
    final profile = await _memoryStore.loadProfile();
    final next = vote == UmaFeedbackVote.helpful
        ? profile.copyWith(
            helpfulFeedbackCount: profile.helpfulFeedbackCount + 1,
            riskTone: 'calm',
          )
        : profile.copyWith(
            notHelpfulFeedbackCount: profile.notHelpfulFeedbackCount + 1,
            riskTone: 'direct',
          );
    final summary = await _memoryStore.loadConversationSummary();
    await _memoryStore.save(profile: next, summary: summary);
  }

  Future<List<UmaFeedbackEntry>> loadFeedback() {
    return _feedbackStore.load();
  }

  Future<void> appendAuditEvent({
    required String messageId,
    required UmaAuditAction action,
    required String summary,
    String? intent,
    String? note,
    Map<String, dynamic> metadata = const {},
  }) {
    final timestamp = DateTime.now();
    final signature = _signatureFor(
      messageId: messageId,
      action: action,
      summary: summary,
      timestamp: timestamp,
      intent: intent,
      note: note,
      metadata: metadata,
    );
    return _auditStore.append(
      UmaAuditEvent(
        id: 'audit-${timestamp.microsecondsSinceEpoch}',
        messageId: messageId,
        action: action,
        timestamp: timestamp,
        signature: signature,
        summary: summary,
        intent: intent,
        note: note,
        metadata: metadata,
      ),
    );
  }

  Future<List<UmaAuditEvent>> loadAuditEvents() {
    return _auditStore.load();
  }

  Future<String> buildPrompt(
    String userText, {
    required UserReadiness readiness,
    required UmaMemoryProfile memory,
    required UmaConversationSummary summary,
  }) async {
    final feedbackContext = await _feedbackStore.buildPromptContext();
    final userContext = _buildUserContext(
      readiness: readiness,
      memory: memory,
      summary: summary,
    );
    return '''
SYSTEM_POLICY:
- Identity: You are Uma, the financial coach embedded in the Vera personal-finance app.
- Scope: Answer only questions tied to the user's personal finances — budgeting, spending analysis, savings goals, bills, subscriptions, debt, investments, taxes, financial literacy, and Vera features that surface those. For anything outside that scope (medical, legal, political opinion, generic chit-chat, code help, etc.), politely decline in one sentence and offer to return to a finance topic. Never give legally or medically binding advice.
- Honesty about capabilities: Vera does NOT have live bank API access. You can analyze imported data, plan, suggest, and prepare proposals through Vera's internal tools, but you must never claim to have moved money, paid a bill, bought an asset, or contacted a bank on the user's behalf. Mutating tools require explicit user confirmation.
- Grounding: Use only numbers and facts that appear in SOURCE_CONTEXT, MEMORY_SUMMARY, or the USER_MESSAGE. Never invent transactions, balances, prices, exchange rates, interest rates, dates, or merchants. If the data needed isn't present, say what's missing and propose how to add it (import statement, scan receipt, manual entry).
- Language: Detect the language of USER_MESSAGE and reply in that same language. Default to Turkish if the language is ambiguous. Keep currency in TL unless the user explicitly uses another currency.
- Style: Short, concrete, and personal — under ~80 words unless a list is necessary. Lead with the answer, then a single line of reasoning, then one next step. Use the user's actual numbers when available. Avoid disclaimers unless safety or compliance demands them.
- Confidence: If your confidence is below 0.55, say so plainly and propose a diagnostic step (e.g., "İşlemleri görmem gerek — ekstreni içe aktarır mısın?") instead of guessing. Never bluff certainty about market direction, future prices, or speculative outcomes.
- Privacy: Do not surface or repeat sensitive PII (full card numbers, IBAN, passwords, OTPs, government IDs) even if visible in context. Refer to accounts by bank name only.
- Safety: Refuse any request to evade taxes, move money illegally, bypass KYC/AML, or commit fraud. Refuse to recommend specific financial products as guaranteed; investments carry risk and you must say so when relevant.
- Tooling: Prefer Vera's internal tools over free-form prose for actionable proposals. Surface a single proposal at a time and wait for confirmation.

READINESS_SUMMARY:
- persona: ${readiness.persona}
- localOnly: ${readiness.localOnly}
- dataDepth: ${readiness.dataDepth.toStringAsFixed(2)}
- sourceCoverage: ${readiness.sourceCoverage.toStringAsFixed(2)}

MEMORY_SUMMARY:
- spendingSensitivity: ${memory.spendingSensitivity}
- riskTone: ${memory.riskTone}
- savingsMotivation: ${memory.savingsMotivation}
- favoriteActionType: ${memory.favoriteActionType}
- recentTopics: ${summary.recentTopics.join(', ')}

SOURCE_CONTEXT:
$userContext
${feedbackContext.isEmpty ? '' : '\nUSER_FEEDBACK_CONTEXT:\n$feedbackContext\n'}

USER_MESSAGE:
$userText
''';
  }

  String _buildUserContext({
    required UserReadiness readiness,
    required UmaMemoryProfile memory,
    required UmaConversationSummary summary,
  }) {
    final home = _ref.read(homeControllerProvider);
    final bills = _ref.read(upcomingBillsControllerProvider);
    final goal = _ref.read(goalsControllerProvider);
    final subs = _ref.read(subscriptionsControllerProvider);
    final wealth = _ref.read(wealthControllerProvider);
    final totalCash = home.banks.fold<double>(0, (s, b) => s + b.balance);
    final txns = home.transactions.take(10).toList();
    final spending = summarizeSpending(home.transactions, otherLabel: 'Diger');

    final buf = StringBuffer()
      ..writeln('- persona=${readiness.persona}')
      ..writeln('- totalCashTL=${totalCash.toStringAsFixed(0)}')
      ..writeln('- preferredRiskTone=${memory.riskTone}')
      ..writeln('- favoriteActionType=${memory.favoriteActionType}');

    if (goal.target > 0) {
      buf.writeln(
        '- goal target=${goal.target.toStringAsFixed(0)} saved=${goal.saved.toStringAsFixed(0)}',
      );
    }
    if (subs.items.isNotEmpty) {
      buf.writeln('- subscriptions=${subs.items.length}');
    }
    if (bills.isNotEmpty) {
      buf.writeln('- upcomingBills=${bills.length}');
    }
    if (wealth.allocations.isNotEmpty) {
      buf.writeln('- wealthBuckets=${wealth.allocations.length}');
    }
    if (spending.isNotEmpty) {
      buf.writeln(
        '- topSpending=${spending.take(3).map((s) => '${s.category}:${s.amount.toStringAsFixed(0)}').join(', ')}',
      );
    }
    if (txns.isNotEmpty) {
      buf.writeln('- recentTransactions:');
      for (final t in txns) {
        buf.writeln(
          '  - ${t.when} ${t.name} ${t.category} ${t.amount.toStringAsFixed(0)}',
        );
      }
    }
    if (summary.recentTopics.isNotEmpty) {
      buf.writeln('- recentTopics=${summary.recentTopics.join(', ')}');
    }
    return buf.toString().trim();
  }

  UmaMessage? _deterministicReply({
    required UmaIntent intent,
    required UserReadiness readiness,
    required UmaMemoryProfile memory,
    required UmaConversationSummary summary,
    required AppStrings l10n,
  }) {
    final sources = _buildSourcesForIntent(intent, readiness, memory);
    final nextStep = _nextStepForIntent(intent, readiness, l10n);
    switch (intent.type) {
      case UmaIntentType.buyGold:
        final banks = _ref.read(homeControllerProvider).banks;
        final primary = banks.isEmpty ? 'Garanti BBVA' : banks.first.name;
        return _reply(
          intent: intent.type.name,
          card: OrderCard(
            type: UmaActionType.buyGold,
            title: l10n.orderTitleBuyGold,
            from: '${l10n.connectedAccounts} / $primary',
            to: '$primary Gold',
            amount: 29840,
            bankApp: primary,
            detailLabel: l10n.orderTitleGoldRate,
            detailValue: 'TL 2.984/g',
          ),
          kind: UmaMessageKind.assistant,
          envelope: UmaResponseEnvelope(
            kind: UmaResponseKind.answer,
            text: l10n.umaReplyBuyGold(primary),
            confidence: 0.84,
            why: l10n.umaWhyGoldPlan,
            sources: sources,
            nextStep: nextStep,
          ),
        );
      case UmaIntentType.payCreditCard:
        final banks = _ref.read(homeControllerProvider).banks;
        final bankName =
            banks.length > 1 ? banks[1].name : (banks.isNotEmpty ? banks.first.name : 'Akbank');
        return _reply(
          intent: intent.type.name,
          card: OrderCard(
            type: UmaActionType.payCreditCard,
            title: l10n.orderTitlePayCard,
            from: '${l10n.connectedAccounts} / $bankName',
            to: bankName,
            amount: 12450,
            bankApp: bankName,
            detailLabel: l10n.orderTitleDue,
            detailValue: l10n.orderTitleDueToday,
          ),
          kind: UmaMessageKind.assistant,
          envelope: UmaResponseEnvelope(
            kind: UmaResponseKind.answer,
            text: l10n.umaReplyPayCard(bankName),
            confidence: 0.87,
            why: l10n.umaWhyBillPlan,
            sources: sources,
            nextStep: nextStep,
          ),
        );
      case UmaIntentType.moveToSavings:
        final goal = _ref.read(goalsControllerProvider);
        const moveAmount = 2500.0;
        final after = goal.target <= 0
            ? 0
            : (((goal.saved + moveAmount) / goal.target) * 100)
                .clamp(0, 100)
                .round();
        final source = _ref.read(homeControllerProvider).banks.isEmpty
            ? 'Yapi Kredi'
            : _ref.read(homeControllerProvider).banks.first.name;
        return _reply(
          intent: intent.type.name,
          card: OrderCard(
            type: UmaActionType.moveToSavings,
            title: l10n.goalEmergencyFund,
            from: source,
            to: l10n.goalEmergencyFund,
            amount: moveAmount,
            bankApp: source,
            detailLabel: l10n.goalsSectionTitle,
            detailValue: '$after%',
          ),
          kind: UmaMessageKind.assistant,
          envelope: UmaResponseEnvelope(
            kind: UmaResponseKind.answer,
            text: l10n.umaReplyMoveSavings(after),
            confidence: 0.86,
            why: l10n.umaWhyGoalPlan,
            sources: sources,
            nextStep: nextStep,
          ),
        );
      case UmaIntentType.showSubscriptions:
        final subs = _ref.read(subscriptionsControllerProvider);
        return _reply(
          intent: intent.type.name,
          kind: UmaMessageKind.assistant,
          envelope: UmaResponseEnvelope(
            kind: UmaResponseKind.answer,
            text: subs.items.isEmpty
                ? l10n.umaReplySubscriptionsEmpty()
                : l10n.umaReplySubscriptions(
                    subs.items.length,
                    fmtTL(subs.monthlyTotal),
                  ),
            confidence: subs.items.isEmpty ? 0.62 : 0.9,
            why: l10n.umaWhySubscriptions,
            sources: sources,
            nextStep: nextStep,
          ),
        );
      case UmaIntentType.analyzeSpending:
        final txns = _ref.read(homeControllerProvider).transactions;
        final spending =
            summarizeSpending(txns, otherLabel: l10n.categoryOther);
        if (spending.isEmpty) {
          return _reply(
            intent: intent.type.name,
            kind: UmaMessageKind.fallback,
            envelope: UmaResponseEnvelope(
              kind: UmaResponseKind.fallback,
              text: l10n.umaReplyAnalyzeEmpty(),
              confidence: 0.42,
              why: l10n.umaWhyInsufficientData,
              sources: sources,
              nextStep: _defaultNextStep(readiness, l10n),
            ),
          );
        }
        final top = spending.first;
        final total = totalSpending(spending);
        return _reply(
          intent: intent.type.name,
          kind: UmaMessageKind.assistant,
          envelope: UmaResponseEnvelope(
            kind: UmaResponseKind.answer,
            text: l10n.umaReplyAnalyze(
              top.category,
              fmtTL(top.amount),
              fmtTL(total),
            ),
            confidence: readiness.dataDepth < 0.4 ? 0.68 : 0.9,
            why: l10n.umaWhySpending,
            sources: sources,
            nextStep: nextStep,
          ),
        );
      case UmaIntentType.explainWealth:
        return _reply(
          intent: intent.type.name,
          kind: UmaMessageKind.assistant,
          envelope: UmaResponseEnvelope(
            kind: UmaResponseKind.answer,
            text: l10n.umaReplyExplainWealth,
            confidence: 0.76,
            why: l10n.umaWhyWealth,
            sources: sources,
            nextStep: nextStep,
          ),
        );
      case UmaIntentType.checkLoanEligibility:
        return _reply(
          intent: intent.type.name,
          kind: UmaMessageKind.assistant,
          envelope: UmaResponseEnvelope(
            kind: UmaResponseKind.answer,
            text: l10n.umaReplyLoan,
            confidence: 0.73,
            why: l10n.umaWhyLoan,
            sources: sources,
            nextStep: nextStep,
          ),
        );
      case UmaIntentType.explainSecurityAlert:
        return _reply(
          intent: intent.type.name,
          kind: UmaMessageKind.assistant,
          envelope: UmaResponseEnvelope(
            kind: UmaResponseKind.answer,
            text: l10n.umaReplySecurity,
            confidence: 0.71,
            why: l10n.umaWhySecurity,
            sources: sources,
            nextStep: nextStep,
          ),
        );
      case UmaIntentType.unknown:
        return null;
    }
  }

  UmaResponseEnvelope _structuredAgentEnvelope({
    required AgentResult result,
    required String intent,
    required UserReadiness readiness,
    required UmaMemoryProfile memory,
    required AppStrings l10n,
  }) {
    final payload = result.payload;
    final text = ((payload['answer'] as String?) ?? result.text).trim();
    final why = (payload['why'] as String?)?.trim();
    final confidence =
        (payload['confidence'] as num?)?.toDouble() ?? _inferConfidence(readiness, memory);
    final nextStep = _parseNextStep(payload, readiness, l10n);
    final sources = _parseSources(payload, l10n).isNotEmpty
        ? _parseSources(payload, l10n)
        : _buildSourcesForIntent(_router.parse(intent), readiness, memory);
    return UmaResponseEnvelope(
      kind: confidence < 0.55
          ? UmaResponseKind.fallback
          : UmaResponseKind.answer,
      text: text.isEmpty ? _fallbackText(readiness, l10n) : text,
      confidence: confidence,
      why: why ?? _defaultWhy(readiness, l10n),
      sources: sources,
      nextStep: nextStep ?? _defaultNextStep(readiness, l10n),
    );
  }

  UmaResponseEnvelope _toolProposalEnvelope({
    required UmaToolPolicy policy,
    required UmaPendingToolCall pendingToolCall,
    required List<UmaSourceRef> sources,
    required AppStrings l10n,
  }) {
    return UmaResponseEnvelope(
      kind: UmaResponseKind.proposal,
      text: l10n.umaToolProposal(policy.summary),
      confidence: 0.88,
      why: policy.reason,
      sources: sources,
      toolPolicy: UmaToolPolicyResult(
        status: policy.status,
        reason: policy.reason,
      ),
      pendingToolCall: pendingToolCall,
      nextStep: UmaNextStep(
        label: l10n.umaConfirmAction,
        type: UmaNextStepType.confirmTool,
      ),
    );
  }

  UmaResponseEnvelope _toolSuccessEnvelope({
    required String text,
    required UmaToolPolicy policy,
    required List<UmaSourceRef> sources,
    required AppStrings l10n,
  }) {
    return UmaResponseEnvelope(
      kind: UmaResponseKind.toolSuccess,
      text: text,
      confidence: 0.93,
      why: policy.reason,
      sources: sources,
      nextStep: _defaultNextStep(_ref.read(userReadinessProvider), l10n),
    );
  }

  UmaResponseEnvelope _toolFailureEnvelope({
    required String text,
    required UmaToolPolicy policy,
    required List<UmaSourceRef> sources,
    required AppStrings l10n,
  }) {
    return UmaResponseEnvelope(
      kind: UmaResponseKind.toolFailure,
      text: text,
      confidence: 0.34,
      why: l10n.umaWhyMissingContext,
      sources: sources,
      toolPolicy: UmaToolPolicyResult(
        status: policy.status,
        reason: policy.reason,
      ),
      nextStep: _defaultNextStep(_ref.read(userReadinessProvider), l10n),
    );
  }

  UmaResponseEnvelope _buildFallbackEnvelope({
    required UserReadiness readiness,
    required UmaMemoryProfile memory,
    required AppStrings l10n,
  }) {
    return UmaResponseEnvelope(
      kind: UmaResponseKind.fallback,
      text: _fallbackText(readiness, l10n),
      confidence: 0.28,
      why: memory.helpfulFeedbackCount > memory.notHelpfulFeedbackCount
          ? l10n.umaWhyFallbackSoft
          : l10n.umaWhyFallbackDirect,
      sources: [
        UmaSourceRef(
          label: l10n.umaSourceReadiness,
          detail: readiness.localOnly
              ? l10n.umaStatusLocalOnly
              : l10n.umaStatusNeedsData,
          type: UmaSourceType.readiness,
        ),
      ],
      nextStep: _defaultNextStep(readiness, l10n),
    );
  }

  Future<void> _recordMemoryFromTool({
    required String name,
    required UmaMemoryProfile memory,
    required UmaConversationSummary summary,
  }) async {
    if (!_remoteConfig.umaMemoryWriteEnabled) return;
    final next = memory.copyWith(
      favoriteActionType: name,
      lastProductSurface: 'uma_chat',
      savingsMotivation:
          name == UmaToolNames.createSavingsGoal ? 'goal_progress' : memory.savingsMotivation,
    );
    await _memoryStore.save(profile: next, summary: summary);
    await appendAuditEvent(
      messageId: 'memory-${DateTime.now().microsecondsSinceEpoch}',
      action: UmaAuditAction.memoryUpdated,
      summary: name,
      metadata: {'surface': 'uma_chat'},
    );
  }

  Future<void> _updateConversationSummary({
    required UmaConversationSummary previous,
    required String topic,
  }) async {
    final topics = [topic, ...previous.recentTopics.where((t) => t != topic)]
        .take(5)
        .toList();
    final profile = await _memoryStore.loadProfile();
    await _memoryStore.save(
      profile: profile,
      summary: previous.copyWith(
        recentTopics: topics,
        lastUpdatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _appendConfidenceAudit({
    required UmaResponseEnvelope envelope,
    required String intent,
  }) async {
    if (envelope.confidence >= 0.55) return;
    await appendAuditEvent(
      messageId: 'confidence-${DateTime.now().microsecondsSinceEpoch}',
      action: UmaAuditAction.confidenceReduced,
      summary: envelope.text,
      intent: intent,
      metadata: {'confidence': envelope.confidence},
    );
  }

  List<UmaSourceRef> _buildSourcesForIntent(
    UmaIntent intent,
    UserReadiness readiness,
    UmaMemoryProfile memory,
  ) {
    final home = _ref.read(homeControllerProvider);
    final goal = _ref.read(goalsControllerProvider);
    final subs = _ref.read(subscriptionsControllerProvider);
    final sources = <UmaSourceRef>[
      UmaSourceRef(
        label: _strings.umaSourceReadiness,
        detail: readiness.localOnly
            ? _strings.umaStatusLocalOnly
            : _strings.umaStatusOnline,
        type: UmaSourceType.readiness,
      ),
      UmaSourceRef(
        label: _strings.umaSourceMemory,
        detail: memory.favoriteActionType,
        type: UmaSourceType.memory,
      ),
    ];
    if (intent.type == UmaIntentType.analyzeSpending &&
        home.transactions.isNotEmpty) {
      sources.add(
        UmaSourceRef(
          label: _strings.recentTransactions,
          detail: '${home.transactions.take(3).length} ${_strings.itemsVisible}',
          type: UmaSourceType.transaction,
        ),
      );
    }
    if (intent.type == UmaIntentType.showSubscriptions && subs.items.isNotEmpty) {
      sources.add(
        UmaSourceRef(
          label: _strings.navPlans,
          detail: '${subs.items.length} ${_strings.filterAll.toLowerCase()}',
          type: UmaSourceType.subscriptions,
        ),
      );
    }
    if (intent.type == UmaIntentType.moveToSavings && goal.target > 0) {
      sources.add(
        UmaSourceRef(
          label: _strings.goalEmergencyFund,
          detail: _strings.goalProgress(
            '${(((goal.saved / goal.target) * 100).clamp(0, 100)).round()}',
          ),
          type: UmaSourceType.goal,
        ),
      );
    }
    if (home.banks.isNotEmpty) {
      sources.add(
        UmaSourceRef(
          label: _strings.connectedAccounts,
          detail: '${home.banks.length} ${_strings.itemsVisible}',
          type: UmaSourceType.transaction,
        ),
      );
    }
    return sources.take(_remoteConfig.umaCitationMode == 'compact' ? 3 : 5).toList();
  }

  List<UmaSourceRef> _buildSourcesForExecution(String toolName) {
    switch (toolName) {
      case UmaToolNames.createSavingsGoal:
        final goal = _ref.read(goalsControllerProvider);
        return [
          UmaSourceRef(
            label: _strings.goalEmergencyFund,
            detail: fmtTL(goal.target),
            type: UmaSourceType.goal,
          ),
        ];
      case UmaToolNames.addUpcomingBill:
        final bills = _ref.read(upcomingBillsControllerProvider);
        return [
          UmaSourceRef(
            label: _strings.upcomingBills,
            detail: '${bills.length} ${_strings.itemsVisible}',
            type: UmaSourceType.goal,
          ),
        ];
      case UmaToolNames.addExpense:
        final txns = _ref.read(homeControllerProvider).transactions;
        return [
          UmaSourceRef(
            label: _strings.recentTransactions,
            detail: '${txns.take(3).length} ${_strings.itemsVisible}',
            type: UmaSourceType.transaction,
          ),
        ];
      default:
        return const [];
    }
  }

  List<UmaSourceRef> _parseSources(
    Map<String, Object?> payload,
    AppStrings l10n,
  ) {
    final raw = payload['sources'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map(
          (source) => UmaSourceRef(
            label: source['label']?.toString() ?? l10n.umaSourceReadiness,
            detail: source['detail']?.toString() ?? '',
            type: UmaSourceType.memory,
          ),
        )
        .toList();
  }

  UmaNextStep? _parseNextStep(
    Map<String, Object?> payload,
    UserReadiness readiness,
    AppStrings l10n,
  ) {
    final raw = payload['next_step'];
    if (raw is Map) {
      return UmaNextStep(
        label: raw['label']?.toString() ?? l10n.umaInsightImportCta,
        type: UmaNextStepType.askUma,
        prompt: raw['prompt']?.toString(),
      );
    }
    return _defaultNextStep(readiness, l10n);
  }

  UmaNextStep _defaultNextStep(UserReadiness readiness, AppStrings l10n) {
    if (readiness.needsUserData) {
      return UmaNextStep(
        label: l10n.umaInsightImportCta,
        type: UmaNextStepType.importStatement,
      );
    }
    return UmaNextStep(
      label: l10n.umaInsightDeepenCta,
      type: UmaNextStepType.askUma,
      prompt: l10n.umaPromptAnalyze,
    );
  }

  UmaNextStep? _nextStepForIntent(
    UmaIntent intent,
    UserReadiness readiness,
    AppStrings l10n,
  ) {
    switch (intent.type) {
      case UmaIntentType.showSubscriptions:
        return UmaNextStep(
          label: l10n.proactivePriceCta,
          type: UmaNextStepType.openSubscriptions,
        );
      case UmaIntentType.explainSecurityAlert:
        return UmaNextStep(
          label: l10n.securityViewReport,
          type: UmaNextStepType.openSecurity,
        );
      case UmaIntentType.moveToSavings:
        return UmaNextStep(
          label: l10n.goalEmptyCta,
          type: UmaNextStepType.reviewGoal,
        );
      case _:
        return _defaultNextStep(readiness, l10n);
    }
  }

  double _inferConfidence(UserReadiness readiness, UmaMemoryProfile memory) {
    final memoryBonus =
        memory.helpfulFeedbackCount > memory.notHelpfulFeedbackCount ? 0.08 : 0;
    final base = readiness.dataDepth * 0.55 + readiness.sourceCoverage * 0.25;
    return (base + memoryBonus).clamp(0.2, 0.92).toDouble();
  }

  String _defaultWhy(UserReadiness readiness, AppStrings l10n) {
    if (readiness.needsUserData) return l10n.umaWhyInsufficientData;
    if (readiness.localOnly) return l10n.umaWhyLocalOnly;
    return l10n.umaWhyGroundedAnswer;
  }

  String _fallbackText(UserReadiness readiness, AppStrings l10n) {
    if (readiness.needsUserData) return l10n.umaReplyNeedsData;
    if (readiness.localOnly) return l10n.umaReplyLocalOnly;
    return _remoteConfig.umaFallbackMessage;
  }

  UmaMessage _reply({
    required UmaResponseEnvelope envelope,
    OrderCard? card,
    String? intent,
    UmaMessageKind kind = UmaMessageKind.assistant,
  }) {
    final message = UmaMessage(
      id: _messageId(),
      role: UmaRole.uma,
      text: envelope.text,
      card: card,
      createdAt: DateTime.now(),
      intent: intent,
      kind: kind,
      envelope: envelope,
    );
    appendAuditEvent(
      messageId: message.id,
      action: UmaAuditAction.replyGenerated,
      summary: envelope.text,
      intent: intent,
      metadata: {
        'hasCard': card != null,
        'confidence': envelope.confidence,
        'sourceCount': envelope.sources.length,
        if (envelope.pendingToolCall != null)
          'pendingTool': envelope.pendingToolCall!.name,
      },
    );
    return message;
  }

  UmaMessageKind _kindForEnvelope(UmaResponseEnvelope envelope) {
    return switch (envelope.kind) {
      UmaResponseKind.answer => UmaMessageKind.assistant,
      UmaResponseKind.proposal => UmaMessageKind.assistant,
      UmaResponseKind.toolSuccess => UmaMessageKind.toolSuccess,
      UmaResponseKind.toolFailure => UmaMessageKind.toolFailure,
      UmaResponseKind.fallback => UmaMessageKind.fallback,
    };
  }

  String _messageId() => 'uma-${DateTime.now().microsecondsSinceEpoch}';

  String _signatureFor({
    required String messageId,
    required UmaAuditAction action,
    required String summary,
    required DateTime timestamp,
    String? intent,
    String? note,
    Map<String, dynamic> metadata = const {},
  }) {
    final source = [
      messageId,
      action.name,
      summary,
      timestamp.toIso8601String(),
      intent ?? '',
      note ?? '',
      metadata.entries.map((entry) => '${entry.key}:${entry.value}').join('|'),
    ].join('::');
    final hash = Object.hashAll(source.codeUnits);
    return 'VERA-${hash.abs().toRadixString(16).toUpperCase()}';
  }
}

final umaRepositoryProvider = Provider<UmaRepository>((ref) {
  return UmaRepository(
    ref.watch(geminiServiceProvider),
    ref.watch(intentRouterProvider),
    ref.watch(firebaseUmaFeedbackStoreProvider),
    ref.watch(firebaseUmaAuditStoreProvider),
    ref.watch(firebaseUmaMemoryStoreProvider),
    ref.watch(remoteConfigServiceProvider),
    ref.watch(analyticsServiceProvider),
    ref,
  );
});
