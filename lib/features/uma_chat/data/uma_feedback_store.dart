import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/uma_feedback.dart';

const _kUmaFeedbackKey = 'uma.feedback.entries';

class UmaFeedbackStore {
  const UmaFeedbackStore();

  Future<List<UmaFeedbackEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUmaFeedbackKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(UmaFeedbackEntry.fromMap)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return const [];
    }
  }

  Future<void> save(UmaFeedbackEntry entry) async {
    final existing = await load();
    final filtered =
        existing.where((item) => item.messageId != entry.messageId).toList();
    final merged = [entry, ...filtered];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kUmaFeedbackKey,
      jsonEncode(merged.map((item) => item.toMap()).toList()),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUmaFeedbackKey);
  }

  Future<String> buildPromptContext() async {
    final entries = await load();
    if (entries.isEmpty) return '';

    final recent = entries.take(5).toList();
    final lines = <String>[];
    for (final entry in recent) {
      final preview = entry.responseText.replaceAll('\n', ' ').trim();
      final shortPreview =
          preview.length > 120 ? '${preview.substring(0, 120)}...' : preview;
      final vote = entry.vote == UmaFeedbackVote.helpful
          ? 'helpful'
          : 'not helpful';
      final note = (entry.note ?? '').trim();
      lines.add(
        note.isEmpty
            ? '- $vote: $shortPreview'
            : '- $vote: $shortPreview | note: $note',
      );
    }

    return [
      'Recent user feedback about previous Uma replies:',
      ...lines,
      'Adapt your style accordingly while staying concise and trustworthy.',
    ].join('\n');
  }
}

final umaFeedbackStoreProvider = Provider<UmaFeedbackStore>((ref) {
  return const UmaFeedbackStore();
});
