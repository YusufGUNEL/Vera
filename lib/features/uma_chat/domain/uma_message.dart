enum UmaRole { uma, user }

enum OrderStatus { review, confirmed, cancelled }

class OrderCard {
  const OrderCard({
    required this.from,
    required this.to,
    required this.grams,
    required this.amount,
    required this.ratePerGram,
    this.status = OrderStatus.review,
  });

  final String from;
  final String to;
  final int grams;
  final double amount;
  final double ratePerGram;
  final OrderStatus status;

  OrderCard copyWith({OrderStatus? status}) => OrderCard(
        from: from,
        to: to,
        grams: grams,
        amount: amount,
        ratePerGram: ratePerGram,
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
