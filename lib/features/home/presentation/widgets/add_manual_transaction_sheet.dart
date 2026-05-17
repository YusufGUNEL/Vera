import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/services/ai_categorizer.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../data/imported_transactions_store.dart';
import '../../data/transaction.dart';
import '../../state/home_controller.dart';

/// Adds a single user-entered transaction (income or expense) to the imported
/// store. Used when there is no statement or receipt to import — e.g. cash
/// spending, a side income, or a one-off transfer.
class AddManualTransactionSheet extends ConsumerStatefulWidget {
  const AddManualTransactionSheet({super.key});

  @override
  ConsumerState<AddManualTransactionSheet> createState() =>
      _AddManualTransactionSheetState();
}

class _AddManualTransactionSheetState
    extends ConsumerState<AddManualTransactionSheet> {
  final _name = TextEditingController();
  final _amount = TextEditingController();
  String _category = 'Diğer';
  bool _isExpense = true;
  DateTime _date = DateTime.now();
  Timer? _aiDebounce;
  String? _aiSuggestion;
  bool _aiBusy = false;
  bool _userPickedCategory = false;

  static const _categories = <String>[
    'Market',
    'Yeme & İçme',
    'Akaryakıt',
    'Fatura',
    'Sağlık',
    'Eğitim',
    'Eğlence',
    'Transfer',
    'Maaş',
    'Abonelik',
    'Diğer',
  ];

  @override
  void initState() {
    super.initState();
    _name.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _aiDebounce?.cancel();
    _name.removeListener(_onNameChanged);
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    _aiDebounce?.cancel();
    final text = _name.text.trim();
    if (text.length < 2) {
      if (_aiSuggestion != null) {
        setState(() => _aiSuggestion = null);
      }
      return;
    }
    // Heuristic is synchronous and free — show it immediately.
    final categorizer = ref.read(aiCategorizerProvider);
    final guess = categorizer.heuristic(text);
    if (guess != 'Diğer') {
      setState(() => _aiSuggestion = guess);
    }
    // Then debounce a richer Gemini call for ambiguous names.
    _aiDebounce = Timer(const Duration(milliseconds: 700), _runAiCategorize);
  }

  Future<void> _runAiCategorize() async {
    final desc = _name.text.trim();
    if (desc.length < 2) return;
    final amountRaw = _amount.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(amountRaw);
    setState(() => _aiBusy = true);
    final result = await ref.read(aiCategorizerProvider).categorize(
          description: desc,
          amount: amount == null
              ? null
              : (_isExpense ? -amount.abs() : amount.abs()),
        );
    if (!mounted) return;
    setState(() {
      _aiBusy = false;
      _aiSuggestion = result;
    });
  }

  void _acceptAiSuggestion() {
    if (_aiSuggestion == null) return;
    setState(() {
      _category = _aiSuggestion!;
      _userPickedCategory = true;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final name = _name.text.trim();
    final raw = _amount.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(raw) ?? 0;
    if (name.isEmpty || amount <= 0) return;

    final palette = iconAndColorForCategory(_category);
    final txn = Txn(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      name: name,
      category: _category,
      icon: palette.icon,
      amount: _isExpense ? -amount : amount,
      when: _formatWhen(_date, l10n),
      color: palette.color,
    );
    await ref.read(homeControllerProvider.notifier).addImportedTransactions([txn]);
    if (mounted) Navigator.of(context).pop();
  }

  String _formatWhen(DateTime dt, AppStrings l10n) {
    final today = DateTime.now();
    if (dt.year == today.year &&
        dt.month == today.month &&
        dt.day == today.day) {
      return '${l10n.today}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
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
                  const SizedBox(height: 14),
                  Text(
                    l10n.addManualTxnTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: t.ink,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _Segment(
                          label: l10n.txnTypeExpense,
                          selected: _isExpense,
                          color: t.red,
                          onTap: () => setState(() => _isExpense = true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _Segment(
                          label: l10n.txnTypeIncome,
                          selected: !_isExpense,
                          color: t.green,
                          onTap: () => setState(() => _isExpense = false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _Label(label: l10n.fieldDescription),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _name,
                    style: TextStyle(fontSize: 14, color: t.ink),
                    decoration: _decoration(t, l10n.addManualTxnNameHint),
                  ),
                  const SizedBox(height: 12),
                  _Label(label: l10n.fieldAmountTl),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _amount,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    style: TextStyle(fontSize: 14, color: t.ink),
                    decoration: _decoration(t, '0'),
                  ),
                  const SizedBox(height: 12),
                  _Label(label: l10n.fieldDate),
                  const SizedBox(height: 6),
                  InkWell(
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
                          Icon(Icons.event_outlined, color: t.muted, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            '${_date.day.toString().padLeft(2, '0')}.${_date.month.toString().padLeft(2, '0')}.${_date.year}',
                            style: TextStyle(fontSize: 14, color: t.ink),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Label(label: l10n.fieldCategory),
                  const SizedBox(height: 6),
                  if (_aiSuggestion != null && !_userPickedCategory)
                    _AiSuggestionChip(
                      busy: _aiBusy,
                      suggestion: _aiSuggestion!,
                      onAccept: _acceptAiSuggestion,
                    ),
                  if (_aiSuggestion != null && !_userPickedCategory)
                    const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in _categories)
                        InkWell(
                          onTap: () => setState(() {
                            _category = c;
                            _userPickedCategory = true;
                          }),
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _category == c
                                  ? t.brand.withValues(alpha: 0.14)
                                  : t.card,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: _category == c ? t.brand : t.line,
                              ),
                            ),
                            child: Text(
                              _categoryLabel(c, l10n),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _category == c ? t.brand : t.ink2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
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

  InputDecoration _decoration(AppTokens t, String hint) {
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

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.14) : t.card,
          border: Border.all(color: selected ? color : t.line),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? color : t.ink2,
          ),
        ),
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

class _AiSuggestionChip extends StatelessWidget {
  const _AiSuggestionChip({
    required this.busy,
    required this.suggestion,
    required this.onAccept,
  });

  final bool busy;
  final String suggestion;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return InkWell(
      onTap: busy ? null : onAccept,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: t.umaSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: t.uma.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: t.uma,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: busy
                  ? SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.6,
                        color: t.brandFG,
                      ),
                    )
                  : const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 12,
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.aiSuggestionLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: t.uma,
                      letterSpacing: 0.4,
                    ),
                  ),
                  Text(
                    suggestion,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: t.ink,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: t.uma,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                context.l10n.acceptSuggestion,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _categoryLabel(String category, AppStrings l10n) {
  return switch (category) {
    'Market' => l10n.categoryMarket,
    'Yeme & İçme' => l10n.categoryFood,
    'Akaryakıt' => l10n.categoryFuel,
    'Fatura' => l10n.categoryBill,
    'Sağlık' => l10n.categoryHealth,
    'Eğitim' => l10n.categoryEducation,
    'Eğlence' => l10n.categoryEntertainment,
    'Transfer' => l10n.categoryTransfer,
    'Maaş' => l10n.categorySalary,
    'Abonelik' => l10n.categorySubscription,
    _ => l10n.categoryOther,
  };
}
