class Car {
  final int id;
  final String name;
  final String brand;
  final int year;
  final String price;
  final String km;
  final String fuel;
  final String transmission;
  final String owner;
  final String city;
  final double rating;
  final String color;
  final String badge;
  final String emi;
  final bool certified;
  final String? imageUrl;
  final InspectionReport inspection;
  final DealerSummary dealer;

  const Car({
    required this.id,
    required this.name,
    required this.brand,
    required this.year,
    required this.price,
    required this.km,
    required this.fuel,
    required this.transmission,
    required this.owner,
    required this.city,
    required this.rating,
    required this.color,
    required this.badge,
    required this.emi,
    this.certified = true,
    this.imageUrl,
    required this.inspection,
    required this.dealer,
  });
}

class InspectionReport {
  final double overallScore;
  final int totalPoints;
  final bool passed;
  final List<InspectionCategory> categories;

  const InspectionReport({
    required this.overallScore,
    this.totalPoints = 200,
    this.passed = true,
    required this.categories,
  });
}

class InspectionCategory {
  final String name;
  final int score;

  const InspectionCategory({required this.name, required this.score});
}

class DealerSummary {
  final String id;
  final String name;
  final double rating;
  final String city;
  final String badge;
  final String initial;

  const DealerSummary({
    required this.id,
    required this.name,
    required this.rating,
    required this.city,
    this.badge = 'Trusted Dealer',
    required this.initial,
  });
}
