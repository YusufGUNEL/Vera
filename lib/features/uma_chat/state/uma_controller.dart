import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/localization/locale_controller.dart';
import '../../auth/state/auth_controller.dart';
import '../domain/uma_audit_event.dart';
import '../data/uma_repository.dart';
import '../domain/uma_feedback.dart';
import '../domain/uma_message.dart';
import '../domain/uma_response.dart';

enum AutoExecMode { auto, confirm }

class UmaState {
  const UmaState({
    this.messages = const [],
    this.thinking = false,
    this.autoExec = AutoExecMode.confirm,
    this.toast,
  });

  final List<UmaMessage> messages;
  final bool thinking;
  final AutoExecMode autoExec;
  final String? toast;

  UmaState copyWith({
    List<UmaMessage>? messages,
    bool? thinking,
    AutoExecMode? autoExec,
    String? toast,
    bool clearToast = false,
  }) {
    return UmaState(
      messages: messages ?? this.messages,
      thinking: thinking ?? this.thinking,
      autoExec: autoExec ?? this.autoExec,
      toast: clearToast ? null : (toast ?? this.toast),
    );
  }
}

class UmaController extends StateNotifier<UmaState> {
  UmaController(this._repository, this._strings, String greeting)
      : _greeting = greeting,
        super(
          UmaState(
            messages: [
              UmaMessage(
                id: _newId('uma'),
                role: UmaRole.uma,
                text: greeting,
                createdAt: DateTime.now(),
                kind: UmaMessageKind.system,
              ),
            ],
          ),
        );

  final UmaRepository _repository;
  final AppStrings _strings;
  final String _greeting;

  Future<void> send(String text) async {
    if (text.trim().isEmpty || state.thinking) return;
    final userMsg = UmaMessage(
      id: _newId('user'),
      role: UmaRole.user,
      text: text.trim(),
      createdAt: DateTime.now(),
      kind: UmaMessageKind.user,
    );
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      thinking: true,
    );

    final reply = await _repository.handle(
      text,
      requireConfirmation: state.autoExec == AutoExecMode.confirm,
    );
    state = state.copyWith(
      messages: [...state.messages, reply],
      thinking: false,
    );
  }

  Future<void> confirmPendingTool(int messageIndex) async {
    final msg = state.messages[messageIndex];
    final pending = msg.envelope?.pendingToolCall;
    if (pending == null || state.thinking) return;
    state = state.copyWith(thinking: true);
    final reply = await _repository.confirmPendingToolCall(
      pending,
      messageId: msg.id,
      intent: msg.intent,
    );
    final cleared = msg.copyWith(
      envelope: UmaResponseEnvelope(
        kind: UmaResponseKind.proposal,
        text: msg.text,
        confidence: msg.envelope?.confidence ?? 0.88,
        why: msg.envelope?.why,
        sources: msg.envelope?.sources ?? const [],
        nextStep: msg.envelope?.nextStep,
        toolPolicy: msg.envelope?.toolPolicy,
        toolOutcome: msg.envelope?.toolOutcome,
      ),
    );
    final list = [...state.messages]..[messageIndex] = cleared;
    state = state.copyWith(
      messages: [...list, reply],
      thinking: false,
      toast: _strings.umaActionConfirmedToast,
    );
    _clearToastLater();
  }

  void forwardOrder(int messageIndex) {
    final msg = state.messages[messageIndex];
    final card = msg.card;
    if (card == null || card.status != OrderStatus.review) return;

    final updated = msg.copyWith(
      card: card.copyWith(status: OrderStatus.forwarded),
    );
    final list = [...state.messages]..[messageIndex] = updated;
    state = state.copyWith(
      messages: list,
      toast: '${card.title} / ${card.bankApp}',
    );
    _repository.appendAuditEvent(
      messageId: msg.id,
      action: UmaAuditAction.orderForwarded,
      summary: card.title,
      intent: msg.intent,
      metadata: {
        'bankApp': card.bankApp,
        'amount': card.amount,
      },
    );
    _clearToastLater();
  }

  void dismissOrder(int messageIndex) {
    final msg = state.messages[messageIndex];
    final card = msg.card;
    if (card == null || card.status != OrderStatus.review) return;
    final updated = msg.copyWith(
      card: card.copyWith(status: OrderStatus.dismissed),
    );
    final list = [...state.messages]..[messageIndex] = updated;
    state = state.copyWith(messages: list);
    _repository.appendAuditEvent(
      messageId: msg.id,
      action: UmaAuditAction.orderDismissed,
      summary: card.title,
      intent: msg.intent,
      metadata: {
        'bankApp': card.bankApp,
        'amount': card.amount,
      },
    );
  }

  Future<void> setFeedback(
    int messageIndex,
    UmaFeedbackVote vote, {
    String? note,
  }) async {
    final msg = state.messages[messageIndex];
    if (msg.role != UmaRole.uma) return;

    final entry = UmaFeedbackEntry(
      messageId: msg.id,
      vote: vote,
      responseText: msg.text,
      createdAt: DateTime.now(),
      note: note == null
          ? msg.feedback?.note
          : (note.trim().isEmpty ? null : note.trim()),
    );

    final updated = msg.copyWith(feedback: entry);
    final list = [...state.messages]..[messageIndex] = updated;
    state = state.copyWith(
      messages: list,
      toast: note == null || note.trim().isEmpty
          ? _strings.umaFeedbackSaved
          : _strings.umaFeedbackSavedWithNote,
    );
    await _repository.saveFeedback(
      messageId: msg.id,
      responseText: msg.text,
      vote: vote,
      note: entry.note,
    );
    await _repository.rememberFeedback(vote: vote, note: entry.note);
    await _repository.appendAuditEvent(
      messageId: msg.id,
      action: vote == UmaFeedbackVote.helpful
          ? UmaAuditAction.feedbackHelpful
          : UmaAuditAction.feedbackNotHelpful,
      summary: msg.text,
      intent: msg.intent,
      note: entry.note,
      metadata: {
        'vote': vote.name,
      },
    );
    _clearToastLater();
  }

  void setAutoExec(AutoExecMode mode) {
    state = state.copyWith(autoExec: mode);
  }

  void resetConversation() {
    state = UmaState(
      autoExec: state.autoExec,
      messages: [
        UmaMessage(
          id: _newId('uma'),
          role: UmaRole.uma,
          text: _greeting,
          createdAt: DateTime.now(),
          kind: UmaMessageKind.system,
        ),
      ],
    );
  }

  void _clearToastLater() {
    Future.delayed(const Duration(milliseconds: 2800), () {
      state = state.copyWith(clearToast: true);
    });
  }

  static String _newId(String role) {
    return '$role-${DateTime.now().microsecondsSinceEpoch}';
  }
}

final umaControllerProvider =
    StateNotifierProvider<UmaController, UmaState>((ref) {
  final auth = ref.read(authControllerProvider);
  final locale = ref.read(localeControllerProvider);
  final strings = AppStrings(locale);
  final name = auth.displayName?.trim().split(' ').first ??
      strings.defaultUserName.split(' ').first;
  return UmaController(
    ref.watch(umaRepositoryProvider),
    strings,
    strings.umaGreeting(name),
  );
});
