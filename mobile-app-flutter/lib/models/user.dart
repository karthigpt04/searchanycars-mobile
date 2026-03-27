class AppUser {
  final String id;
  final String name;
  final String initials;
  final String email;
  final String phone;
  final String city;
  final String memberSince;
  final String tier;

  const AppUser({
    required this.id,
    required this.name,
    required this.initials,
    required this.email,
    required this.phone,
    required this.city,
    required this.memberSince,
    required this.tier,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? '';
    final parts = name.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : name.isNotEmpty
            ? name[0].toUpperCase()
            : 'U';

    return AppUser(
      id: json['id']?.toString() ?? '',
      name: name,
      initials: initials,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      city: json['city'] as String? ?? '',
      memberSince:
          json['created_at'] as String? ?? json['memberSince'] as String? ?? '',
      tier: json['tier'] as String? ?? 'Member',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'city': city,
        'memberSince': memberSince,
        'tier': tier,
      };
}
