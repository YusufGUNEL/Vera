import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kNotificationCenterStateKey = 'home.notification_center.state';

class NoticeLocalState {
  const NoticeLocalState({
    this.isRead = false,
    this.isDismissed = false,
    this.updatedAt,
  });

  final bool isRead;
  final bool isDismissed;
  final DateTime? updatedAt;

  NoticeLocalState copyWith({
    bool? isRead,
    bool? isDismissed,
    DateTime? updatedAt,
  }) {
    return NoticeLocalState(
      isRead: isRead ?? this.isRead,
      isDismissed: isDismissed ?? this.isDismissed,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isRead': isRead,
      'isDismissed': isDismissed,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory NoticeLocalState.fromMap(Map<String, dynamic> map) {
    return NoticeLocalState(
      isRead: map['isRead'] as bool? ?? false,
      isDismissed: map['isDismissed'] as bool? ?? false,
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? ''),
    );
  }
}

class NotificationCenterStore {
  const NotificationCenterStore();

  Future<Map<String, NoticeLocalState>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kNotificationCenterStateKey);
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const {};
      return decoded.map(
        (key, value) => MapEntry(
          '$key',
          value is Map<String, dynamic>
              ? NoticeLocalState.fromMap(value)
              : NoticeLocalState.fromMap(
                  Map<String, dynamic>.from(value as Map)),
        ),
      );
    } catch (_) {
      return const {};
    }
  }

  Future<void> save(Map<String, NoticeLocalState> state) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = state.map((key, value) => MapEntry(key, value.toMap()));
    await prefs.setString(_kNotificationCenterStateKey, jsonEncode(encoded));
  }
}

final notificationCenterStoreProvider =
    Provider<NotificationCenterStore>((ref) => const NotificationCenterStore());
