import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/uma_audit_event.dart';

const _kUmaAuditKey = 'uma.audit.events';

class UmaAuditStore {
  const UmaAuditStore();

  Future<List<UmaAuditEvent>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUmaAuditKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      final items = decoded
          .whereType<Map<String, dynamic>>()
          .map(UmaAuditEvent.fromMap)
          .toList();
      items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return items;
    } catch (_) {
      return const [];
    }
  }

  Future<void> append(UmaAuditEvent event) async {
    final existing = await load();
    final merged = [event, ...existing].take(120).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kUmaAuditKey,
      jsonEncode(merged.map((item) => item.toMap()).toList()),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUmaAuditKey);
  }
}

final umaAuditStoreProvider = Provider<UmaAuditStore>((ref) {
  return const UmaAuditStore();
});
