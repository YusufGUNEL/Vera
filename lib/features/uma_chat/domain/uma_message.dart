enum UmaRole { uma, user }

class UmaMessage {
  const UmaMessage({
    required this.id,
    required this.role,
    required this.text,
    this.createdAt,
    this.intent,
  });

  final String id;
  final UmaRole role;
  final String text;
  final DateTime? createdAt;
  final String? intent;

  UmaMessage copyWith({
    String? text,
    DateTime? createdAt,
    String? intent,
  }) =>
      UmaMessage(
        id: id,
        role: role,
        text: text ?? this.text,
        createdAt: createdAt ?? this.createdAt,
        intent: intent ?? this.intent,
      );
}
