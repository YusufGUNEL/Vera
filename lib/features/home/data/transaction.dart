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
}

const kTransactions = <Txn>[
  Txn(
    id: 1,
    name: 'Migros',
    category: 'Groceries',
    icon: Icons.shopping_cart_outlined,
    amount: -487.20,
    when: 'Today, 14:22',
    color: Color(0xFFE67E22),
  ),
  Txn(
    id: 2,
    name: 'Aksoy Yazılım',
    category: 'Salary',
    icon: Icons.work_outline,
    amount: 48500,
    when: 'Today, 09:00',
    color: Color(0xFF2F8B5C),
  ),
  Txn(
    id: 3,
    name: 'Kahve Dünyası',
    category: 'Food & Drink',
    icon: Icons.local_cafe_outlined,
    amount: -125,
    when: 'Yesterday',
    color: Color(0xFF8E5A3C),
  ),
  Txn(
    id: 4,
    name: 'Netflix',
    category: 'Subscriptions',
    icon: Icons.movie_outlined,
    amount: -149.99,
    when: 'Yesterday',
    color: Color(0xFFC03A2B),
  ),
  Txn(
    id: 5,
    name: 'Ahmet K.',
    category: 'Transfer',
    icon: Icons.send_outlined,
    amount: -1500,
    when: 'May 11',
    color: Color(0xFF2D5FB0),
  ),
  Txn(
    id: 6,
    name: 'BIM',
    category: 'Groceries',
    icon: Icons.shopping_cart_outlined,
    amount: -312.40,
    when: 'May 11',
    color: Color(0xFFE67E22),
  ),
];
