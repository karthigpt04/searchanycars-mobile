class TestDriveBooking {
  final int listingId;
  final String carTitle;
  final String name;
  final String phone;
  final String preferredDate;
  final String preferredTime;
  final String? notes;
  final String createdAt;

  const TestDriveBooking({
    required this.listingId,
    required this.carTitle,
    required this.name,
    required this.phone,
    required this.preferredDate,
    required this.preferredTime,
    this.notes,
    required this.createdAt,
  });

  factory TestDriveBooking.fromJson(Map<String, dynamic> json) {
    return TestDriveBooking(
      listingId: json['listing_id'] as int,
      carTitle: json['car_title'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      preferredDate: json['preferred_date'] as String? ?? '',
      preferredTime: json['preferred_time'] as String? ?? '',
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'listing_id': listingId,
      'car_title': carTitle,
      'name': name,
      'phone': phone,
      'preferred_date': preferredDate,
      'preferred_time': preferredTime,
      'notes': notes,
      'created_at': createdAt,
    };
  }
}
