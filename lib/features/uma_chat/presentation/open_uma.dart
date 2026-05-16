import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/uma_controller.dart';
import 'uma_chat_sheet.dart';

/// Opens the UMA chat sheet. When [prompt] is provided, sends it through the
/// controller immediately so the sheet shows the user message and Uma's reply
/// without an extra interaction.
void openUma(BuildContext context, WidgetRef ref, {String? prompt}) {
  if (prompt != null && prompt.trim().isNotEmpty) {
    ref.read(umaControllerProvider.notifier).send(prompt);
  }
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => const UmaChatSheet(),
  );
}
