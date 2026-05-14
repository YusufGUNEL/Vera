enum SubscriptionStatus {
  healthy,
  priceIncreased,
  unused,
  renewalSoon,
}

extension SubscriptionStatusX on SubscriptionStatus {
  bool get needsAttention =>
      this == SubscriptionStatus.priceIncreased ||
      this == SubscriptionStatus.unused ||
      this == SubscriptionStatus.renewalSoon;

  String get label => switch (this) {
        SubscriptionStatus.healthy => 'ACTIVE',
        SubscriptionStatus.priceIncreased => 'PRICE UP',
        SubscriptionStatus.unused => 'UNUSED',
        SubscriptionStatus.renewalSoon => 'RENEWS SOON',
      };
}
