import 'package:flutter/material.dart';

class Bank {
  const Bank({
    required this.id,
    required this.name,
    required this.shortCode,
    required this.balance,
    required this.color,
    required this.last4,
  });

  final String id;
  final String name;
  final String shortCode;
  final double balance;
  final Color color;
  final String last4;
}

const kBanks = <Bank>[
  Bank(
    id: 'gr',
    name: 'Garanti BBVA',
    shortCode: 'GR',
    balance: 184250,
    color: Color(0xFF1B5E20),
    last4: '••2847',
  ),
  Bank(
    id: 'ak',
    name: 'Akbank',
    shortCode: 'AK',
    balance: 92400,
    color: Color(0xFFB71C1C),
    last4: '••1209',
  ),
  Bank(
    id: 'is',
    name: 'İş Bankası',
    shortCode: 'IB',
    balance: 41680,
    color: Color(0xFF0D47A1),
    last4: '••5544',
  ),
  Bank(
    id: 'zb',
    name: 'Ziraat',
    shortCode: 'ZB',
    balance: 28910,
    color: Color(0xFF3E2723),
    last4: '••3318',
  ),
];
