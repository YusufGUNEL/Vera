import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

class ToggleSwitch extends StatelessWidget {
  const ToggleSwitch({
    required this.on,
    required this.onChanged,
    super.key,
  });

  final bool on;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      onTap: () => onChanged(!on),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 26,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: on ? t.uma : (t.isDark ? t.line : const Color(0xFFD9D4C8)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Color(0x26000000), blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
