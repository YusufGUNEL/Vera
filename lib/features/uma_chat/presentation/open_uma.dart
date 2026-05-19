import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'uma_chat_sheet.dart';

/// Opens the UMA chat sheet. When [prompt] is provided, the sheet resets the
/// conversation on open and then dispatches the prompt into the fresh thread.
void openUma(BuildContext context, WidgetRef ref, {String? prompt}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => UmaChatSheet(initialPrompt: prompt),
  );
}
