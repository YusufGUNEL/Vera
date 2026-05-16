enum UmaFeedbackVote { helpful, notHelpful }

class UmaFeedbackEntry {
  const UmaFeedbackEntry({
    required this.messageId,
    required this.vote,
    required this.responseText,
    required this.createdAt,
    this.note,
  });

  final String messageId;
  final UmaFeedbackVote vote;
  final String responseText;
  final DateTime createdAt;
  final String? note;

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'vote': vote.name,
      'responseText': responseText,
      'createdAt': createdAt.toIso8601String(),
      'note': note,
    };
  }

  factory UmaFeedbackEntry.fromMap(Map<String, dynamic> map) {
    return UmaFeedbackEntry(
      messageId: map['messageId'] as String,
      vote: _voteByName(map['vote'] as String?),
      responseText: map['responseText'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      note: map['note'] as String?,
    );
  }

  UmaFeedbackEntry copyWith({
    UmaFeedbackVote? vote,
    String? note,
    bool clearNote = false,
  }) {
    return UmaFeedbackEntry(
      messageId: messageId,
      vote: vote ?? this.vote,
      responseText: responseText,
      createdAt: createdAt,
      note: clearNote ? null : (note ?? this.note),
    );
  }
}

UmaFeedbackVote _voteByName(String? name) {
  for (final vote in UmaFeedbackVote.values) {
    if (vote.name == name) return vote;
  }
  return UmaFeedbackVote.helpful;
}
