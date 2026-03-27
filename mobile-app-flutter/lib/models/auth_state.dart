class AuthUser {
  final int id;
  final String email;
  final String? name;
  final String role;
  final String? avatarUrl;
  final String? phone;
  final String? createdAt;

  const AuthUser({
    required this.id,
    required this.email,
    this.name,
    this.role = 'user',
    this.avatarUrl,
    this.phone,
    this.createdAt,
  });

  String get displayName => name ?? email.split('@').first;

  String get initials {
    if (name != null && name!.isNotEmpty) {
      final parts = name!.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
      return parts.first[0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  bool get isAdmin => role == 'admin';

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as int,
      email: json['email'] as String? ?? '',
      name: json['name'] as String?,
      role: json['role'] as String? ?? 'user',
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'role': role,
        'avatar_url': avatarUrl,
        'phone': phone,
        'created_at': createdAt,
      };
}

enum AuthStatus { unknown, guest, authenticated }

class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isGuest => status == AuthStatus.guest;
  bool get isLoading => status == AuthStatus.unknown;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }

  factory AuthState.guest() => const AuthState(status: AuthStatus.guest);

  factory AuthState.authenticated(AuthUser user) => AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );

  factory AuthState.error(String message) => AuthState(
        status: AuthStatus.guest,
        error: message,
      );
}
