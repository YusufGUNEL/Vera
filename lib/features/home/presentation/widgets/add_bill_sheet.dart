import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../data/upcoming_bill.dart';
import '../../state/upcoming_bills_controller.dart';

/// Lets the user add (or edit) an upcoming bill: name, amount, due date,
/// and an icon/accent that the bill strip will render with.
class AddBillSheet extends ConsumerStatefulWidget {
  const AddBillSheet({this.initial, super.key});

  final UpcomingBill? initial;

  @override
  ConsumerState<AddBillSheet> createState() => _AddBillSheetState();
}

class _AddBillSheetState extends ConsumerState<AddBillSheet> {
  late final TextEditingController _name;
  late final TextEditingController _amount;
  late DateTime _dueDate;
  late _BillKind _kind;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _name = TextEditingController(text: initial?.name ?? '');
    _amount = TextEditingController(
      text: initial == null ? '' : initial.amount.round().toString(),
    );
    _dueDate =
        initial?.dueDate ?? DateTime.now().add(const Duration(days: 7));
    _kind = initial == null
        ? _BillKind.card
        : _BillKind.values.firstWhere(
            (k) => k.iconCode == initial.iconCode,
            orElse: () => _BillKind.card,
          );
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final amount = double.tryParse(_amount.text.trim().replaceAll(',', '.')) ?? 0;
    if (name.isEmpty || amount <= 0) return;
    final bill = UpcomingBill(
      id: widget.initial?.id ??
          'bill-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      amount: amount,
      dueDate: _dueDate,
      iconCode: _kind.iconCode,
      accentColor: _kind.color.toARGB32(),
    );
    if (widget.initial == null) {
      await ref.read(upcomingBillsControllerProvider.notifier).add(bill);
    } else {
      await ref.read(upcomingBillsControllerProvider.notifier).update(bill);
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final id = widget.initial?.id;
    if (id == null) return;
    await ref.read(upcomingBillsControllerProvider.notifier).remove(id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final mq = MediaQuery.of(context);
    final isEdit = widget.initial != null;

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
                const SizedBox(height: 16),
                Text(
                  isEdit ? l10n.editBillTitle : l10n.addBillTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: t.ink,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 14),
                _Field(
                  label: l10n.fieldName,
                  child: TextField(
                    controller: _name,
                    style: TextStyle(fontSize: 14, color: t.ink),
                    decoration: _inputDecoration(t, hint: l10n.addBillNameHint),
                  ),
                ),
                const SizedBox(height: 12),
                _Field(
                  label: l10n.fieldAmountTl,
                  child: TextField(
                    controller: _amount,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    style: TextStyle(fontSize: 14, color: t.ink),
                    decoration: _inputDecoration(t, hint: '0'),
                  ),
                ),
                const SizedBox(height: 12),
                _Field(
                  label: l10n.dueDateLabel,
                  child: InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: t.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: t.line),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.event_outlined,
                              color: t.muted, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            '${_dueDate.day.toString().padLeft(2, '0')}.${_dueDate.month.toString().padLeft(2, '0')}.${_dueDate.year}',
                            style: TextStyle(fontSize: 14, color: t.ink),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _Field(
                  label: l10n.fieldCategory,
                  child: SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _BillKind.values.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final kind = _BillKind.values[i];
                        final selected = kind == _kind;
                        return InkWell(
                          onTap: () => setState(() => _kind = kind),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? kind.color.withValues(alpha: 0.18)
                                  : t.card,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected ? kind.color : t.line,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(IconData(kind.iconCode,
                                        fontFamily: 'MaterialIcons'),
                                    size: 16, color: kind.color),
                                const SizedBox(width: 6),
                                Text(
                                  kind.label(l10n),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: selected ? kind.color : t.ink2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    if (isEdit) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _delete,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: t.red,
                            side: BorderSide(
                                color: t.red.withValues(alpha: 0.35)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(l10n.actionDelete),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: FilledButton(
                        onPressed: _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: t.brand,
                          foregroundColor: t.brandFG,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          isEdit ? l10n.actionUpdate : l10n.actionAdd,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(AppTokens t, {String? hint}) {
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

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: t.muted,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

enum _BillKind {
  card(iconCode: 0xe19f, color: Color(0xFFE63E5C)),
  internet(iconCode: 0xe63e, color: Color(0xFF1E88E5)),
  electric(iconCode: 0xe1b8, color: Color(0xFFFFA000)),
  water(iconCode: 0xe798, color: Color(0xFF26A69A)),
  gas(iconCode: 0xe546, color: Color(0xFFEF6C00)),
  rent(iconCode: 0xe88a, color: Color(0xFF8E44AD)),
  other(iconCode: 0xe9b9, color: Color(0xFF607D8B));

  const _BillKind({
    required this.iconCode,
    required this.color,
  });

  final int iconCode;
  final Color color;

  String label(AppStrings l10n) {
    return switch (this) {
      _BillKind.card => l10n.billKindCard,
      _BillKind.internet => l10n.billKindInternet,
      _BillKind.electric => l10n.billKindElectric,
      _BillKind.water => l10n.billKindWater,
      _BillKind.gas => l10n.billKindGas,
      _BillKind.rent => l10n.billKindRent,
      _BillKind.other => l10n.billKindOther,
    };
  }
}
