import '../models/car.dart';
import '../models/listing.dart';

/// Converts a [Listing] (from the API/repository layer) into a [Car]
/// (the display model used by CarCard and CarListItem widgets).
///
/// This bridge allows the existing card widgets to render API data
/// without requiring a full widget rewrite.
Car listingToCar(Listing l, {String serverBaseUrl = ''}) {
  final imageUrls = l.imageUrls(serverBaseUrl);
  return Car(
    id: l.id,
    name: l.title,
    brand: l.brand,
    year: l.modelYear ?? 0,
    price: l.priceCompact.replaceAll('\u20B9', ''),
    km: l.kmCompact,
    fuel: l.fuelType ?? 'N/A',
    transmission: l.transmissionType ?? 'N/A',
    owner: l.ownerDisplay,
    city: l.locationCity ?? 'N/A',
    rating: (l.overallConditionRating ?? 8) / 2,
    color: _colorForBrand(l.brand),
    badge: l.badgeText,
    emi: l.emiFormatted,
    certified: l.isCertified,
    imageUrl: imageUrls.isNotEmpty ? imageUrls.first : null,
    inspection: InspectionReport(
      overallScore: (l.inspectionScore ?? 90) / 20, // Convert 0-100 to 0-5
      categories: const [
        InspectionCategory(name: 'Engine & Transmission', score: 95),
        InspectionCategory(name: 'Exterior & Body', score: 88),
        InspectionCategory(name: 'Interior & Electronics', score: 92),
        InspectionCategory(name: 'Tyres & Suspension', score: 85),
      ],
    ),
    dealer: DealerSummary(
      id: 'd${l.id}',
      name: l.sellerType ?? 'Dealer',
      rating: l.dealerRating ?? 4.5,
      city: l.locationCity ?? 'N/A',
      initial: (l.sellerType ?? 'D').isNotEmpty
          ? (l.sellerType ?? 'D')[0]
          : 'D',
    ),
  );
}

/// Maps brand names to representative hex colours used by CarCard
/// gradient backgrounds.
String _colorForBrand(String brand) {
  const colors = {
    'Mercedes': '#C0C0C0',
    'Mercedes-Benz': '#C0C0C0',
    'BMW': '#1E3A5F',
    'Audi': '#2D2D2D',
    'Toyota': '#F5F5DC',
    'Hyundai': '#8B0000',
    'Tata': '#1B4332',
    'Kia': '#4A4A4A',
    'Mahindra': '#8B4513',
    'Honda': '#B22222',
    'Maruti': '#2F4F4F',
    'Maruti Suzuki': '#2F4F4F',
    'Volkswagen': '#1C1C6B',
    'Ford': '#003478',
    'Renault': '#FFD700',
    'Skoda': '#006400',
    'Nissan': '#C3002F',
    'MG': '#D4A853',
    'Jeep': '#4A6741',
    'Lexus': '#1A1A2E',
    'Volvo': '#003057',
    'Jaguar': '#006633',
    'Land Rover': '#004225',
    'Porsche': '#B12B28',
    'Mini': '#000000',
    'Citro\u00EBn': '#A01830',
  };
  return colors[brand] ?? '#5A5A7A';
}
