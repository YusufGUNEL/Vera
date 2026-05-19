enum AuthStatus { loading, signedOut, signedIn }

class AuthSession {
  const AuthSession({
    required this.status,
    this.userId,
    this.displayName,
    this.email,
    this.signedInAt,
    this.authMethod = 'none',
  });

  final AuthStatus status;
  final String? userId;
  final String? displayName;
  final String? email;
  final DateTime? signedInAt;
  final String authMethod;

  /// True when the user is signed in via the local demo vault (no Firebase UID).
  bool get isAnonymous =>
      userId == 'demo-user' || authMethod == 'demo vault' || authMethod == 'none' && status == AuthStatus.signedIn;

  String get initials {
    final name = displayName?.trim();
    if (name == null || name.isEmpty) return 'VE';
    final parts = name.split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  AuthSession copyWith({
    AuthStatus? status,
    String? userId,
    String? displayName,
    String? email,
    DateTime? signedInAt,
    String? authMethod,
    bool clearIdentity = false,
  }) {
    return AuthSession(
      status: status ?? this.status,
      userId: clearIdentity ? null : (userId ?? this.userId),
      displayName: clearIdentity ? null : (displayName ?? this.displayName),
      email: clearIdentity ? null : (email ?? this.email),
      signedInAt: clearIdentity ? null : (signedInAt ?? this.signedInAt),
      authMethod: clearIdentity ? 'none' : (authMethod ?? this.authMethod),
    );
  }
}
