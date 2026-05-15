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

const kTransactions = <Txn>[
  Txn(
    id: 1,
    name: 'Migros',
    category: 'Market',
    icon: Icons.shopping_cart_outlined,
    amount: -487.20,
    when: 'Bugün, 14:22',
    color: Color(0xFFE67E22),
  ),
  Txn(
    id: 2,
    name: 'Aksoy Yazılım',
    category: 'Maaş',
    icon: Icons.work_outline,
    amount: 48500,
    when: 'Bugün, 09:00',
    color: Color(0xFF2F8B5C),
  ),
  Txn(
    id: 3,
    name: 'Kahve Dünyası',
    category: 'Yeme & İçme',
    icon: Icons.local_cafe_outlined,
    amount: -125,
    when: 'Dün, 18:40',
    color: Color(0xFF8E5A3C),
  ),
  Txn(
    id: 4,
    name: 'Netflix',
    category: 'Abonelik',
    icon: Icons.movie_outlined,
    amount: -149.99,
    when: 'Dün, 09:10',
    color: Color(0xFFC03A2B),
  ),
  Txn(
    id: 5,
    name: 'Ahmet K.',
    category: 'Transfer',
    icon: Icons.send_outlined,
    amount: -1500,
    when: '11 May, 16:08',
    color: Color(0xFF2D5FB0),
  ),
  Txn(
    id: 6,
    name: 'BIM',
    category: 'Market',
    icon: Icons.shopping_cart_outlined,
    amount: -312.40,
    when: '11 May, 10:14',
    color: Color(0xFFE67E22),
  ),
];
