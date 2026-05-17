class SecurityCheck {
  const SecurityCheck({
    required this.id,
    required this.name,
    required this.location,
    required this.when,
    required this.blocked,
    this.reason,
  });

  final int id;
  final String name;
  final String location;
  final String when;
  final bool blocked;
  final String? reason;

  SecurityCheck copyWith({
    int? id,
    String? name,
    String? location,
    String? when,
    bool? blocked,
    String? reason,
  }) {
    return SecurityCheck(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      when: when ?? this.when,
      blocked: blocked ?? this.blocked,
      reason: reason ?? this.reason,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'when': when,
      'blocked': blocked,
      'reason': reason,
    };
  }

  factory SecurityCheck.fromMap(Map<String, dynamic> map) {
    return SecurityCheck(
      id: map['id'] as int,
      name: map['name'] as String,
      location: map['location'] as String,
      when: map['when'] as String,
      blocked: map['blocked'] as bool,
      reason: map['reason'] as String?,
    );
  }
}

/// No hardcoded fraud events. The feed comes only from real signals analyzed
/// by Uma over the user's imported transactions and live session activity.
const kSecurityChecks = <SecurityCheck>[];
