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
  WishlistNotifier() : super(CacheManager.getWishlistIds());


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

  /// Sets all advanced filters at once from the filter panel map.
  void setAdvancedFilters(Map<String, dynamic> filters) {
    state = state.copyWith(
      priceMin: filters['priceMin'] as double?,
      priceMax: filters['priceMax'] as double?,
      fuelType: filters['fuelType'] as String?,
      transmissionType: filters['transmissionType'] as String?,
      yearMin: filters['yearMin'] as int?,
      yearMax: filters['yearMax'] as int?,
      ownershipType: filters['ownershipType'] as String?,
      maxKm: filters['maxKm'] as double?,
      clearPriceMin: !filters.containsKey('priceMin'),
      clearPriceMax: !filters.containsKey('priceMax'),
      clearFuelType: !filters.containsKey('fuelType'),
      clearTransmissionType: !filters.containsKey('transmissionType'),
      clearYearMin: !filters.containsKey('yearMin'),
      clearYearMax: !filters.containsKey('yearMax'),
      clearOwnershipType: !filters.containsKey('ownershipType'),
      clearMaxKm: !filters.containsKey('maxKm'),
    );
  }

  /// Resets all advanced filters to null.
  void clearAdvancedFilters() {
    state = state.copyWith(
      clearPriceMin: true,
      clearPriceMax: true,
      clearFuelType: true,
      clearTransmissionType: true,
      clearYearMin: true,
      clearYearMax: true,
      clearOwnershipType: true,
      clearMaxKm: true,
    );
  }

  /// Count of non-null advanced filters.
  int get activeFilterCount => state.activeFilterCount;
}

class SearchState {
  final String query;
  final String activeFilter;
  final String sortBy;

  // Advanced filter fields
  final double? priceMin; // in INR
  final double? priceMax; // in INR
  final String? fuelType;
  final String? transmissionType;
  final int? yearMin;
  final int? yearMax;
  final String? ownershipType;
  final double? maxKm;

  const SearchState({
    this.query = '',
    this.activeFilter = 'All',
    this.sortBy = 'default',
    this.priceMin,
    this.priceMax,
    this.fuelType,
    this.transmissionType,
    this.yearMin,
    this.yearMax,
    this.ownershipType,
    this.maxKm,
  });

  /// Count of non-null advanced filters.
  int get activeFilterCount {
    int count = 0;
    if (priceMin != null || priceMax != null) count++;
    if (fuelType != null) count++;
    if (transmissionType != null) count++;
    if (yearMin != null || yearMax != null) count++;
    if (ownershipType != null) count++;
    if (maxKm != null) count++;
    return count;
  }

  /// Returns a map of current advanced filter values for initializing the filter panel.
  Map<String, dynamic> toAdvancedFilterMap() {
    final map = <String, dynamic>{};
    if (priceMin != null) map['priceMin'] = priceMin;
    if (priceMax != null) map['priceMax'] = priceMax;
    if (fuelType != null) map['fuelType'] = fuelType;
    if (transmissionType != null) map['transmissionType'] = transmissionType;
    if (yearMin != null) map['yearMin'] = yearMin;
    if (yearMax != null) map['yearMax'] = yearMax;
    if (ownershipType != null) map['ownershipType'] = ownershipType;
    if (maxKm != null) map['maxKm'] = maxKm;
    return map;
  }

  SearchState copyWith({
    String? query,
    String? activeFilter,
    String? sortBy,
    double? priceMin,
    double? priceMax,
    String? fuelType,
    String? transmissionType,
    int? yearMin,
    int? yearMax,
    String? ownershipType,
    double? maxKm,
    bool clearPriceMin = false,
    bool clearPriceMax = false,
    bool clearFuelType = false,
    bool clearTransmissionType = false,
    bool clearYearMin = false,
    bool clearYearMax = false,
    bool clearOwnershipType = false,
    bool clearMaxKm = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      activeFilter: activeFilter ?? this.activeFilter,
      sortBy: sortBy ?? this.sortBy,
      priceMin: clearPriceMin ? null : (priceMin ?? this.priceMin),
      priceMax: clearPriceMax ? null : (priceMax ?? this.priceMax),
      fuelType: clearFuelType ? null : (fuelType ?? this.fuelType),
      transmissionType: clearTransmissionType ? null : (transmissionType ?? this.transmissionType),
      yearMin: clearYearMin ? null : (yearMin ?? this.yearMin),
      yearMax: clearYearMax ? null : (yearMax ?? this.yearMax),
      ownershipType: clearOwnershipType ? null : (ownershipType ?? this.ownershipType),
      maxKm: clearMaxKm ? null : (maxKm ?? this.maxKm),
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

    // Advanced filter params
    if (priceMin != null) params['listing_price_min'] = priceMin!.toInt();
    if (priceMax != null) params['listing_price_max'] = priceMax!.toInt();
    if (fuelType != null) params['fuel_type'] = fuelType;
    if (transmissionType != null) params['transmission_type'] = transmissionType;
    if (yearMin != null) params['model_year_min'] = yearMin;
    if (yearMax != null) params['model_year_max'] = yearMax;
    if (ownershipType != null) params['ownership_type'] = ownershipType;
    if (maxKm != null) params['total_km_driven_max'] = maxKm!.toInt();

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
