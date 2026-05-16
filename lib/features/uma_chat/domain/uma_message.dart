import 'uma_feedback.dart';

enum UmaRole { uma, user }

enum OrderStatus { review, forwarded, dismissed }

enum UmaActionType { buyGold, payCreditCard, moveToSavings }

class OrderCard {
  const OrderCard({
    required this.type,
    required this.title,
    required this.from,
    required this.to,
    required this.amount,
    required this.bankApp,
    this.detailLabel,
    this.detailValue,
    this.note,
    this.status = OrderStatus.review,
  });

  final UmaActionType type;
  final String title;
  final String from;
  final String to;
  final double amount;
  final String bankApp;
  final String? detailLabel;
  final String? detailValue;
  final String? note;
  final OrderStatus status;

  OrderCard copyWith({OrderStatus? status}) => OrderCard(
        type: type,
        title: title,
        from: from,
        to: to,
        amount: amount,
        bankApp: bankApp,
        detailLabel: detailLabel,
        detailValue: detailValue,
        note: note,
        status: status ?? this.status,
      );
}

class UmaMessage {
  const UmaMessage({
    required this.id,
    required this.role,
    required this.text,
    this.card,
    this.createdAt,
    this.feedback,
    this.intent,
  });

  final String id;
  final UmaRole role;
  final String text;
  final OrderCard? card;
  final DateTime? createdAt;
  final UmaFeedbackEntry? feedback;
  final String? intent;

  UmaMessage copyWith({
    String? text,
    OrderCard? card,
    DateTime? createdAt,
    UmaFeedbackEntry? feedback,
    String? intent,
    bool clearFeedback = false,
  }) =>
      UmaMessage(
        id: id,
        role: role,
        text: text ?? this.text,
        card: card ?? this.card,
        createdAt: createdAt ?? this.createdAt,
        feedback: clearFeedback ? null : (feedback ?? this.feedback),
        intent: intent ?? this.intent,
      );
}
