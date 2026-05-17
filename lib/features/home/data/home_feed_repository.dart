import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/env.dart';
import '../domain/home_feed_data.dart';

const _kHomeFeedCacheKey = 'home.feed.cache';

/// Loads the home feed (banks + transactions + insight) for the user.
///
/// The app does not have AISP licensing, so we never fabricate bank data.
/// Sources, in order:
///   1) An optional remote endpoint (HOME_FEED_URL) — useful for users who
///      run their own ingestion bridge.
///   2) A locally cached snapshot from a prior session.
///   3) An empty feed — the UI then nudges the user to add a bank manually,
///      import a statement, or scan a receipt.
class HomeFeedRepository {
  const HomeFeedRepository();

  Future<HomeFeedData?> loadCached() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kHomeFeedCacheKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return HomeFeedData.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<HomeFeedData> refresh() async {
    final remote = await _fetchRemote();
    if (remote != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kHomeFeedCacheKey, jsonEncode(remote.toMap()));
      return remote;
    }

    // No remote source configured: the home feed is whatever the user has
    // already stored locally (banks + imported transactions). The controller
    // merges those in. We just return an empty snapshot with no insight so
    // the UI surfaces the empty state.
    return HomeFeedData(
      banks: const [],
      transactions: const [],
      insight: '',
      lastUpdated: DateTime.now(),
    );
  }

  Future<HomeFeedData?> _fetchRemote() async {
    final rawUrl = Env.homeFeedUrl;
    if (rawUrl == null || rawUrl.isEmpty) return null;

    final uri = Uri.tryParse(rawUrl);
    if (uri == null) return null;

    try {
      final response = await http.get(uri);
      if (response.statusCode < 200 || response.statusCode >= 300) return null;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      return HomeFeedData.fromMap(decoded);
    } catch (_) {
      return null;
    }
  }
}

final homeFeedRepositoryProvider = Provider<HomeFeedRepository>((ref) {
  return const HomeFeedRepository();
});
