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

  Bank copyWith({
    String? id,
    String? name,
    String? shortCode,
    double? balance,
    Color? color,
    String? last4,
  }) {
    return Bank(
      id: id ?? this.id,
      name: name ?? this.name,
      shortCode: shortCode ?? this.shortCode,
      balance: balance ?? this.balance,
      color: color ?? this.color,
      last4: last4 ?? this.last4,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'shortCode': shortCode,
      'balance': balance,
      'color': color.toARGB32(),
      'last4': last4,
    };
  }

  factory Bank.fromMap(Map<String, dynamic> map) {
    return Bank(
      id: map['id'] as String,
      name: map['name'] as String,
      shortCode: map['shortCode'] as String,
      balance: (map['balance'] as num).toDouble(),
      color: Color(map['color'] as int),
      last4: map['last4'] as String,
    );
  }
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
    name: 'Is Bankasi',
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
