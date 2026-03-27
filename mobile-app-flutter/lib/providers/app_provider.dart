import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/car.dart';
import '../models/listing.dart';
import '../models/mock_data.dart';
import '../repositories/car_repository.dart';
import '../utils/cache_manager.dart';

// ============================================================
// WISHLIST — persisted in Hive
// ============================================================

class WishlistNotifier extends StateNotifier<List<int>> {
  WishlistNotifier() : super(CacheManager.getWishlistIds()) {
    // If Hive was empty, use default mock IDs
    if (state.isEmpty) {
      state = [1, 3];
      CacheManager.saveWishlistIds(state);
    }
  }

  void toggle(int carId) {
    if (state.contains(carId)) {
      state = state.where((id) => id != carId).toList();
    } else {
      state = [...state, carId];
    }
    CacheManager.saveWishlistIds(state);
  }

  bool isWishlisted(int carId) => state.contains(carId);
}

final wishlistProvider = StateNotifierProvider<WishlistNotifier, List<int>>(
  (ref) => WishlistNotifier(),
);

// ============================================================
// CAR PROVIDERS (legacy — kept for backward compat with widgets)
// ============================================================

final carsProvider = Provider<List<Car>>((ref) => MockData.cars);

final featuredCarsProvider = Provider<List<Car>>((ref) {
  return ref.watch(carsProvider).take(4).toList();
});

final recentCarsProvider = Provider<List<Car>>((ref) {
  return ref.watch(carsProvider).skip(4).toList();
});

final wishlistedCarsProvider = Provider<List<Car>>((ref) {
  final wishlist = ref.watch(wishlistProvider);
  final cars = ref.watch(carsProvider);
  return cars.where((car) => wishlist.contains(car.id)).toList();
});

// ============================================================
// SEARCH — works with both API and mock data
// ============================================================

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(const SearchState());

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setFilter(String filter) {
    state = state.copyWith(activeFilter: filter);
  }

  void setSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }
}

class SearchState {
  final String query;
  final String activeFilter;
  final String sortBy;

  const SearchState({
    this.query = '',
    this.activeFilter = 'All',
    this.sortBy = 'default',
  });

  SearchState copyWith({String? query, String? activeFilter, String? sortBy}) {
    return SearchState(
      query: query ?? this.query,
      activeFilter: activeFilter ?? this.activeFilter,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  /// Build API query parameters from search state
  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (query.isNotEmpty) params['search'] = query;
    if (activeFilter != 'All') {
      params['body_style'] = activeFilter;
    }
    if (sortBy != 'default') params['sortBy'] = sortBy;
    return params;
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>(
  (ref) => SearchNotifier(),
);

/// Search results using the repository (API or mock fallback)
final searchResultsProvider = FutureProvider<List<Listing>>((ref) async {
  final search = ref.watch(searchProvider);
  final repo = ref.watch(carRepositoryProvider);
  final params = search.toQueryParams();
  return repo.getListings(filters: params.isEmpty ? null : params);
});

// Legacy filtered cars provider (still used by some widgets)
final filteredCarsProvider = Provider<List<Car>>((ref) {
  final search = ref.watch(searchProvider);
  final cars = ref.watch(carsProvider);

  return cars.where((car) {
    if (search.query.isNotEmpty) {
      final q = search.query.toLowerCase();
      if (!car.name.toLowerCase().contains(q) &&
          !car.brand.toLowerCase().contains(q) &&
          !car.city.toLowerCase().contains(q)) {
        return false;
      }
    }

    if (search.activeFilter != 'All') {
      final filter = search.activeFilter.toLowerCase();
      switch (filter) {
        case 'suv':
          return ['Toyota Fortuner', 'Hyundai Creta', 'Tata Harrier', 'Kia Seltos', 'Mahindra XUV700']
              .contains(car.name);
        case 'sedan':
          return ['Mercedes-Benz C-Class', 'BMW 3 Series', 'Audi A4'].contains(car.name);
        case 'luxury':
          return ['Mercedes', 'BMW', 'Audi'].contains(car.brand);
        default:
          return true;
      }
    }

    return true;
  }).toList();
});

final selectedCarProvider = StateProvider<Car?>((ref) => null);

// ============================================================
// COMPARE
// ============================================================

final compareCarsProvider = StateNotifierProvider<CompareCarsNotifier, List<Car>>(
  (ref) => CompareCarsNotifier(),
);

class CompareCarsNotifier extends StateNotifier<List<Car>> {
  CompareCarsNotifier() : super([]);

  void addCar(Car car) {
    if (state.length < 3 && !state.any((c) => c.id == car.id)) {
      state = [...state, car];
    }
  }

  void removeCar(int carId) {
    state = state.where((c) => c.id != carId).toList();
  }

  void clear() {
    state = [];
  }
}

// ============================================================
// LISTING-BASED WISHLISTED ITEMS
// ============================================================

final wishlistedListingsProvider = FutureProvider<List<Listing>>((ref) async {
  final wishlist = ref.watch(wishlistProvider);
  final repo = ref.watch(carRepositoryProvider);
  if (wishlist.isEmpty) return [];

  final allListings = await repo.getListings();
  return allListings.where((l) => wishlist.contains(l.id)).toList();
});
