import '../../models/listing.dart';
import '../../models/mock_data.dart';
import '../interfaces/car_service.dart';

class MockCarService implements CarService {
  /// Convert mock Car objects to Listing objects for a unified interface
  static List<Listing> get mockListings {
    return MockData.cars.map((car) {
      // Parse price string like "32.5L" to INR
      final priceStr = car.price.replaceAll(RegExp(r'[^\d.]'), '');
      final priceInLakhs = double.tryParse(priceStr) ?? 0;
      final priceInr = priceInLakhs * 100000;

      // Parse km string like "18,200" to number
      final kmStr = car.km.replaceAll(',', '');
      final km = double.tryParse(kmStr) ?? 0;

      return Listing(
        id: car.id,
        title: car.name,
        brand: car.brand,
        model: car.name
            .replaceFirst('${car.brand} ', '')
            .replaceFirst('${car.brand}-Benz ', ''),
        modelYear: car.year,
        listingPriceInr: priceInr,
        totalKmDriven: km,
        fuelType: car.fuel,
        transmissionType: car.transmission,
        ownershipType: car.owner == '1st'
            ? 'First'
            : car.owner == '2nd'
                ? 'Second'
                : car.owner,
        locationCity: car.city,
        exteriorColor: car.color,
        overallConditionRating: car.rating * 2, // Convert 5-scale to 10-scale
        inspectionStatus: car.certified ? 'Completed' : 'Pending',
        inspectionScore:
            car.inspection.overallScore * 20, // Convert to 100-scale
        featuredListing: car.id <= 4,
        promotionTier: car.badge == 'Premium'
            ? 'Premium'
            : car.badge == 'Luxury'
                ? 'Featured'
                : 'Standard',
        sellerType: car.dealer.badge,
        dealerRating: car.dealer.rating,
        listingStatus: 'Active',
        bodyStyle: _inferBodyStyle(car.name),
        vehicleType: _inferBodyStyle(car.name),
      );
    }).toList();
  }

  static String _inferBodyStyle(String name) {
    if (['Fortuner', 'Creta', 'Harrier', 'Seltos', 'XUV700']
        .any((s) => name.contains(s))) {
      return 'SUV';
    }
    if (['C-Class', '3 Series', 'A4'].any((s) => name.contains(s))) {
      return 'Sedan';
    }
    return 'SUV';
  }

  @override
  Future<List<Listing>> getListings({Map<String, dynamic>? filters}) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network
    var listings = mockListings;

    if (filters != null) {
      final search = filters['search'] as String?;
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        listings = listings
            .where((l) =>
                l.title.toLowerCase().contains(q) ||
                l.brand.toLowerCase().contains(q) ||
                (l.locationCity?.toLowerCase().contains(q) ?? false))
            .toList();
      }

      final brand = filters['brand'] as String?;
      if (brand != null) {
        listings = listings.where((l) => l.brand == brand).toList();
      }

      final fuelType = filters['fuel_type'] as String?;
      if (fuelType != null) {
        listings = listings.where((l) => l.fuelType == fuelType).toList();
      }

      final bodyStyle = filters['body_style'] as String?;
      if (bodyStyle != null) {
        listings = listings
            .where(
                (l) => l.bodyStyle == bodyStyle || l.vehicleType == bodyStyle)
            .toList();
      }
    }

    return listings;
  }

  @override
  Future<Listing?> getListingById(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return mockListings.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }
}
