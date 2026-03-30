import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

/// Manages Hive-based caching with TTL (time-to-live) support.
///
/// All cached data is stored as JSON strings with metadata (timestamp, TTL).
/// Expired entries are automatically purged on read.
class CacheManager {
  static const String _listingsBox = 'listings_cache';
  static const String _listingDetailBox = 'listing_detail_cache';
  static const String _categoriesBox = 'categories_cache';
  static const String _siteConfigBox = 'site_config_cache';
  static const String _wishlistBox = 'wishlist_box';
  static const String _settingsBox = 'settings_box';
  static const String _bookingsBox = 'bookings_box';

  /// Initialize Hive and open all required boxes.
  /// Must be called before any other CacheManager methods.
  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(_listingsBox),
      Hive.openBox(_listingDetailBox),
      Hive.openBox(_categoriesBox),
      Hive.openBox(_siteConfigBox),
      Hive.openBox(_wishlistBox),
      Hive.openBox(_settingsBox),
      Hive.openBox(_bookingsBox),
    ]);

    // One-time migration: clear stale wishlist data from development
    await _runMigrations();
  }

  static Future<void> _runMigrations() async {
    const migrationKey = 'wishlist_cleared_v1';
    if (getSetting(migrationKey) != 'true') {
      await clearWishlist();
      await saveSetting(migrationKey, 'true');
    }
  }

  // ---------------------------------------------------------------------------
  // Generic get/set with TTL
  // ---------------------------------------------------------------------------

  /// Store [data] in the given Hive [boxName] under [key], with an optional [ttl].
  ///
  /// Data is JSON-encoded along with a timestamp and TTL metadata.
  static Future<void> put(
    String boxName,
    String key,
    dynamic data, {
    Duration? ttl,
  }) async {
    final box = Hive.box(boxName);
    final entry = {
      'data': data is String ? data : jsonEncode(data),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'ttlMs': ttl?.inMilliseconds,
    };
    await box.put(key, jsonEncode(entry));
  }

  /// Retrieve data from [boxName] under [key].
  ///
  /// Returns `null` if:
  /// - The key does not exist
  /// - The entry has expired (TTL exceeded)
  /// - The data cannot be decoded
  ///
  /// Expired entries are automatically deleted.
  static dynamic get(String boxName, String key) {
    final box = Hive.box(boxName);
    final raw = box.get(key);
    if (raw == null) return null;

    try {
      final entry = jsonDecode(raw as String) as Map<String, dynamic>;
      final ttlMs = entry['ttlMs'] as int?;
      if (ttlMs != null) {
        final timestamp = entry['timestamp'] as int;
        final elapsed = DateTime.now().millisecondsSinceEpoch - timestamp;
        if (elapsed > ttlMs) {
          box.delete(key); // Expired — clean up
          return null;
        }
      }
      final data = entry['data'];
      if (data is String) {
        try {
          return jsonDecode(data);
        } catch (_) {
          return data; // Plain string value
        }
      }
      return data;
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Listings cache (TTL: 1 hour)
  // ---------------------------------------------------------------------------

  /// Cache a list of listing JSON maps under [cacheKey].
  static Future<void> saveListings(
    String cacheKey,
    List<Map<String, dynamic>> listings,
  ) async {
    await put(_listingsBox, cacheKey, listings,
        ttl: const Duration(hours: 1));
  }

  /// Retrieve cached listings for [cacheKey], or `null` if missing/expired.
  static List<Map<String, dynamic>>? getListings(String cacheKey) {
    final data = get(_listingsBox, cacheKey);
    if (data is List) {
      return data
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Listing detail cache (TTL: 1 hour)
  // ---------------------------------------------------------------------------

  /// Cache a single listing detail by [id].
  static Future<void> saveListingDetail(
    int id,
    Map<String, dynamic> listing,
  ) async {
    await put(_listingDetailBox, id.toString(), listing,
        ttl: const Duration(hours: 1));
  }

  /// Retrieve a cached listing detail by [id], or `null` if missing/expired.
  static Map<String, dynamic>? getListingDetail(int id) {
    final data = get(_listingDetailBox, id.toString());
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Categories cache (TTL: 24 hours)
  // ---------------------------------------------------------------------------

  /// Cache the full list of categories.
  static Future<void> saveCategories(
    List<Map<String, dynamic>> categories,
  ) async {
    await put(_categoriesBox, 'all', categories,
        ttl: const Duration(hours: 24));
  }

  /// Retrieve cached categories, or `null` if missing/expired.
  static List<Map<String, dynamic>>? getCategories() {
    final data = get(_categoriesBox, 'all');
    if (data is List) {
      return data
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Site config cache (TTL: 6 hours)
  // ---------------------------------------------------------------------------

  /// Cache the site configuration.
  static Future<void> saveSiteConfig(Map<String, dynamic> config) async {
    await put(_siteConfigBox, 'config', config,
        ttl: const Duration(hours: 6));
  }

  /// Retrieve cached site configuration, or `null` if missing/expired.
  static Map<String, dynamic>? getSiteConfig() {
    final data = get(_siteConfigBox, 'config');
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Wishlist (permanent — no TTL)
  // ---------------------------------------------------------------------------

  /// Persist the list of wishlisted listing IDs.
  static Future<void> saveWishlistIds(List<int> ids) async {
    final box = Hive.box(_wishlistBox);
    await box.put('ids', jsonEncode(ids));
  }

  /// Retrieve persisted wishlist IDs. Returns empty list if none saved.
  static List<int> getWishlistIds() {
    final box = Hive.box(_wishlistBox);
    final raw = box.get('ids');
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw as String);
      if (decoded is List) {
        return decoded.map((e) => e as int).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Clear the wishlist (used on logout or to remove stale data).
  static Future<void> clearWishlist() async {
    final box = Hive.box(_wishlistBox);
    await box.delete('ids');
  }

  // ---------------------------------------------------------------------------
  // Bookings (permanent — no TTL)
  // ---------------------------------------------------------------------------

  /// Save a test drive booking.
  static Future<void> saveBooking(Map<String, dynamic> booking) async {
    final box = Hive.box(_bookingsBox);
    final raw = box.get('bookings');
    List<dynamic> bookings = [];
    if (raw != null) {
      try {
        bookings = List<dynamic>.from(jsonDecode(raw as String) as List);
      } catch (_) {}
    }
    bookings.add(booking);
    await box.put('bookings', jsonEncode(bookings));
  }

  /// Retrieve all saved bookings.
  static List<Map<String, dynamic>> getBookings() {
    final box = Hive.box(_bookingsBox);
    final raw = box.get('bookings');
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw as String) as List;
      return decoded
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Settings (permanent — no TTL)
  // ---------------------------------------------------------------------------

  /// Save a string setting by [key].
  static Future<void> saveSetting(String key, String value) async {
    final box = Hive.box(_settingsBox);
    await box.put(key, value);
  }

  /// Retrieve a string setting by [key], or `null` if not set.
  static String? getSetting(String key) {
    final box = Hive.box(_settingsBox);
    return box.get(key) as String?;
  }

  // ---------------------------------------------------------------------------
  // Convenience: Server URL
  // ---------------------------------------------------------------------------

  /// Save the backend server base URL.
  static Future<void> saveServerUrl(String url) =>
      saveSetting('server_base_url', url);

  /// Retrieve the saved server base URL, or `null` if not configured.
  static String? getServerUrl() => getSetting('server_base_url');

  // ---------------------------------------------------------------------------
  // Convenience: Onboarding
  // ---------------------------------------------------------------------------

  /// Mark onboarding as completed.
  static Future<void> setOnboardingDone() =>
      saveSetting('onboarding_done', 'true');

  /// Whether the user has completed onboarding.
  static bool isOnboardingDone() => getSetting('onboarding_done') == 'true';

  // ---------------------------------------------------------------------------
  // Cache clearing
  // ---------------------------------------------------------------------------

  /// Clear all data caches (listings, categories, site config).
  /// Preserves wishlist and settings.
  static Future<void> clearAll() async {
    await Future.wait([
      Hive.box(_listingsBox).clear(),
      Hive.box(_listingDetailBox).clear(),
      Hive.box(_categoriesBox).clear(),
      Hive.box(_siteConfigBox).clear(),
    ]);
  }

  /// Clear everything including wishlist and settings.
  static Future<void> clearEverything() async {
    await clearAll();
    await Future.wait([
      Hive.box(_wishlistBox).clear(),
      Hive.box(_settingsBox).clear(),
    ]);
  }
}
