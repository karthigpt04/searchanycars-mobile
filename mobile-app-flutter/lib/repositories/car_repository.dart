import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/listing.dart';
import '../providers/connectivity_provider.dart';
import '../services/api/api_car_service.dart';
import '../services/api/dio_client.dart';
import '../services/mock/mock_car_service.dart';
import '../utils/cache_manager.dart';

class CarRepository {
  final bool isConnected;

  CarRepository({required this.isConnected});

  Future<List<Listing>> getListings({Map<String, dynamic>? filters}) async {
    final cacheKey = _buildCacheKey(filters);

    if (isConnected) {
      try {
        final listings = await ApiCarService().getListings(filters: filters);
        // Cache the results
        await CacheManager.saveListings(
          cacheKey,
          listings.map((l) => l.toJson()).toList(),
        );
        return listings;
      } catch (_) {
        return _fallbackListings(cacheKey, filters);
      }
    } else {
      return _fallbackListings(cacheKey, filters);
    }
  }

  Future<Listing?> getListingById(int id) async {
    if (isConnected) {
      try {
        final listing = await ApiCarService().getListingById(id);
        if (listing != null) {
          await CacheManager.saveListingDetail(id, listing.toJson());
          return listing;
        }
      } catch (_) {
        return _fallbackListingDetail(id);
      }
    }
    return _fallbackListingDetail(id);
  }

  Future<List<Listing>> _fallbackListings(
    String cacheKey,
    Map<String, dynamic>? filters,
  ) async {
    // Try cache first
    final cached = CacheManager.getListings(cacheKey);
    if (cached != null) {
      return cached.map((json) => Listing.fromJson(json)).toList();
    }
    // Fall back to mock data
    return MockCarService().getListings(filters: filters);
  }

  Future<Listing?> _fallbackListingDetail(int id) async {
    final cached = CacheManager.getListingDetail(id);
    if (cached != null) {
      return Listing.fromJson(cached);
    }
    return MockCarService().getListingById(id);
  }

  String _buildCacheKey(Map<String, dynamic>? filters) {
    if (filters == null || filters.isEmpty) return 'all';
    final sorted = filters.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return sorted.map((e) => '${e.key}=${e.value}').join('&');
  }
}

// Providers

final carRepositoryProvider = Provider<CarRepository>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return CarRepository(isConnected: connectivity.isConnected);
});

final listingsProvider = FutureProvider.family<List<Listing>, Map<String, dynamic>?>(
  (ref, filters) async {
    final repo = ref.watch(carRepositoryProvider);
    return repo.getListings(filters: filters);
  },
);

final featuredListingsProvider = FutureProvider<List<Listing>>((ref) async {
  final repo = ref.watch(carRepositoryProvider);
  final listings = await repo.getListings();
  return listings.where((l) => l.featuredListing).take(6).toList();
});

final recentListingsProvider = FutureProvider<List<Listing>>((ref) async {
  final repo = ref.watch(carRepositoryProvider);
  final listings = await repo.getListings();
  // Sort by created_at descending, take 4
  final sorted = List<Listing>.from(listings)
    ..sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
  return sorted.take(4).toList();
});

final listingDetailProvider = FutureProvider.family<Listing?, int>(
  (ref, id) async {
    final repo = ref.watch(carRepositoryProvider);
    return repo.getListingById(id);
  },
);

final allListingsProvider = FutureProvider<List<Listing>>((ref) async {
  final repo = ref.watch(carRepositoryProvider);
  return repo.getListings();
});

/// S-Plus premium pre-owned listings — derived from allListingsProvider
final splusListingsProvider = FutureProvider<List<Listing>>((ref) async {
  final allListings = await ref.watch(allListingsProvider.future);
  return allListings.where((l) => l.isSplus && !l.isNewCar).toList();
});

/// S-Plus New — brand new / unregistered / demo cars — derived from allListingsProvider
final splusNewListingsProvider = FutureProvider<List<Listing>>((ref) async {
  final allListings = await ref.watch(allListingsProvider.future);
  return allListings.where((l) => l.isNewCar).toList();
});

/// Server base URL for building image URLs
final serverBaseUrlProvider = Provider<String>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.serverUrl ?? DioClient.baseUrl;
});
