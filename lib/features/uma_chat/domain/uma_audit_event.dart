enum UmaAuditAction {
  replyGenerated,
  orderForwarded,
  orderDismissed,
  feedbackHelpful,
  feedbackNotHelpful,
}

class UmaAuditEvent {
  const UmaAuditEvent({
    required this.id,
    required this.messageId,
    required this.action,
    required this.timestamp,
    required this.signature,
    required this.summary,
    this.intent,
    this.note,
    this.metadata = const {},
  });

  final String id;
  final String messageId;
  final UmaAuditAction action;
  final DateTime timestamp;
  final String signature;
  final String summary;
  final String? intent;
  final String? note;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'messageId': messageId,
      'action': action.name,
      'timestamp': timestamp.toIso8601String(),
      'signature': signature,
      'summary': summary,
      'intent': intent,
      'note': note,
      'metadata': metadata,
    };
  }

  factory UmaAuditEvent.fromMap(Map<String, dynamic> map) {
    return UmaAuditEvent(
      id: map['id'] as String? ?? '',
      messageId: map['messageId'] as String? ?? '',
      action: _actionByName(map['action'] as String?),
      timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      signature: map['signature'] as String? ?? '',
      summary: map['summary'] as String? ?? '',
      intent: map['intent'] as String?,
      note: map['note'] as String?,
      metadata: (map['metadata'] as Map?)?.cast<String, dynamic>() ?? const {},
    );
  }
}

UmaAuditAction _actionByName(String? name) {
  for (final action in UmaAuditAction.values) {
    if (action.name == name) return action;
  }
  return UmaAuditAction.replyGenerated;
}
