import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/localization/app_strings.dart';
import '../../auth/state/auth_controller.dart';
import '../../receipt_scan/domain/parsed_receipt.dart';
import '../../statement_import/domain/parsed_statement.dart';
import 'firebase_imported_transactions_service.dart';
import 'transaction.dart';

const _kImportedTxnsKey = 'home.imported.txns';

/// Persistent store for user-imported transactions (from OCR receipts and
/// statement imports). Lives in SharedPreferences so it survives restarts.
///
/// HomeController merges this list with bank/transaction data loaded from the
/// user's own sources; imports always appear at the top of the transaction
/// list, in newest-first order.
class ImportedTransactionsStore {
  const ImportedTransactionsStore(this._firebaseService);

  final FirebaseImportedTransactionsService _firebaseService;

  Future<List<Txn>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kImportedTxnsKey);
    final local = _decode(raw);

    if (!_firebaseService.isEnabled) return local;

    final remote = await _firebaseService.load();
    if (remote.isEmpty) return local;
    await _saveLocal(remote);
    return remote;
  }

  Future<void> save(List<Txn> txns) async {
    await _saveLocal(txns);
    if (_firebaseService.isEnabled) {
      await _firebaseService.saveAll(txns);
    }
  }

  Future<List<Txn>> append(List<Txn> newTxns) async {
    final existing = await load();
    final merged = [...newTxns, ...existing];
    await save(merged);
    return merged;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kImportedTxnsKey);
    if (_firebaseService.isEnabled) {
      await _firebaseService.saveAll(const []);
    }
  }

  List<Txn> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Txn.fromMap)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _saveLocal(List<Txn> txns) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(txns.map((t) => t.toMap()).toList());
    await prefs.setString(_kImportedTxnsKey, encoded);
  }
}

final importedTransactionsStoreProvider =
    Provider<ImportedTransactionsStore>((ref) {
  ref.watch(authControllerProvider);
  return ImportedTransactionsStore(
    ref.watch(firebaseImportedTransactionsServiceProvider),
  );
});

/// Maps a category code (whatever Gemini returned or what the user picked) to
/// (icon, color) for the transaction tile.
({IconData icon, Color color}) iconAndColorForCategory(String? raw) {
  final cat = (raw ?? '').toLowerCase().trim();
  if (cat.contains('market')) {
    return (icon: Icons.shopping_cart_outlined, color: const Color(0xFFE67E22));
  }
  if (cat.contains('yemek') || cat.contains('food') || cat.contains('dining')) {
    return (icon: Icons.local_cafe_outlined, color: const Color(0xFF8E5A3C));
  }
  if (cat.contains('akaryak') || cat.contains('fuel')) {
    return (icon: Icons.local_gas_station_outlined,
        color: const Color(0xFF34495E));
  }
  if (cat.contains('fatura') || cat.contains('bill')) {
    return (icon: Icons.receipt_long_outlined, color: const Color(0xFF8E44AD));
  }
  if (cat.contains('saglik') ||
      cat.contains('sağlık') ||
      cat.contains('health')) {
    return (icon: Icons.local_hospital_outlined, color: const Color(0xFFC03A2B));
  }
  if (cat.contains('egitim') ||
      cat.contains('eğitim') ||
      cat.contains('education')) {
    return (icon: Icons.school_outlined, color: const Color(0xFF2980B9));
  }
  if (cat.contains('eglence') ||
      cat.contains('eğlence') ||
      cat.contains('fun')) {
    return (icon: Icons.movie_outlined, color: const Color(0xFFC03A2B));
  }
  if (cat.contains('banka') ||
      cat.contains('eft') ||
      cat.contains('transfer')) {
    return (icon: Icons.send_outlined, color: const Color(0xFF2D5FB0));
  }
  if (cat.contains('maas') || cat.contains('maaş') || cat.contains('salary')) {
    return (icon: Icons.work_outline, color: const Color(0xFF2F8B5C));
  }
  if (cat.contains('abonelik') || cat.contains('subscription')) {
    return (icon: Icons.subscriptions_outlined, color: const Color(0xFFC03A2B));
  }
  return (icon: Icons.payments_outlined, color: const Color(0xFF7F8C8D));
}

String _todayLabel(AppStrings l10n) {
  final now = DateTime.now();
  final time =
      '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  return l10n.todayAt(time);
}

int _nextId() {
  return DateTime.now().millisecondsSinceEpoch ~/ 1000;
}

extension ParsedReceiptToTxn on ParsedReceipt {
  /// Builds a single transaction from the parsed receipt. Uses `total` when
  /// present, otherwise sums the line items. Returns null if neither yields
  /// a positive amount.
  Txn? toTxn(AppStrings l10n) {
    final raw = total ?? lines.fold<double>(0, (s, l) => s + l.amount);
    if (raw <= 0) return null;
    final palette = iconAndColorForCategory(category);
    return Txn(
      id: _nextId(),
      name: merchant ?? (category ?? l10n.receiptDefaultName),
      category: category ?? l10n.categoryOther,
      icon: palette.icon,
      amount: -raw,
      when: date ?? _todayLabel(l10n),
      color: palette.color,
    );
  }
}

extension ParsedStatementToTxns on ParsedStatement {
  /// Builds one Txn per statement transaction, preserving sign (incoming /
  /// outgoing) and category.
  List<Txn> toTxns(AppStrings l10n) {
    final out = <Txn>[];
    final baseId = _nextId();
    for (var i = 0; i < transactions.length; i++) {
      final src = transactions[i];
      final palette = iconAndColorForCategory(src.category);
      out.add(
        Txn(
          id: baseId + i,
          name: src.description,
          category: src.category ?? l10n.categoryOther,
          icon: palette.icon,
          amount: src.amount,
          when: src.date,
          color: palette.color,
        ),
      );
    }
    return out;
  }
}
