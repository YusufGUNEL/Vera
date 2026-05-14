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
}
