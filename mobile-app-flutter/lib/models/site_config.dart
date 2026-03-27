class SiteConfig {
  final String siteName;
  final HeroConfig? hero;
  final List<TrustBarItem> trustBar;
  final List<BudgetBracket> budgetBrackets;
  final List<BodyTypeConfig> bodyTypes;
  final List<FuelTypeConfig> fuelTypes;
  final List<CityConfig> cities;
  final List<ReviewConfig> reviews;
  final ContactInfo? contactInfo;

  const SiteConfig({
    this.siteName = 'SearchAnyCars',
    this.hero,
    this.trustBar = const [],
    this.budgetBrackets = const [],
    this.bodyTypes = const [],
    this.fuelTypes = const [],
    this.cities = const [],
    this.reviews = const [],
    this.contactInfo,
  });

  factory SiteConfig.fromJson(Map<String, dynamic> json) {
    return SiteConfig(
      siteName: json['site_name'] as String? ?? 'SearchAnyCars',
      hero: json['hero'] is Map
          ? HeroConfig.fromJson(Map<String, dynamic>.from(json['hero'] as Map))
          : null,
      trustBar: _parseList(json['trust_bar'], TrustBarItem.fromJson),
      budgetBrackets:
          _parseList(json['budget_brackets'], BudgetBracket.fromJson),
      bodyTypes: _parseList(json['body_types'], BodyTypeConfig.fromJson),
      fuelTypes: _parseList(json['fuel_types'], FuelTypeConfig.fromJson),
      cities: _parseList(json['cities'], CityConfig.fromJson),
      reviews: _parseList(json['reviews'], ReviewConfig.fromJson),
      contactInfo: json['contact_info'] is Map
          ? ContactInfo.fromJson(
              Map<String, dynamic>.from(json['contact_info'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'site_name': siteName,
        'hero': hero?.toJson(),
        'trust_bar': trustBar.map((e) => e.toJson()).toList(),
        'budget_brackets': budgetBrackets.map((e) => e.toJson()).toList(),
        'body_types': bodyTypes.map((e) => e.toJson()).toList(),
        'fuel_types': fuelTypes.map((e) => e.toJson()).toList(),
        'cities': cities.map((e) => e.toJson()).toList(),
        'reviews': reviews.map((e) => e.toJson()).toList(),
        'contact_info': contactInfo?.toJson(),
      };

  static List<T> _parseList<T>(
      dynamic value, T Function(Map<String, dynamic>) fromJson) {
    if (value is! List) return [];
    return value
        .whereType<Map>()
        .map((e) => fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

class HeroConfig {
  final String title;
  final String subtitle;

  const HeroConfig({this.title = '', this.subtitle = ''});

  factory HeroConfig.fromJson(Map<String, dynamic> json) => HeroConfig(
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'title': title, 'subtitle': subtitle};
}

class TrustBarItem {
  final String icon;
  final String label;
  final String? iconClass;

  const TrustBarItem({this.icon = '', this.label = '', this.iconClass});

  factory TrustBarItem.fromJson(Map<String, dynamic> json) => TrustBarItem(
        icon: json['icon'] as String? ?? '',
        label: json['label'] as String? ?? '',
        iconClass: json['iconClass'] as String?,
      );

  Map<String, dynamic> toJson() =>
      {'icon': icon, 'label': label, 'iconClass': iconClass};
}

class BudgetBracket {
  final String label;
  final int min;
  final int max;

  const BudgetBracket({this.label = '', this.min = 0, this.max = 0});

  factory BudgetBracket.fromJson(Map<String, dynamic> json) => BudgetBracket(
        label: json['label'] as String? ?? '',
        min: json['min'] as int? ?? 0,
        max: json['max'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {'label': label, 'min': min, 'max': max};
}

class BodyTypeConfig {
  final String name;
  final String icon;
  final String count;

  const BodyTypeConfig({this.name = '', this.icon = '', this.count = ''});

  factory BodyTypeConfig.fromJson(Map<String, dynamic> json) => BodyTypeConfig(
        name: json['name'] as String? ?? '',
        icon: json['icon'] as String? ?? '',
        count: json['count']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() =>
      {'name': name, 'icon': icon, 'count': count};
}

class FuelTypeConfig {
  final String name;
  final String icon;
  final String count;

  const FuelTypeConfig({this.name = '', this.icon = '', this.count = ''});

  factory FuelTypeConfig.fromJson(Map<String, dynamic> json) => FuelTypeConfig(
        name: json['name'] as String? ?? '',
        icon: json['icon'] as String? ?? '',
        count: json['count']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() =>
      {'name': name, 'icon': icon, 'count': count};
}

class CityConfig {
  final String name;
  final String slug;
  final String count;
  final String? image;

  const CityConfig(
      {this.name = '', this.slug = '', this.count = '', this.image});

  factory CityConfig.fromJson(Map<String, dynamic> json) => CityConfig(
        name: json['name'] as String? ?? '',
        slug: json['slug'] as String? ?? '',
        count: json['count']?.toString() ?? '',
        image: json['image'] as String?,
      );

  Map<String, dynamic> toJson() =>
      {'name': name, 'slug': slug, 'count': count, 'image': image};
}

class ReviewConfig {
  final String name;
  final String city;
  final String car;
  final String text;
  final int rating;

  const ReviewConfig({
    this.name = '',
    this.city = '',
    this.car = '',
    this.text = '',
    this.rating = 5,
  });

  factory ReviewConfig.fromJson(Map<String, dynamic> json) => ReviewConfig(
        name: json['name'] as String? ?? '',
        city: json['city'] as String? ?? '',
        car: json['car'] as String? ?? '',
        text: json['text'] as String? ?? '',
        rating: json['rating'] as int? ?? 5,
      );

  Map<String, dynamic> toJson() =>
      {'name': name, 'city': city, 'car': car, 'text': text, 'rating': rating};
}

class ContactInfo {
  final String? phone;
  final String? whatsapp;
  final String? email;
  final String? address;

  const ContactInfo({this.phone, this.whatsapp, this.email, this.address});

  factory ContactInfo.fromJson(Map<String, dynamic> json) => ContactInfo(
        phone: json['phone'] as String?,
        whatsapp: json['whatsapp'] as String?,
        email: json['email'] as String?,
        address: json['address'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'whatsapp': whatsapp,
        'email': email,
        'address': address,
      };
}
