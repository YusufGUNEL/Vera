import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/env.dart';
import '../domain/security_feed_data.dart';

const _kSecurityFeedCacheKey = 'security.feed.cache';

/// Provides the security feed used by Fraud Radar.
///
/// Sources:
///   1) An optional remote endpoint (SECURITY_FEED_URL).
///   2) A locally cached snapshot.
///   3) An empty feed — the screen then shows the "all clear" state.
class SecurityFeedRepository {
  const SecurityFeedRepository();

  Future<SecurityFeedData?> loadCached() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSecurityFeedCacheKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return SecurityFeedData.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<SecurityFeedData> refresh() async {
    final remote = await _fetchRemote();
    if (remote != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kSecurityFeedCacheKey, jsonEncode(remote.toMap()));
      return remote;
    }

    // No remote source: return an empty feed so the UI shows the "all clear"
    // state instead of inventing fake fraud events.
    return SecurityFeedData(
      checks: const [],
      lastUpdated: DateTime.now(),
    );
  }

  Future<SecurityFeedData?> _fetchRemote() async {
    final rawUrl = Env.securityFeedUrl;
    if (rawUrl == null || rawUrl.isEmpty) return null;

    final uri = Uri.tryParse(rawUrl);
    if (uri == null) return null;

    try {
      final response = await http.get(uri);
      if (response.statusCode < 200 || response.statusCode >= 300) return null;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      return SecurityFeedData.fromMap(decoded);
    } catch (_) {
      return null;
    }
  }
}

final securityFeedRepositoryProvider = Provider<SecurityFeedRepository>((ref) {
  return const SecurityFeedRepository();
});
