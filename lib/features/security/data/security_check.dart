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
    name: 'Wire transfer · ₺48.000',
    location: 'To: Unknown account',
    when: '1h ago',
    blocked: true,
    reason:
        'Unusual device location detected during transfer. The recipient account was created 3 days ago and matches patterns from prior fraud reports. The transfer originated from an IP in Lagos (199.x.x.x) while your typical activity is in Istanbul.',
  ),
  SecurityCheck(
    id: 3,
    name: 'Card-not-present · ₺349',
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
    name: 'ATM withdrawal · ₺2.000',
    location: 'Garanti BBVA Levent',
    when: 'Yesterday',
    blocked: false,
  ),
];
