class SubscriptionAlert {
  const SubscriptionAlert({
    required this.title,
    required this.message,
    required this.metricLabel,
    required this.metricValue,
  });

  final String title;
  final String message;
  final String metricLabel;
  final String metricValue;
}
