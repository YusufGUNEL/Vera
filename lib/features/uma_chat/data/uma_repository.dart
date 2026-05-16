import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/analytics_service.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/utils/formatters.dart';
import '../../home/data/category_summary.dart';
import '../../home/state/goals_controller.dart';
import '../../home/state/home_controller.dart';
import '../../subscriptions/state/subscriptions_controller.dart';
import '../domain/uma_audit_event.dart';
import '../domain/uma_feedback.dart';
import '../domain/uma_intent.dart';
import '../domain/uma_message.dart';
import 'firebase_uma_audit_store.dart';
import 'firebase_uma_feedback_store.dart';
import 'intent_router.dart';

class UmaRepository {
  UmaRepository(
    this._gemini,
    this._router,
    this._feedbackStore,
    this._auditStore,
    this._analytics,
    this._ref,
  );

  final GeminiService _gemini;
  final IntentRouter _router;
  final FirebaseUmaFeedbackStore _feedbackStore;
  final FirebaseUmaAuditStore _auditStore;
  final AnalyticsService _analytics;
  final Ref _ref;

  AppStrings get _strings => AppStrings(_ref.read(localeControllerProvider));

  Future<UmaMessage> handle(String userText) async {
    final intent = _router.parse(userText);
    final l10n = _strings;

    switch (intent.type) {
      case UmaIntentType.buyGold:
        final banks = _ref.read(homeControllerProvider).banks;
        final primary = banks.isEmpty ? 'Garanti BBVA' : banks.first.name;
        final last4 = banks.isEmpty ? '****' : banks.first.last4;
        return _reply(
          intent: intent.type.name,
          text: l10n.umaReplyBuyGold(primary),
          card: OrderCard(
            type: UmaActionType.buyGold,
            title: l10n.orderTitleBuyGold,
            from: '${l10n.connectedAccounts} / $primary $last4',
            to: '$primary Gold',
            amount: 29840,
            bankApp: primary,
            detailLabel: l10n.orderTitleGoldRate,
            detailValue: 'TL 2.984/g',
          ),
        );
      case UmaIntentType.payCreditCard:
        final banks = _ref.read(homeControllerProvider).banks;
        final bank =
            banks.length > 1 ? banks[1] : (banks.isNotEmpty ? banks.first : null);
        final bankName = bank?.name ?? 'Akbank';
        return _reply(
          intent: intent.type.name,
          text: l10n.umaReplyPayCard(bankName),
          card: OrderCard(
            type: UmaActionType.payCreditCard,
            title: l10n.orderTitlePayCard,
            from:
                '${l10n.connectedAccounts} / $bankName ${bank?.last4 ?? '****'}',
            to: bankName,
            amount: 12450,
            bankApp: bankName,
            detailLabel: l10n.orderTitleDue,
            detailValue: l10n.orderTitleDueToday,
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
        final banks = _ref.read(homeControllerProvider).banks;
        final source = banks.isEmpty ? 'Yapi Kredi' : banks.first.name;
        final last4 = banks.isEmpty ? '****' : banks.first.last4;
        return _reply(
          intent: intent.type.name,
          text: l10n.umaReplyMoveSavings(after),
          card: OrderCard(
            type: UmaActionType.moveToSavings,
            title: l10n.goalEmergencyFund,
            from: '$source $last4',
            to: l10n.goalEmergencyFund,
            amount: moveAmount,
            bankApp: source,
            detailLabel: l10n.goalsSectionTitle,
            detailValue: '$after%',
          ),
        );
      case UmaIntentType.showSubscriptions:
        final subs = _ref.read(subscriptionsControllerProvider);
        if (subs.items.isEmpty) {
          return _reply(
            intent: intent.type.name,
            text: l10n.umaReplySubscriptionsEmpty(),
          );
        }
        return _reply(
          intent: intent.type.name,
          text: l10n.umaReplySubscriptions(
            subs.items.length,
            fmtTL(subs.monthlyTotal),
          ),
        );
      case UmaIntentType.analyzeSpending:
        final txns = _ref.read(homeControllerProvider).transactions;
        final spending =
            summarizeSpending(txns, otherLabel: l10n.categoryOther);
        if (spending.isEmpty) {
          return _reply(
            intent: intent.type.name,
            text: l10n.umaReplyAnalyzeEmpty(),
          );
        }
        final top = spending.first;
        final total = totalSpending(spending);
        return _reply(
          intent: intent.type.name,
          text: l10n.umaReplyAnalyze(
            top.category,
            fmtTL(top.amount),
            fmtTL(total),
          ),
        );
      case UmaIntentType.explainWealth:
        return _reply(intent: intent.type.name, text: l10n.umaReplyExplainWealth);
      case UmaIntentType.checkLoanEligibility:
        return _reply(intent: intent.type.name, text: l10n.umaReplyLoan);
      case UmaIntentType.explainSecurityAlert:
        return _reply(intent: intent.type.name, text: l10n.umaReplySecurity);
      case UmaIntentType.unknown:
        break;
    }

    try {
      final reply = await _gemini.generateText(await buildPrompt(userText));
      await _analytics.logUmaIntent(
        intent: intent.type.name,
        resolvedByGemini: true,
      );
      return _reply(intent: intent.type.name, text: reply.trim());
    } catch (_) {
      return _reply(intent: intent.type.name, text: l10n.umaReplyFallback);
    }
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

  Future<String> buildPrompt(String userText) async {
    final feedbackContext = await _feedbackStore.buildPromptContext();
    return '''
You are Uma, the AI coach inside Vera, a Turkish personal finance app.
Vera does NOT execute bank transactions itself. It analyzes the user's data
(imported statements, receipts, screenshots, manual entries) and forwards
real actions to the user's bank app for them to confirm.

Tone: warm, concise (1-3 sentences), helpful. Use TL when relevant.
Never invent specific transaction history or prices the user hasn't asked about.
Never claim Vera will move money. If the user wants an action, say you will
open the right bank app and that they'll confirm there.
${feedbackContext.isEmpty ? '' : '\n$feedbackContext\n'}

User: $userText
Uma:''';
  }

  UmaMessage _reply({
    required String text,
    OrderCard? card,
    String? intent,
  }) {
    final message = UmaMessage(
      id: _messageId(),
      role: UmaRole.uma,
      text: text,
      card: card,
      createdAt: DateTime.now(),
      intent: intent,
    );
    appendAuditEvent(
      messageId: message.id,
      action: UmaAuditAction.replyGenerated,
      summary: text,
      intent: intent,
      metadata: {
        'hasCard': card != null,
        if (card != null) 'bankApp': card.bankApp,
      },
    );
    return message;
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
    ref.watch(analyticsServiceProvider),
    ref,
  );
});
