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

  /// Internal code; UI maps it to a localized label via AppStrings.
  String get code => switch (this) {
        SubscriptionStatus.healthy => 'active',
        SubscriptionStatus.priceIncreased => 'priceUp',
        SubscriptionStatus.unused => 'unused',
        SubscriptionStatus.renewalSoon => 'renewsSoon',
      };

  String get label => switch (this) {
        SubscriptionStatus.healthy => 'ACTIVE',
        SubscriptionStatus.priceIncreased => 'PRICE UP',
        SubscriptionStatus.unused => 'UNUSED',
        SubscriptionStatus.renewalSoon => 'RENEWS SOON',
      };
}
