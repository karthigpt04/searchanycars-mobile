import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/site_config.dart';
import '../models/category.dart';
import '../models/filter_definition.dart';
import '../providers/connectivity_provider.dart';
import '../services/api/api_config_service.dart';
import '../utils/cache_manager.dart';

class ConfigRepository {
  final bool isConnected;

  ConfigRepository({required this.isConnected});

  Future<SiteConfig> getSiteConfig() async {
    if (isConnected) {
      try {
        final config = await ApiConfigService().getSiteConfig();
        if (config != null) {
          await CacheManager.saveSiteConfig(config.toJson());
          return config;
        }
      } catch (_) {}
    }

    // Fallback to cache
    final cached = CacheManager.getSiteConfig();
    if (cached != null) {
      return SiteConfig.fromJson(cached);
    }

    return const SiteConfig();
  }

  Future<List<Category>> getCategories() async {
    if (isConnected) {
      try {
        final categories = await ApiConfigService().getCategories();
        if (categories.isNotEmpty) {
          await CacheManager.saveCategories(
            categories.map((c) => c.toJson()).toList(),
          );
          return categories;
        }
      } catch (_) {}
    }

    final cached = CacheManager.getCategories();
    if (cached != null) {
      return cached.map((c) => Category.fromJson(c)).toList();
    }

    return _defaultCategories;
  }

  Future<List<FilterDefinition>> getFilterDefinitions() async {
    if (isConnected) {
      try {
        return await ApiConfigService().getFilterDefinitions();
      } catch (_) {}
    }
    return [];
  }

  static const _defaultCategories = [
    Category(id: 1, name: 'Hatchback', slug: 'hatchback'),
    Category(id: 2, name: 'Sedan', slug: 'sedan'),
    Category(id: 3, name: 'SUV', slug: 'suv'),
    Category(id: 4, name: 'MUV', slug: 'muv'),
    Category(id: 5, name: 'Coupe', slug: 'coupe'),
    Category(id: 6, name: 'Pickup', slug: 'pickup'),
    Category(id: 7, name: 'Luxury Sedan', slug: 'luxury-sedan'),
    Category(id: 8, name: 'Luxury SUV', slug: 'luxury-suv'),
  ];
}

final configRepositoryProvider = Provider<ConfigRepository>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return ConfigRepository(isConnected: connectivity.isConnected);
});
