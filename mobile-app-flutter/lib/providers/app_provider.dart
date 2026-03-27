import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/car.dart';
import '../models/mock_data.dart';

// Wishlist state
class WishlistNotifier extends StateNotifier<List<int>> {
  WishlistNotifier() : super([1, 3]); // Pre-saved cars 1 & 3

  void toggle(int carId) {
    if (state.contains(carId)) {
      state = state.where((id) => id != carId).toList();
    } else {
      state = [...state, carId];
    }
  }

  bool isWishlisted(int carId) => state.contains(carId);
}

final wishlistProvider = StateNotifierProvider<WishlistNotifier, List<int>>(
  (ref) => WishlistNotifier(),
);

// All cars provider
final carsProvider = Provider<List<Car>>((ref) => MockData.cars);

// Featured cars (first 4)
final featuredCarsProvider = Provider<List<Car>>((ref) {
  return ref.watch(carsProvider).take(4).toList();
});

// Recently added cars (last 4)
final recentCarsProvider = Provider<List<Car>>((ref) {
  return ref.watch(carsProvider).skip(4).toList();
});

// Wishlisted cars
final wishlistedCarsProvider = Provider<List<Car>>((ref) {
  final wishlist = ref.watch(wishlistProvider);
  final cars = ref.watch(carsProvider);
  return cars.where((car) => wishlist.contains(car.id)).toList();
});

// Search state
class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(const SearchState());

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setFilter(String filter) {
    state = state.copyWith(activeFilter: filter);
  }
}

class SearchState {
  final String query;
  final String activeFilter;

  const SearchState({this.query = '', this.activeFilter = 'All'});

  SearchState copyWith({String? query, String? activeFilter}) {
    return SearchState(
      query: query ?? this.query,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>(
  (ref) => SearchNotifier(),
);

// Filtered cars for search
final filteredCarsProvider = Provider<List<Car>>((ref) {
  final search = ref.watch(searchProvider);
  final cars = ref.watch(carsProvider);

  return cars.where((car) {
    // Query filter
    if (search.query.isNotEmpty) {
      final q = search.query.toLowerCase();
      if (!car.name.toLowerCase().contains(q) &&
          !car.brand.toLowerCase().contains(q) &&
          !car.city.toLowerCase().contains(q)) {
        return false;
      }
    }

    // Type filter
    if (search.activeFilter != 'All') {
      final filter = search.activeFilter.toLowerCase();
      // Simple mapping: Luxury brands, SUV models, etc.
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

// Selected car for detail
final selectedCarProvider = StateProvider<Car?>((ref) => null);

// Compare cars
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
