import 'package:flutter/material.dart';

class UpcomingBill {
  const UpcomingBill({
    required this.id,
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.iconCode,
    required this.accentColor,
  });

  final String id;
  final String name;
  final double amount;
  final DateTime dueDate;
  final int iconCode;
  final int accentColor;

  /// Days until [dueDate] from now, floored at 0.
  int get daysUntilDue {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final delta = due.difference(start).inDays;
    return delta < 0 ? 0 : delta;
  }

  IconData get icon =>
      IconData(iconCode, fontFamily: 'MaterialIcons');

  Color get accent => Color(accentColor);

  UpcomingBill copyWith({
    String? id,
    String? name,
    double? amount,
    DateTime? dueDate,
    int? iconCode,
    int? accentColor,
  }) {
    return UpcomingBill(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      iconCode: iconCode ?? this.iconCode,
      accentColor: accentColor ?? this.accentColor,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'iconCode': iconCode,
      'accentColor': accentColor,
    };
  }

  factory UpcomingBill.fromMap(Map<String, dynamic> map) {
    return UpcomingBill(
      id: map['id'] as String,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      dueDate: DateTime.tryParse(map['dueDate'] as String? ?? '') ??
          DateTime.now(),
      iconCode:
          map['iconCode'] as int? ?? Icons.receipt_long_outlined.codePoint,
      accentColor: map['accentColor'] as int? ?? 0xFF7C3AED,
    );
  }
}

/// No hardcoded bills. The list is fully managed by the user (add/edit/delete).
const kUpcomingBills = <UpcomingBill>[];
