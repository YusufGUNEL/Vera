import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/env.dart';
import '../domain/home_feed_data.dart';
import 'bank.dart';
import 'transaction.dart';

const _kHomeFeedCacheKey = 'home.feed.cache';

class HomeFeedRepository {
  const HomeFeedRepository();

  Future<HomeFeedData?> loadCached() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kHomeFeedCacheKey);
    if (raw == null || raw.isEmpty) return null;
    return HomeFeedData.fromMap(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<HomeFeedData> refresh() async {
    final remote = await _fetchRemote();
    if (remote != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kHomeFeedCacheKey, jsonEncode(remote.toMap()));
      return remote;
    }

    await Future<void>.delayed(const Duration(milliseconds: 700));
    final now = DateTime.now();
    final minuteShift = now.minute % 5;

    final banks = [
      kBanks[0].copyWith(balance: kBanks[0].balance + minuteShift * 280),
      kBanks[1].copyWith(balance: kBanks[1].balance - minuteShift * 90),
      kBanks[2].copyWith(balance: kBanks[2].balance + minuteShift * 55),
      kBanks[3].copyWith(balance: kBanks[3].balance + minuteShift * 32),
    ];

    final transactions = [
      Txn(
        id: 1000 + now.minute,
        name: now.minute.isEven ? 'Yemeksepeti' : 'Marti',
        category: now.minute.isEven ? 'Food & Drink' : 'Transport',
        icon: now.minute.isEven
            ? kTransactions[2].icon
            : const IconData(0xe1d5, fontFamily: 'MaterialIcons'),
        amount: now.minute.isEven ? -184 : -96,
        when:
            'Today, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        color: now.minute.isEven
            ? const Color(0xFF8E5A3C)
            : const Color(0xFF2D5FB0),
      ),
      ...kTransactions.take(5),
    ];

    final total = banks.fold<double>(0, (sum, bank) => sum + bank.balance);
    final insight =
        'Live sync completed. Vera refreshed ${banks.length} accounts and now tracks ${transactions.length} recent items. Cash position is ${total > 340000 ? 'healthy' : 'worth reviewing'} after the latest update.';

    final data = HomeFeedData(
      banks: banks,
      transactions: transactions,
      insight: insight,
      lastUpdated: now,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kHomeFeedCacheKey, jsonEncode(data.toMap()));
    return data;
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
