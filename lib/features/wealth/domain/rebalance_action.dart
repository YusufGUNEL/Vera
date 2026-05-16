import 'package:flutter/material.dart';

enum WealthActionType { rebalance, buyEquity, topUpCash, protection }

class RebalanceAction {
  const RebalanceAction({
    required this.id,
    required this.type,
    required this.title,
    required this.detail,
    required this.why,
    required this.when,
    required this.amount,
    required this.undoable,
    this.undone = false,
  });

  final String id;
  final WealthActionType type;
  final String title;
  final String detail;
  final String why;
  final String when;
  final double amount;
  final bool undoable;
  final bool undone;

  RebalanceAction copyWith({bool? undone}) {
    return RebalanceAction(
      id: id,
      type: type,
      title: title,
      detail: detail,
      why: why,
      when: when,
      amount: amount,
      undoable: undoable,
      undone: undone ?? this.undone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'detail': detail,
      'why': why,
      'when': when,
      'amount': amount,
      'undoable': undoable,
      'undone': undone,
    };
  }

  factory RebalanceAction.fromMap(Map<String, dynamic> map) {
    return RebalanceAction(
      id: map['id'] as String? ?? '',
      type: WealthActionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => WealthActionType.rebalance,
      ),
      title: map['title'] as String? ?? '',
      detail: map['detail'] as String? ?? '',
      why: map['why'] as String? ?? '',
      when: map['when'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      undoable: map['undoable'] as bool? ?? false,
      undone: map['undone'] as bool? ?? false,
    );
  }
}

class WealthActionVisual {
  const WealthActionVisual({
    required this.icon,
    required this.colorKey,
  });

  final IconData icon;
  final String colorKey;
}
