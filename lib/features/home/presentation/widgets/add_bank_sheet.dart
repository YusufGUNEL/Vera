import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../data/bank.dart';
import '../../state/home_controller.dart';

const _kSwatches = <Color>[
  Color(0xFF1B5E20),
  Color(0xFFB71C1C),
  Color(0xFF0D47A1),
  Color(0xFF3E2723),
  Color(0xFF7C3AED),
  Color(0xFF00897B),
  Color(0xFFD84315),
  Color(0xFF5D4037),
];

class AddBankSheet extends ConsumerStatefulWidget {
  const AddBankSheet({super.key});

  @override
  ConsumerState<AddBankSheet> createState() => _AddBankSheetState();
}

class _AddBankSheetState extends ConsumerState<AddBankSheet> {
  final _nameCtrl = TextEditingController();
  final _last4Ctrl = TextEditingController();
  final _balanceCtrl = TextEditingController();
  Color _color = _kSwatches.first;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _last4Ctrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  String _shortCodeFor(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'BK';
    final words = trimmed.split(RegExp(r'\s+'));
    if (words.length == 1) {
      return trimmed.substring(0, trimmed.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = l10n.addBankNameRequired);
      return;
    }
    final balance = double.tryParse(
      _balanceCtrl.text.trim().replaceAll(',', '.'),
    ) ?? 0;
    final last4Digits = _last4Ctrl.text.trim();
    final last4 = last4Digits.isEmpty ? '••••' : '••${last4Digits.padLeft(4, '0').substring(0, 4)}';

    setState(() {
      _busy = true;
      _error = null;
    });

    final bank = Bank(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      shortCode: _shortCodeFor(name),
      balance: balance,
      color: _color,
      last4: last4,
    );

    await ref.read(homeControllerProvider.notifier).addBank(bank);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.bankAdded(name)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final mq = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: t.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: t.line,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.addBankTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: t.ink,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.addBankSubtitle,
                    style: TextStyle(fontSize: 12, color: t.muted, height: 1.4),
                  ),
                  const SizedBox(height: 18),
                  _Field(
                    label: l10n.addBankName,
                    controller: _nameCtrl,
                    hint: 'Akbank',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          label: l10n.addBankLast4,
                          controller: _last4Ctrl,
                          hint: '1209',
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Field(
                          label: l10n.addBankBalance,
                          controller: _balanceCtrl,
                          hint: '0',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.addBankColor,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: t.muted,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final c in _kSwatches)
                        GestureDetector(
                          onTap: () => setState(() => _color = c),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _color == c ? t.ink : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: TextStyle(color: t.red, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: _busy ? null : _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: t.brand,
                        foregroundColor: t.brandFG,
                      ),
                      child: _busy
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: t.brandFG,
                              ),
                            )
                          : Text(
                              l10n.addBankSave,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.maxLength,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: t.muted,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          inputFormatters: keyboardType == TextInputType.number
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          style: TextStyle(fontSize: 14, color: t.ink),
          decoration: InputDecoration(
            counterText: '',
            hintText: hint,
            hintStyle: TextStyle(color: t.muted, fontSize: 14),
            filled: true,
            fillColor: t.card,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: t.line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: t.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: t.brand, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}
