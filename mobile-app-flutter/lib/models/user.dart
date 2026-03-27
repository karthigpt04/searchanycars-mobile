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
}
