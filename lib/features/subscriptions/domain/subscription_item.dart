import 'package:flutter/material.dart';

import 'subscription_status.dart';

class SubscriptionItem {
  const SubscriptionItem({
    required this.id,
    required this.name,
    required this.vendor,
    required this.category,
    required this.monthlyPrice,
    required this.previousPrice,
    required this.renewalLabel,
    required this.lastUsedLabel,
    required this.status,
    required this.recommendation,
    required this.icon,
    this.canFreeze = false,
  });

  final String id;
  final String name;
  final String vendor;
  final String category;
  final double monthlyPrice;
  final double previousPrice;
  final String renewalLabel;
  final String lastUsedLabel;
  final SubscriptionStatus status;
  final String recommendation;
  final IconData icon;
  final bool canFreeze;

  double get priceDelta => monthlyPrice - previousPrice;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'vendor': vendor,
      'category': category,
      'monthlyPrice': monthlyPrice,
      'previousPrice': previousPrice,
      'renewalLabel': renewalLabel,
      'lastUsedLabel': lastUsedLabel,
      'status': status.name,
      'recommendation': recommendation,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'iconFontPackage': icon.fontPackage,
      'canFreeze': canFreeze,
    };
  }

  factory SubscriptionItem.fromMap(Map<String, dynamic> map) {
    return SubscriptionItem(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      vendor: map['vendor'] as String? ?? '',
      category: map['category'] as String? ?? '',
      monthlyPrice: (map['monthlyPrice'] as num?)?.toDouble() ?? 0,
      previousPrice: (map['previousPrice'] as num?)?.toDouble() ?? 0,
      renewalLabel: map['renewalLabel'] as String? ?? '',
      lastUsedLabel: map['lastUsedLabel'] as String? ?? '',
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SubscriptionStatus.healthy,
      ),
      recommendation: map['recommendation'] as String? ?? '',
      icon: IconData(
        map['iconCodePoint'] as int? ?? Icons.star.codePoint,
        fontFamily: map['iconFontFamily'] as String? ?? Icons.star.fontFamily,
        fontPackage: map['iconFontPackage'] as String?,
      ),
      canFreeze: map['canFreeze'] as bool? ?? false,
    );
  }
}
