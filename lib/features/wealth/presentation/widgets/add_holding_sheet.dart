import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../state/wealth_controller.dart';

/// Bottom sheet for adding a manual portfolio holding. The user picks a
/// bucket (equity/gold/cash/crypto/funds), labels it (e.g. "THYAO"), and
/// enters the TL value. WealthController re-computes weights.
class AddHoldingSheet extends ConsumerStatefulWidget {
  const AddHoldingSheet({super.key});

  @override
  ConsumerState<AddHoldingSheet> createState() => _AddHoldingSheetState();
}

class _AddHoldingSheetState extends ConsumerState<AddHoldingSheet> {
  final _label = TextEditingController();
  final _amount = TextEditingController();
  _HoldingBucket _bucket = _HoldingBucket.equity;

  @override
  void dispose() {
    _label.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final label = _label.text.trim().isEmpty
        ? _bucket.label(context.l10n)
        : _label.text.trim();
    final raw = _amount.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(raw) ?? 0;
    if (amount <= 0) return;

    await ref.read(wealthControllerProvider.notifier).addAllocation(
          label: label,
          amount: amount,
          paletteKey: _bucket.paletteKey,
        );
    if (mounted) Navigator.of(context).pop();
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_rounded, color: t.muted),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: l10n.actionBack,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          l10n.addHoldingTitle,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: t.ink,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.addHoldingSubtitle,
                    style: TextStyle(fontSize: 12, color: t.muted, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final b in _HoldingBucket.values)
                        InkWell(
                          onTap: () => setState(() => _bucket = b),
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _bucket == b
                                  ? t.brand.withValues(alpha: 0.14)
                                  : t.card,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: _bucket == b ? t.brand : t.line,
                              ),
                            ),
                            child: Text(
                              b.label(l10n),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _bucket == b ? t.brand : t.ink2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _Label(label: l10n.fieldLabelOptional),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _label,
                    style: TextStyle(fontSize: 14, color: t.ink),
                    decoration: _deco(t, l10n.addHoldingHint),
                  ),
                  const SizedBox(height: 12),
                  _Label(label: l10n.holdingValueLabel),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _amount,
                    autofocus: true,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    style: TextStyle(fontSize: 14, color: t.ink),
                    decoration: _deco(t, '0'),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: t.brand,
                        foregroundColor: t.brandFG,
                      ),
                      child: Text(
                        l10n.actionAdd,
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

  InputDecoration _deco(AppTokens t, String hint) {
    return InputDecoration(
      filled: true,
      fillColor: t.card,
      hintText: hint,
      hintStyle: TextStyle(color: t.muted),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: t.muted,
      ),
    );
  }
}

enum _HoldingBucket {
  equity(paletteKey: 'brand'),
  gold(paletteKey: 'gold'),
  cash(paletteKey: 'blueSoft'),
  crypto(paletteKey: 'uma'),
  funds(paletteKey: 'green'),
  bonds(paletteKey: 'blue');

  const _HoldingBucket({required this.paletteKey});
  final String paletteKey;

  String label(AppStrings l10n) {
    return switch (this) {
      _HoldingBucket.equity => l10n.holdingBucketEquity,
      _HoldingBucket.gold => l10n.holdingBucketGold,
      _HoldingBucket.cash => l10n.holdingBucketCash,
      _HoldingBucket.crypto => l10n.holdingBucketCrypto,
      _HoldingBucket.funds => l10n.holdingBucketFunds,
      _HoldingBucket.bonds => l10n.holdingBucketBonds,
    };
  }
}
