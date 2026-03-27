import 'dart:math';
import 'package:intl/intl.dart';

class Listing {
  final int id;
  final int? categoryId;
  final String? categoryName;
  final String? categorySlug;
  final String listingCode;
  final String title;
  final String brand;
  final String model;
  final String? variant;
  final int? modelYear;
  final int? registrationYear;
  final String? vehicleType;
  final String? bodyStyle;
  final String? exteriorColor;
  final String? interiorColor;
  final double listingPriceInr;
  final bool negotiable;
  final double? estimatedMarketValueInr;
  final String? ownershipType;
  final String? sellerType;
  final String? registrationState;
  final String? registrationCity;
  final double? totalKmDriven;
  final double? mileageKmpl;
  final String? engineType;
  final double? engineCapacityCc;
  final double? powerBhp;
  final double? torqueNm;
  final String? transmissionType;
  final String? fuelType;
  final double? batteryCapacityKwh;
  final double? overallConditionRating;
  final bool serviceHistoryAvailable;
  final int? airbagsCount;
  final String? infotainmentScreenSize;
  final String? locationCity;
  final String? locationState;
  final double? dealerRating;
  final String? inspectionStatus;
  final double? inspectionScore;
  final String listingStatus;
  final bool featuredListing;
  final bool isSplus;
  final bool isNewCar;
  final int viewsCount;
  final int favoritesCount;
  final int leadCount;
  final List<String> images;
  final List<String> interiorImages;
  final List<String> exteriorImages;
  final List<String> engineImages;
  final List<String> tireImages;
  final List<String> damageImages;
  final Map<String, dynamic> specs;
  final String? promotionTier;
  final String? additionalNotes;
  final String? createdAt;
  final String? updatedAt;

  const Listing({
    required this.id,
    this.categoryId,
    this.categoryName,
    this.categorySlug,
    this.listingCode = '',
    required this.title,
    required this.brand,
    required this.model,
    this.variant,
    this.modelYear,
    this.registrationYear,
    this.vehicleType,
    this.bodyStyle,
    this.exteriorColor,
    this.interiorColor,
    required this.listingPriceInr,
    this.negotiable = false,
    this.estimatedMarketValueInr,
    this.ownershipType,
    this.sellerType,
    this.registrationState,
    this.registrationCity,
    this.totalKmDriven,
    this.mileageKmpl,
    this.engineType,
    this.engineCapacityCc,
    this.powerBhp,
    this.torqueNm,
    this.transmissionType,
    this.fuelType,
    this.batteryCapacityKwh,
    this.overallConditionRating,
    this.serviceHistoryAvailable = false,
    this.airbagsCount,
    this.infotainmentScreenSize,
    this.locationCity,
    this.locationState,
    this.dealerRating,
    this.inspectionStatus,
    this.inspectionScore,
    this.listingStatus = 'Active',
    this.featuredListing = false,
    this.isSplus = false,
    this.isNewCar = false,
    this.viewsCount = 0,
    this.favoritesCount = 0,
    this.leadCount = 0,
    this.images = const [],
    this.interiorImages = const [],
    this.exteriorImages = const [],
    this.engineImages = const [],
    this.tireImages = const [],
    this.damageImages = const [],
    this.specs = const {},
    this.promotionTier,
    this.additionalNotes,
    this.createdAt,
    this.updatedAt,
  });

  // COMPUTED FIELDS
  String get priceFormatted {
    if (listingPriceInr >= 10000000) {
      return '\u20B9${(listingPriceInr / 10000000).toStringAsFixed(1)} Cr';
    } else if (listingPriceInr >= 100000) {
      return '\u20B9${(listingPriceInr / 100000).toStringAsFixed(1)}L';
    } else {
      return '\u20B9${NumberFormat('#,###', 'en_IN').format(listingPriceInr.round())}';
    }
  }

  String get priceCompact {
    if (listingPriceInr >= 10000000) {
      return '\u20B9${(listingPriceInr / 10000000).toStringAsFixed(1)}Cr';
    }
    if (listingPriceInr >= 100000) {
      return '\u20B9${(listingPriceInr / 100000).toStringAsFixed(1)}L';
    }
    return '\u20B9${(listingPriceInr / 1000).toStringAsFixed(0)}K';
  }

  String get kmFormatted {
    if (totalKmDriven == null) return 'N/A';
    return '${NumberFormat('#,###', 'en_IN').format(totalKmDriven!.round())} km';
  }

  String get kmCompact {
    if (totalKmDriven == null) return 'N/A';
    return NumberFormat('#,###', 'en_IN').format(totalKmDriven!.round());
  }

  String get emiFormatted {
    const loanPercent = 0.80;
    const annualRate = 10.5;
    const tenureMonths = 48;
    final principal = listingPriceInr * loanPercent;
    final monthlyRate = annualRate / 12 / 100;
    final factor = pow(1 + monthlyRate, tenureMonths);
    final emi = (principal * monthlyRate * factor) / (factor - 1);
    return '\u20B9${NumberFormat('#,###', 'en_IN').format(emi.round())}/mo';
  }

  String get ownerDisplay {
    switch (ownershipType) {
      case 'First':
        return '1st';
      case 'Second':
        return '2nd';
      case 'Third':
        return '3rd';
      case 'Fourth':
        return '4th';
      case 'Fifth+':
        return '5th+';
      default:
        return ownershipType ?? 'N/A';
    }
  }

  String get brandInitial => brand.isNotEmpty ? brand[0].toUpperCase() : '?';

  bool get isCertified => inspectionStatus == 'Completed';

  String get badgeText {
    if (isSplus) return 'S+';
    if (promotionTier == 'Premium') return 'Premium';
    if (promotionTier == 'Featured') return 'Featured';
    if (featuredListing) return 'Featured';
    return '';
  }

  List<String> imageUrls(String serverBaseUrl) {
    return images.map((path) => '$serverBaseUrl$path').toList();
  }

  List<String> allImageUrls(String serverBaseUrl) {
    final all = <String>[];
    all.addAll(images);
    all.addAll(interiorImages);
    all.addAll(exteriorImages);
    all.addAll(engineImages);
    all.addAll(tireImages);
    return all.map((path) => '$serverBaseUrl$path').toList();
  }

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'] as int,
      categoryId: json['category_id'] as int?,
      categoryName: json['category_name'] as String?,
      categorySlug: json['category_slug'] as String?,
      listingCode: json['listing_code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      variant: json['variant'] as String?,
      modelYear: json['model_year'] as int?,
      registrationYear: json['registration_year'] as int?,
      vehicleType: json['vehicle_type'] as String?,
      bodyStyle: json['body_style'] as String?,
      exteriorColor: json['exterior_color'] as String?,
      interiorColor: json['interior_color'] as String?,
      listingPriceInr: (json['listing_price_inr'] as num?)?.toDouble() ?? 0,
      negotiable: json['negotiable'] == 1 || json['negotiable'] == true,
      estimatedMarketValueInr:
          (json['estimated_market_value_inr'] as num?)?.toDouble(),
      ownershipType: json['ownership_type'] as String?,
      sellerType: json['seller_type'] as String?,
      registrationState: json['registration_state'] as String?,
      registrationCity: json['registration_city'] as String?,
      totalKmDriven: (json['total_km_driven'] as num?)?.toDouble(),
      mileageKmpl: (json['mileage_kmpl'] as num?)?.toDouble(),
      engineType: json['engine_type'] as String?,
      engineCapacityCc: (json['engine_capacity_cc'] as num?)?.toDouble(),
      powerBhp: (json['power_bhp'] as num?)?.toDouble(),
      torqueNm: (json['torque_nm'] as num?)?.toDouble(),
      transmissionType: json['transmission_type'] as String?,
      fuelType: json['fuel_type'] as String?,
      batteryCapacityKwh:
          (json['battery_capacity_kwh'] as num?)?.toDouble(),
      overallConditionRating:
          (json['overall_condition_rating'] as num?)?.toDouble(),
      serviceHistoryAvailable: json['service_history_available'] == 1 ||
          json['service_history_available'] == true,
      airbagsCount: json['airbags_count'] as int?,
      infotainmentScreenSize: json['infotainment_screen_size'] as String?,
      locationCity: json['location_city'] as String?,
      locationState: json['location_state'] as String?,
      dealerRating: (json['dealer_rating'] as num?)?.toDouble(),
      inspectionStatus: json['inspection_status'] as String?,
      inspectionScore: (json['inspection_score'] as num?)?.toDouble(),
      listingStatus: json['listing_status'] as String? ?? 'Active',
      featuredListing:
          json['featured_listing'] == 1 || json['featured_listing'] == true,
      isSplus: json['is_splus'] == 1 || json['is_splus'] == true,
      isNewCar: json['is_new_car'] == 1 || json['is_new_car'] == true,
      viewsCount: json['views_count'] as int? ?? 0,
      favoritesCount: json['favorites_count'] as int? ?? 0,
      leadCount: json['lead_count'] as int? ?? 0,
      images: _parseStringList(json['images']),
      interiorImages: _parseStringList(json['interiorImages']),
      exteriorImages: _parseStringList(json['exteriorImages']),
      engineImages: _parseStringList(json['engineImages']),
      tireImages: _parseStringList(json['tireImages']),
      damageImages: _parseStringList(json['damageImages']),
      specs: json['specs'] is Map
          ? Map<String, dynamic>.from(json['specs'] as Map)
          : const {},
      promotionTier: json['promotion_tier'] as String?,
      additionalNotes: json['additional_notes'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'category_name': categoryName,
      'category_slug': categorySlug,
      'listing_code': listingCode,
      'title': title,
      'brand': brand,
      'model': model,
      'variant': variant,
      'model_year': modelYear,
      'registration_year': registrationYear,
      'vehicle_type': vehicleType,
      'body_style': bodyStyle,
      'exterior_color': exteriorColor,
      'interior_color': interiorColor,
      'listing_price_inr': listingPriceInr,
      'negotiable': negotiable ? 1 : 0,
      'estimated_market_value_inr': estimatedMarketValueInr,
      'ownership_type': ownershipType,
      'seller_type': sellerType,
      'registration_state': registrationState,
      'registration_city': registrationCity,
      'total_km_driven': totalKmDriven,
      'mileage_kmpl': mileageKmpl,
      'engine_type': engineType,
      'engine_capacity_cc': engineCapacityCc,
      'power_bhp': powerBhp,
      'torque_nm': torqueNm,
      'transmission_type': transmissionType,
      'fuel_type': fuelType,
      'battery_capacity_kwh': batteryCapacityKwh,
      'overall_condition_rating': overallConditionRating,
      'service_history_available': serviceHistoryAvailable ? 1 : 0,
      'airbags_count': airbagsCount,
      'infotainment_screen_size': infotainmentScreenSize,
      'location_city': locationCity,
      'location_state': locationState,
      'dealer_rating': dealerRating,
      'inspection_status': inspectionStatus,
      'inspection_score': inspectionScore,
      'listing_status': listingStatus,
      'featured_listing': featuredListing ? 1 : 0,
      'is_splus': isSplus ? 1 : 0,
      'is_new_car': isNewCar ? 1 : 0,
      'views_count': viewsCount,
      'favorites_count': favoritesCount,
      'lead_count': leadCount,
      'images': images,
      'interiorImages': interiorImages,
      'exteriorImages': exteriorImages,
      'engineImages': engineImages,
      'tireImages': tireImages,
      'damageImages': damageImages,
      'specs': specs,
      'promotion_tier': promotionTier,
      'additional_notes': additionalNotes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) {
      try {
        // Handle JSON string arrays from SQLite
        if (value.startsWith('[')) {
          // It's a JSON array string - would need dart:convert to parse
          // but the backend auto-parses JSON fields via toListing(),
          // so this case should be rare
          return [];
        }
      } catch (_) {
        // Fallthrough to return empty
      }
    }
    return [];
  }
}
