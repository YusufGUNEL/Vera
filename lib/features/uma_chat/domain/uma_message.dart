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
    required this.role,
    required this.text,
    this.card,
  });

  final UmaRole role;
  final String text;
  final OrderCard? card;

  UmaMessage copyWith({String? text, OrderCard? card}) => UmaMessage(
        role: role,
        text: text ?? this.text,
        card: card ?? this.card,
      );
}
