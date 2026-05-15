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
    name: 'MacBook Pro\'dan giriş',
    location: 'İstanbul, TR',
    when: '2 dk önce',
    blocked: false,
  ),
  SecurityCheck(
    id: 2,
    name: 'Havale · 48.000 TL',
    location: 'Alıcı: Bilinmeyen hesap',
    when: '1 sa önce',
    blocked: true,
    reason:
        'Bu transfer sırasında alışılmadık bir cihaz konumu tespit edildi. Alıcı hesap 3 gün önce açıldı ve daha önceki dolandırıcılık raporlarındaki örüntülerle eşleşiyor. Transfer Lagos IP\'sinden geldi; normal aktiviteniz ise İstanbul merkezli.',
  ),
  SecurityCheck(
    id: 3,
    name: 'Karta dokunmadan ödeme · 349 TL',
    location: 'Trendyol.com',
    when: '3 sa önce',
    blocked: false,
  ),
  SecurityCheck(
    id: 4,
    name: 'Yeni cihaz girişi',
    location: 'iPhone 17 Pro · İstanbul',
    when: 'Bugün, 09:14',
    blocked: false,
  ),
  SecurityCheck(
    id: 5,
    name: 'ATM çekimi · 2.000 TL',
    location: 'Garanti BBVA Levent',
    when: 'Dün',
    blocked: false,
  ),
];
