import 'package:dio/dio.dart';
import '../../models/site_config.dart';
import '../../models/category.dart';
import '../../models/filter_definition.dart';
import '../interfaces/config_service.dart';
import 'dio_client.dart';

class ApiConfigService implements ConfigService {
  @override
  Future<SiteConfig?> getSiteConfig() async {
    try {
      final response = await DioClient.instance.get('/api/site-config');
      if (response.data != null) {
        return SiteConfig.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      final response = await DioClient.instance.get('/api/categories');
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Category.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<List<FilterDefinition>> getFilterDefinitions() async {
    try {
      final response = await DioClient.instance.get('/api/filter-definitions');
      if (response.data is List) {
        return (response.data as List)
            .map((json) =>
                FilterDefinition.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<List<FilterDefinition>> getCategoryFilters(int categoryId) async {
    try {
      final response =
          await DioClient.instance.get('/api/category-filters/$categoryId');
      if (response.data is List) {
        return (response.data as List)
            .map((json) =>
                FilterDefinition.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException {
      rethrow;
    }
  }
}
