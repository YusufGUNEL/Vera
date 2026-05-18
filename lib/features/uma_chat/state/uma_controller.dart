import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/localization/locale_controller.dart';
import '../../auth/state/auth_controller.dart';
import '../data/uma_repository.dart';
import '../domain/uma_message.dart';

class UmaState {
  const UmaState({
    this.messages = const [],
    this.thinking = false,
    this.toast,
  });

  final List<UmaMessage> messages;
  final bool thinking;
  final String? toast;

  UmaState copyWith({
    List<UmaMessage>? messages,
    bool? thinking,
    String? toast,
    bool clearToast = false,
  }) {
    return UmaState(
      messages: messages ?? this.messages,
      thinking: thinking ?? this.thinking,
      toast: clearToast ? null : (toast ?? this.toast),
    );
  }
}

class UmaController extends StateNotifier<UmaState> {
  UmaController(this._repository, String greeting)
      : super(
          UmaState(
            messages: [
              UmaMessage(
                id: _newId('uma'),
                role: UmaRole.uma,
                text: greeting,
                createdAt: DateTime.now(),
              ),
            ],
          ),
        );

  final UmaRepository _repository;

  Future<void> send(String text) async {
    if (text.trim().isEmpty || state.thinking) return;
    final userMsg = UmaMessage(
      id: _newId('user'),
      role: UmaRole.user,
      text: text.trim(),
      createdAt: DateTime.now(),
    );
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
    strings.umaGreeting(name),
  );
});
