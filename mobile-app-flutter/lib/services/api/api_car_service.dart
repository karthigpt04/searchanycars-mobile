import 'package:dio/dio.dart';
import '../../models/listing.dart';
import '../interfaces/car_service.dart';
import 'dio_client.dart';

class ApiCarService implements CarService {
  @override
  Future<List<Listing>> getListings({Map<String, dynamic>? filters}) async {
    try {
      final response = await DioClient.instance.get(
        '/api/listings',
        queryParameters: filters,
      );
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Listing.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<Listing?> getListingById(int id) async {
    try {
      final response = await DioClient.instance.get('/api/listings/$id');
      if (response.data != null) {
        return Listing.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }
}
