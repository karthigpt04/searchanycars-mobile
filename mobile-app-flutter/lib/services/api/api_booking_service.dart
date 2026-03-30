import 'dio_client.dart';

/// API service for managing test drive bookings on the backend.
/// Requires authenticated session (cookies handled by DioClient).
class ApiBookingService {
  /// Get the current user's bookings.
  Future<List<Map<String, dynamic>>> getBookings() async {
    final response = await DioClient.instance.get('/api/bookings');
    final data = response.data as List;
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Create a test drive booking.
  Future<int> createBooking({
    required int listingId,
    required String carTitle,
    required String name,
    required String phone,
    String? email,
    String? preferredDate,
    String? preferredTime,
    String? locationPreference,
    String? notes,
  }) async {
    final data = <String, dynamic>{
      'listingId': listingId,
      'carTitle': carTitle,
      'name': name,
      'phone': phone,
    };
    if (email != null) data['email'] = email;
    if (preferredDate != null) data['preferredDate'] = preferredDate;
    if (preferredTime != null) data['preferredTime'] = preferredTime;
    if (locationPreference != null) data['locationPreference'] = locationPreference;
    if (notes != null) data['notes'] = notes;

    final response = await DioClient.instance.post('/api/bookings', data: data);
    return response.data['id'] as int;
  }

  /// Cancel a booking.
  Future<void> cancelBooking(int bookingId) async {
    await DioClient.instance.delete('/api/bookings/$bookingId');
  }
}
