import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../domain/uma_message.dart';

class UmaMessageBubble extends StatelessWidget {
  const UmaMessageBubble({required this.message, super.key});

  final UmaMessage message;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final isMe = message.role == UmaRole.user;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isMe ? t.brand : t.card,
            border: isMe ? null : Border.all(color: t.line),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMe ? 18 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 18),
            ),
          ),
          child: SelectableText(
            message.text,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              letterSpacing: -0.1,
              color: isMe ? t.brandFG : t.ink,
            ),
          ),
        ),
      ),
    );
  }
}
