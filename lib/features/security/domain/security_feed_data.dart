import '../data/security_check.dart';

class SecurityFeedData {
  const SecurityFeedData({
    required this.checks,
    required this.lastUpdated,
  });

  final List<SecurityCheck> checks;
  final DateTime lastUpdated;

  int get blockedCount => checks.where((check) => check.blocked).length;

  Map<String, dynamic> toMap() {
    return {
      'checks': checks.map((check) => check.toMap()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory SecurityFeedData.fromMap(Map<String, dynamic> map) {
    return SecurityFeedData(
      checks: (map['checks'] as List<dynamic>)
          .map((item) =>
              SecurityCheck.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList(),
      lastUpdated: DateTime.parse(map['lastUpdated'] as String),
    );
  }
}
