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

const kSecurityChecks = <SecurityCheck>[
  SecurityCheck(
    id: 1,
    name: 'Login from MacBook Pro',
    location: 'Istanbul, TR',
    when: '2 min ago',
    blocked: false,
  ),
  SecurityCheck(
    id: 2,
    name: 'Wire transfer · TL 48.000',
    location: 'To: Unknown account',
    when: '1h ago',
    blocked: true,
    reason:
        'An unusual device location was detected during this transfer. The recipient account was created 3 days ago and matches patterns seen in earlier fraud reports. The transfer also came from an IP in Lagos while your normal activity is based in Istanbul.',
  ),
  SecurityCheck(
    id: 3,
    name: 'Card-not-present · TL 349',
    location: 'Trendyol.com',
    when: '3h ago',
    blocked: false,
  ),
  SecurityCheck(
    id: 4,
    name: 'New device sign-in',
    location: 'iPhone 17 Pro · Istanbul',
    when: 'Today, 09:14',
    blocked: false,
  ),
  SecurityCheck(
    id: 5,
    name: 'ATM withdrawal · TL 2.000',
    location: 'Garanti BBVA Levent',
    when: 'Yesterday',
    blocked: false,
  ),
];
