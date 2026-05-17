import 'package:flutter/material.dart';

class Txn {
  const Txn({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.amount,
    required this.when,
    required this.color,
  });

  final int id;
  final String name;
  final String category;
  final IconData icon;
  final double amount;
  final String when;
  final Color color;

  bool get isCredit => amount > 0;

  Txn copyWith({
    int? id,
    String? name,
    String? category,
    IconData? icon,
    double? amount,
    String? when,
    Color? color,
  }) {
    return Txn(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      amount: amount ?? this.amount,
      when: when ?? this.when,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'icon': icon.codePoint,
      'amount': amount,
      'when': when,
      'color': color.toARGB32(),
    };
  }

  factory Txn.fromMap(Map<String, dynamic> map) {
    return Txn(
      id: map['id'] as int,
      name: map['name'] as String,
      category: map['category'] as String,
      icon: IconData(map['icon'] as int, fontFamily: 'MaterialIcons'),
      amount: (map['amount'] as num).toDouble(),
      when: map['when'] as String,
      color: Color(map['color'] as int),
    );
  }
}

/// No hardcoded transactions. The list comes from user-managed entries:
/// manual add, statement import (PDF/Excel), or receipt OCR.
const kTransactions = <Txn>[];
