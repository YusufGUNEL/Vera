import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/state/auth_controller.dart';
import 'bank.dart';
import 'firebase_banks_service.dart';

const _kCustomBanksKey = 'home.custom.banks';

class BanksStore {
  const BanksStore(this._firebaseService);

  final FirebaseBanksService _firebaseService;

  Future<List<Bank>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kCustomBanksKey);
    final local = _decode(raw);

    if (!_firebaseService.isEnabled) return local;

    final remote = await _firebaseService.load();
    if (remote.isEmpty) return local;
    await _saveLocal(remote);
    return remote;
  }

  Future<List<Bank>> add(Bank bank) async {
    final existing = await load();
    final merged = [...existing, bank];
    await _saveLocal(merged);
    if (_firebaseService.isEnabled) {
      await _firebaseService.saveAll(merged);
    }
    return merged;
  }

  Future<List<Bank>> remove(String id) async {
    final existing = await load();
    final filtered = existing.where((b) => b.id != id).toList();
    await _saveLocal(filtered);
    if (_firebaseService.isEnabled) {
      await _firebaseService.saveAll(filtered);
    }
    return filtered;
  }

  Future<void> clear() async {
    await _saveLocal(const []);
    if (_firebaseService.isEnabled) {
      await _firebaseService.saveAll(const []);
    }
  }

  List<Bank> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Bank.fromMap)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _saveLocal(List<Bank> banks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kCustomBanksKey,
      jsonEncode(banks.map((b) => b.toMap()).toList()),
    );
  }
}

final banksStoreProvider = Provider<BanksStore>((ref) {
  ref.watch(authControllerProvider);
  return BanksStore(ref.watch(firebaseBanksServiceProvider));
});
