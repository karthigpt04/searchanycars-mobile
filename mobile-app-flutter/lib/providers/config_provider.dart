import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/site_config.dart';
import '../models/category.dart';
import '../services/api/api_config_service.dart';
import '../utils/cache_manager.dart';
import 'connectivity_provider.dart';

/// Provides the site configuration from API, cache, or defaults.
///
/// Priority: live API (when connected) > Hive cache > empty defaults.
final siteConfigProvider = FutureProvider<SiteConfig>((ref) async {
  final connectivity = ref.watch(connectivityProvider);

  // Try fetching from the API when connected
  if (connectivity.isConnected) {
    try {
      final config = await ApiConfigService().getSiteConfig();
      if (config != null) {
        await CacheManager.saveSiteConfig(config.toJson());
        return config;
      }
    } catch (_) {
      // Fall through to cache
    }
  }

  // Fallback to cache
  final cached = CacheManager.getSiteConfig();
  if (cached != null) {
    return SiteConfig.fromJson(cached);
  }

  // Default fallback — empty config with sensible site name
  return const SiteConfig();
});

/// Provides vehicle categories from API, cache, or hardcoded defaults.
///
/// Priority: live API (when connected) > Hive cache > seed categories.
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final connectivity = ref.watch(connectivityProvider);

  // Try fetching from the API when connected
  if (connectivity.isConnected) {
    try {
      final categories = await ApiConfigService().getCategories();
      if (categories.isNotEmpty) {
        await CacheManager.saveCategories(
          categories.map((c) => c.toJson()).toList(),
        );
        return categories;
      }
    } catch (_) {
      // Fall through to cache
    }
  }

  // Fallback to cache
  final cached = CacheManager.getCategories();
  if (cached != null) {
    return cached.map((c) => Category.fromJson(c)).toList();
  }

  // Hardcoded seed categories matching the backend
  return const [
    Category(id: 1, name: 'Hatchback', slug: 'hatchback'),
    Category(id: 2, name: 'Sedan', slug: 'sedan'),
    Category(id: 3, name: 'SUV', slug: 'suv'),
    Category(id: 4, name: 'MUV', slug: 'muv'),
    Category(id: 5, name: 'Coupe', slug: 'coupe'),
    Category(id: 6, name: 'Pickup', slug: 'pickup'),
    Category(id: 7, name: 'Luxury Sedan', slug: 'luxury-sedan'),
    Category(id: 8, name: 'Luxury SUV', slug: 'luxury-suv'),
  ];
});
