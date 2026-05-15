import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/uma_repository.dart';
import '../domain/uma_message.dart';

enum AutoExecMode { auto, confirm }

class UmaState {
  const UmaState({
    this.messages = const [
      UmaMessage(
        role: UmaRole.uma,
        text:
            'Hi Mert. I read your latest statement — your monthly spend is 14% below last month. I can help you pay a card bill, plan a transfer, or look at gold pricing. The action happens in your bank app; I prepare it and track the result.',
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
  UmaController(this._repository) : super(const UmaState());

  final UmaRepository _repository;

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

  /// Order'i kullanicinin kendi bankasina yonlendirildi olarak isaretler.
  /// Vera burada para hareketi yapmaz - sadece kullaniciyi banka uygulamasina
  /// yonlendirdigimizi kayda alir.
  void forwardOrder(int messageIndex) {
    final msg = state.messages[messageIndex];
    final card = msg.card;
    if (card == null || card.status != OrderStatus.review) return;

    final updated = msg.copyWith(card: card.copyWith(status: OrderStatus.forwarded));
    final list = [...state.messages]..[messageIndex] = updated;
    state = state.copyWith(
      messages: list,
      toast: '${card.title} · ${card.bankApp}',
    );

    Future.delayed(const Duration(milliseconds: 2800), () {
      state = state.copyWith(clearToast: true);
    });
  }

  void dismissOrder(int messageIndex) {
    final msg = state.messages[messageIndex];
    final card = msg.card;
    if (card == null || card.status != OrderStatus.review) return;
    final updated =
        msg.copyWith(card: card.copyWith(status: OrderStatus.dismissed));
    final list = [...state.messages]..[messageIndex] = updated;
    state = state.copyWith(messages: list);
  }

  void setAutoExec(AutoExecMode mode) {
    state = state.copyWith(autoExec: mode);
  }
}

final umaControllerProvider =
    StateNotifierProvider<UmaController, UmaState>((ref) {
  return UmaController(ref.watch(umaRepositoryProvider));
});
