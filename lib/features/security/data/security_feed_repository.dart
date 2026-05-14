import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/env.dart';
import '../domain/security_feed_data.dart';
import 'security_check.dart';

const _kSecurityFeedCacheKey = 'security.feed.cache';

class SecurityFeedRepository {
  const SecurityFeedRepository();

  Future<SecurityFeedData?> loadCached() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSecurityFeedCacheKey);
    if (raw == null || raw.isEmpty) return null;
    return SecurityFeedData.fromMap(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<SecurityFeedData> refresh() async {
    final remote = await _fetchRemote();
    if (remote != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kSecurityFeedCacheKey, jsonEncode(remote.toMap()));
      return remote;
    }

    await Future<void>.delayed(const Duration(milliseconds: 650));
    final now = DateTime.now();

    final checks = [
      SecurityCheck(
        id: 900 + now.minute,
        name: now.minute.isEven
            ? 'Merchant token refresh'
            : 'Card-not-present · TL 129',
        location: now.minute.isEven ? 'Apple Wallet' : 'Getir',
        when: '${(now.second % 50) + 1} sec ago',
        blocked: !now.minute.isEven,
        reason: now.minute.isEven
            ? null
            : 'The payment originated from a merchant pattern you have not used recently and the device signature did not match your last known checkout path.',
      ),
      ...kSecurityChecks.take(4),
    ];

    final data = SecurityFeedData(checks: checks, lastUpdated: now);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSecurityFeedCacheKey, jsonEncode(data.toMap()));
    return data;
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
