import 'package:flutter/material.dart';

class UpcomingBill {
  const UpcomingBill({
    required this.name,
    required this.amount,
    required this.daysUntilDue,
    required this.icon,
    required this.accent,
  });

  final String name;
  final double amount;
  final int daysUntilDue;
  final IconData icon;
  final Color accent;
}

const kUpcomingBills = <UpcomingBill>[
  UpcomingBill(
    name: 'Akbank Platinum',
    amount: 12450,
    daysUntilDue: 3,
    icon: Icons.credit_card,
    accent: Color(0xFFE63E5C),
  ),
  UpcomingBill(
    name: 'Türk Telekom',
    amount: 425,
    daysUntilDue: 8,
    icon: Icons.wifi,
    accent: Color(0xFF1E88E5),
  ),
  UpcomingBill(
    name: 'BEDAŞ Elektrik',
    amount: 380,
    daysUntilDue: 12,
    icon: Icons.bolt,
    accent: Color(0xFFFFA000),
  ),
];
