import '../../models/site_config.dart';
import '../../models/category.dart';
import '../../models/filter_definition.dart';

abstract class ConfigService {
  Future<SiteConfig?> getSiteConfig();
  Future<List<Category>> getCategories();
  Future<List<FilterDefinition>> getFilterDefinitions();
  Future<List<FilterDefinition>> getCategoryFilters(int categoryId);
}
