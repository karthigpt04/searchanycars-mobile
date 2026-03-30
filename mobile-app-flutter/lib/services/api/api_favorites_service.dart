import 'dio_client.dart';

/// API service for managing user favorites (wishlist) on the backend.
/// Requires authenticated session (cookies handled by DioClient).
class ApiFavoritesService {
  /// Get the current user's favorite listing IDs.
  Future<List<int>> getFavorites() async {
    final response = await DioClient.instance.get('/api/favorites');
    final data = response.data as List;
    return data.map((e) => e as int).toList();
  }

  /// Add a listing to the user's favorites.
  Future<void> addFavorite(int listingId) async {
    await DioClient.instance.post('/api/favorites/$listingId');
  }

  /// Remove a listing from the user's favorites.
  Future<void> removeFavorite(int listingId) async {
    await DioClient.instance.delete('/api/favorites/$listingId');
  }

  /// Bulk sync: merge local IDs into the server and return the full merged list.
  Future<List<int>> syncFavorites(List<int> localIds) async {
    final response = await DioClient.instance.put(
      '/api/favorites',
      data: {'ids': localIds},
    );
    final data = response.data as List;
    return data.map((e) => e as int).toList();
  }
}
