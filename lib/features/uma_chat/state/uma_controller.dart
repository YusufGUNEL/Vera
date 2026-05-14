import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/state/balance_controller.dart';
import '../data/uma_repository.dart';
import '../domain/uma_message.dart';

enum AutoExecMode { auto, confirm }

class UmaState {
  const UmaState({
    this.messages = const [
      UmaMessage(
        role: UmaRole.uma,
        text:
            'Hi Mert. Gold is up 1.8% today. I can help you rebalance, pay a card bill, or move money into savings.',
      ),
    ],
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
  UmaController(this._repository, this._ref) : super(const UmaState());

  final UmaRepository _repository;
  final Ref _ref;

  Future<void> send(String text) async {
    if (text.trim().isEmpty || state.thinking) return;
    final userMsg = UmaMessage(role: UmaRole.user, text: text.trim());
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      thinking: true,
    );

    final reply = await _repository.handle(text);
    state = state.copyWith(
      messages: [...state.messages, reply],
      thinking: false,
    );
  }

  void confirmOrder(int messageIndex) {
    final msg = state.messages[messageIndex];
    final card = msg.card;
    if (card == null || card.status != OrderStatus.review) return;

    if (card.balanceDelta < 0) {
      _ref.read(balanceProvider.notifier).debit(card.balanceDelta.abs());
    } else if (card.balanceDelta > 0) {
      _ref.read(balanceProvider.notifier).credit(card.balanceDelta);
    }

    final updated =
        msg.copyWith(card: card.copyWith(status: OrderStatus.confirmed));
    final list = [...state.messages]..[messageIndex] = updated;
    state = state.copyWith(
      messages: list,
      toast: '${card.title} confirmed · ${card.amount.toStringAsFixed(0)} TL',
    );

    final newBalance = _ref.read(balanceProvider);
    Future.delayed(const Duration(milliseconds: 500), () {
      final confirm =
          _repository.actionConfirmation(card: card, newBalance: newBalance);
      state = state.copyWith(messages: [...state.messages, confirm]);
    });

    Future.delayed(const Duration(milliseconds: 2800), () {
      state = state.copyWith(clearToast: true);
    });
  }

  void cancelOrder(int messageIndex) {
    final msg = state.messages[messageIndex];
    final card = msg.card;
    if (card == null || card.status != OrderStatus.review) return;
    final updated =
        msg.copyWith(card: card.copyWith(status: OrderStatus.cancelled));
    final list = [...state.messages]..[messageIndex] = updated;
    state = state.copyWith(messages: list);
  }

  void setAutoExec(AutoExecMode mode) {
    state = state.copyWith(autoExec: mode);
  }
}

final umaControllerProvider =
    StateNotifierProvider<UmaController, UmaState>((ref) {
  return UmaController(ref.watch(umaRepositoryProvider), ref);
});
