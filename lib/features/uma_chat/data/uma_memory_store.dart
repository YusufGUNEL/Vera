import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/uma_memory.dart';

const _kUmaMemoryProfileKey = 'uma.memory.profile';
const _kUmaConversationSummaryKey = 'uma.memory.summary';

class UmaMemoryStore {
  const UmaMemoryStore();

  Future<UmaMemoryProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUmaMemoryProfileKey);
    if (raw == null || raw.isEmpty) return UmaMemoryProfile.empty;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return UmaMemoryProfile.empty;
      return UmaMemoryProfile.fromMap(decoded);
    } catch (_) {
      return UmaMemoryProfile.empty;
    }
  }

  Future<void> saveProfile(UmaMemoryProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUmaMemoryProfileKey, jsonEncode(profile.toMap()));
  }

  Future<UmaConversationSummary> loadConversationSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUmaConversationSummaryKey);
    if (raw == null || raw.isEmpty) return UmaConversationSummary.empty;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return UmaConversationSummary.empty;
      return UmaConversationSummary.fromMap(decoded);
    } catch (_) {
      return UmaConversationSummary.empty;
    }
  }

  Future<void> saveConversationSummary(UmaConversationSummary summary) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kUmaConversationSummaryKey,
      jsonEncode(summary.toMap()),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUmaMemoryProfileKey);
    await prefs.remove(_kUmaConversationSummaryKey);
  }
}

final umaMemoryStoreProvider = Provider<UmaMemoryStore>((ref) {
  return const UmaMemoryStore();
});
