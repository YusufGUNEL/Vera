import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';

class AuthField extends StatelessWidget {
  const AuthField({
    required this.label,
    required this.controller,
    this.hintText,
    this.keyboardType,
    this.obscure = false,
    this.prefixIcon,
    this.suffix,
    this.autofillHints,
    this.textInputAction,
    this.onSubmitted,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscure;
  final IconData? prefixIcon;
  final Widget? suffix;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final radius = BorderRadius.circular(14);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: t.ink,
          ),
        ),
        const SizedBox(height: 8),
        DefaultSelectionStyle(
          cursorColor: t.uma,
          selectionColor: t.uma.withValues(alpha: 0.30),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            autofillHints: autofillHints,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted,
            enableSuggestions: !obscure,
            autocorrect: !obscure && keyboardType != TextInputType.emailAddress,
            cursorColor: t.uma,
            cursorWidth: 2,
            style: TextStyle(
              fontSize: 16,
              color: t.ink,
              fontWeight: FontWeight.w500,
              height: 1.25,
              decoration: TextDecoration.none,
            ),
            decoration: InputDecoration(
              isDense: false,
              filled: true,
              fillColor: t.card,
              hintText: hintText,
              hintStyle: TextStyle(color: t.muted, fontSize: 14),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, size: 19, color: t.muted)
                  : null,
              suffixIcon: suffix,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: radius,
                borderSide: BorderSide(color: t.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: radius,
                borderSide: BorderSide(color: t.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: radius,
                borderSide: BorderSide(color: t.uma, width: 1.4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
