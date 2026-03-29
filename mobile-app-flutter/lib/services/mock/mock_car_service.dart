import '../../models/listing.dart';
import '../../models/mock_data.dart';
import '../interfaces/car_service.dart';

class MockCarService implements CarService {
  /// Convert mock Car objects to Listing objects for a unified interface
  static List<Listing> get mockListings {
    final normalListings = MockData.cars.map((car) {
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

    return [...normalListings, ..._mockSplusListings, ..._mockNewCarListings];
  }

  /// S+ Premium pre-owned mock listings
  static final List<Listing> _mockSplusListings = [
    const Listing(
      id: 101,
      listingCode: 'SAC-SP-001',
      title: '2023 BMW X5 xDrive40i M Sport',
      brand: 'BMW',
      model: 'X5',
      variant: 'xDrive40i M Sport',
      modelYear: 2023,
      listingPriceInr: 7500000,
      totalKmDriven: 12000,
      fuelType: 'Petrol',
      transmissionType: 'Automatic',
      ownershipType: 'First',
      locationCity: 'Mumbai',
      locationState: 'Maharashtra',
      bodyStyle: 'SUV',
      vehicleType: 'SUV',
      engineType: '3.0L Turbo Petrol',
      powerBhp: 340,
      inspectionStatus: 'Completed',
      inspectionScore: 95,
      overallConditionRating: 9.5,
      dealerRating: 4.9,
      sellerType: 'Certified Dealer',
      featuredListing: true,
      isSplus: true,
      isNewCar: false,
      promotionTier: 'Premium',
      listingStatus: 'Active',
    ),
    const Listing(
      id: 102,
      listingCode: 'SAC-SP-002',
      title: '2023 Mercedes-Benz GLC 300 AMG',
      brand: 'Mercedes-Benz',
      model: 'GLC',
      variant: '300 AMG Line',
      modelYear: 2023,
      listingPriceInr: 6800000,
      totalKmDriven: 8500,
      fuelType: 'Petrol',
      transmissionType: 'Automatic',
      ownershipType: 'First',
      locationCity: 'New Delhi',
      locationState: 'Delhi',
      bodyStyle: 'SUV',
      vehicleType: 'SUV',
      engineType: '2.0L Turbo Petrol',
      powerBhp: 258,
      inspectionStatus: 'Completed',
      inspectionScore: 93,
      overallConditionRating: 9.2,
      dealerRating: 4.8,
      sellerType: 'Certified Dealer',
      featuredListing: true,
      isSplus: true,
      isNewCar: false,
      promotionTier: 'Premium',
      listingStatus: 'Active',
    ),
  ];

  /// S+ New (brand new / unregistered / demo) mock listings
  static final List<Listing> _mockNewCarListings = [
    const Listing(
      id: 201,
      listingCode: 'SAC-NC-001',
      title: '2025 Mercedes-Benz GLE 300d 4MATIC',
      brand: 'Mercedes-Benz',
      model: 'GLE',
      variant: '300d 4MATIC LWB',
      modelYear: 2025,
      listingPriceInr: 9650000,
      totalKmDriven: 12,
      fuelType: 'Diesel',
      transmissionType: 'Automatic',
      locationCity: 'Mumbai',
      locationState: 'Maharashtra',
      bodyStyle: 'Luxury SUV',
      vehicleType: 'SUV',
      engineType: '2.0L Diesel',
      powerBhp: 269,
      inspectionStatus: 'Factory New',
      inspectionScore: 100,
      overallConditionRating: 10,
      dealerRating: 4.9,
      sellerType: 'Authorized Dealer',
      featuredListing: true,
      isSplus: true,
      isNewCar: true,
      newCarType: 'Unregistered',
      promotionTier: 'Premium',
      listingStatus: 'Active',
    ),
    const Listing(
      id: 202,
      listingCode: 'SAC-NC-002',
      title: '2025 BMW X3 xDrive20d M Sport',
      brand: 'BMW',
      model: 'X3',
      variant: 'xDrive20d M Sport',
      modelYear: 2025,
      listingPriceInr: 7490000,
      totalKmDriven: 22,
      fuelType: 'Diesel',
      transmissionType: 'Automatic',
      locationCity: 'Bengaluru',
      locationState: 'Karnataka',
      bodyStyle: 'Luxury SUV',
      vehicleType: 'SUV',
      engineType: '2.0L Diesel',
      powerBhp: 190,
      inspectionStatus: 'Factory New',
      inspectionScore: 100,
      overallConditionRating: 10,
      dealerRating: 4.8,
      sellerType: 'Authorized Dealer',
      featuredListing: true,
      isSplus: true,
      isNewCar: true,
      newCarType: 'Demo',
      promotionTier: 'Premium',
      listingStatus: 'Active',
    ),
    const Listing(
      id: 203,
      listingCode: 'SAC-NC-003',
      title: '2025 Audi Q5 45 TFSI quattro',
      brand: 'Audi',
      model: 'Q5',
      variant: '45 TFSI quattro',
      modelYear: 2025,
      listingPriceInr: 7190000,
      totalKmDriven: 5,
      fuelType: 'Petrol',
      transmissionType: 'Automatic',
      locationCity: 'Chennai',
      locationState: 'Tamil Nadu',
      bodyStyle: 'Luxury SUV',
      vehicleType: 'SUV',
      engineType: '2.0L TFSI Petrol',
      powerBhp: 265,
      inspectionStatus: 'Factory New',
      inspectionScore: 100,
      overallConditionRating: 10,
      dealerRating: 4.7,
      sellerType: 'Authorized Dealer',
      featuredListing: true,
      isSplus: true,
      isNewCar: true,
      newCarType: 'Unregistered',
      promotionTier: 'Premium',
      listingStatus: 'Active',
    ),
  ];

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

      // S+ filter
      final isSplus = filters['is_splus'];
      if (isSplus != null && (isSplus == 1 || isSplus == '1')) {
        listings = listings.where((l) => l.isSplus).toList();
      }

      // New car filter
      final isNewCar = filters['is_new_car'];
      if (isNewCar != null && (isNewCar == 1 || isNewCar == '1')) {
        listings = listings.where((l) => l.isNewCar).toList();
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
