class RecurringTransactionParser {
  const RecurringTransactionParser();

  List<String> detectVendors(List<String> transactionNames) {
    final normalized =
        transactionNames.map((name) => name.toLowerCase()).toList();
    final matches = <String>{};

    for (final name in normalized) {
      if (name.contains('netflix')) matches.add('Netflix');
      if (name.contains('spotify')) matches.add('Spotify');
      if (name.contains('youtube')) matches.add('YouTube Premium');
      if (name.contains('icloud')) matches.add('iCloud+');
    }

    return matches.toList()..sort();
  }
}
