import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/state/auth_controller.dart';
import 'firebase_upcoming_bills_service.dart';
import 'upcoming_bill.dart';

const _kBillsKey = 'home.upcoming.bills';

/// Local + Firestore persistence for the user-managed list of upcoming bills.
class UpcomingBillsStore {
  const UpcomingBillsStore(this._firebaseService);

  final FirebaseUpcomingBillsService _firebaseService;

  Future<List<UpcomingBill>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kBillsKey);
    final local = _decode(raw);

    if (!_firebaseService.isEnabled) return local;

    final remote = await _firebaseService.load();
    if (remote.isEmpty) return local;
    await _saveLocal(remote);
    return remote;
  }

  Future<List<UpcomingBill>> add(UpcomingBill bill) async {
    final existing = await load();
    final merged = [...existing, bill]..sort(
        (a, b) => a.dueDate.compareTo(b.dueDate),
      );
    await _saveLocal(merged);
    if (_firebaseService.isEnabled) {
      await _firebaseService.saveAll(merged);
    }
    return merged;
  }

  Future<List<UpcomingBill>> update(UpcomingBill bill) async {
    final existing = await load();
    final updated = [
      for (final b in existing)
        if (b.id == bill.id) bill else b,
    ]..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    await _saveLocal(updated);
    if (_firebaseService.isEnabled) {
      await _firebaseService.saveAll(updated);
    }
    return updated;
  }

  Future<List<UpcomingBill>> remove(String id) async {
    final existing = await load();
    final filtered = existing.where((b) => b.id != id).toList();
    await _saveLocal(filtered);
    if (_firebaseService.isEnabled) {
      await _firebaseService.saveAll(filtered);
    }
    return filtered;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kBillsKey);
    if (_firebaseService.isEnabled) {
      await _firebaseService.saveAll(const []);
    }
  }

  List<UpcomingBill> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(UpcomingBill.fromMap)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _saveLocal(List<UpcomingBill> bills) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kBillsKey,
      jsonEncode(bills.map((b) => b.toMap()).toList()),
    );
  }
}

final upcomingBillsStoreProvider = Provider<UpcomingBillsStore>((ref) {
  ref.watch(authControllerProvider);
  return UpcomingBillsStore(ref.watch(firebaseUpcomingBillsServiceProvider));
});
