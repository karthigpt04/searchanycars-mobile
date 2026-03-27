import 'dart:developer' as dev;
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

class DioClient {
  static Dio? _instance;
  static String? _baseUrl;
  static PersistCookieJar? _cookieJar;

  static Future<void> initialize(String baseUrl) async {
    _baseUrl = baseUrl;
    _instance = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    // Set up persistent cookie jar for HTTP-only cookie auth
    if (_cookieJar == null) {
      try {
        final appDocDir = await getApplicationDocumentsDirectory();
        _cookieJar = PersistCookieJar(
          storage: FileStorage('${appDocDir.path}/.cookies/'),
        );
      } catch (_) {
        // Fallback to in-memory cookie jar if file storage fails
        _cookieJar = PersistCookieJar();
      }
    }
    _instance!.interceptors.add(CookieManager(_cookieJar!));

    // Add logging interceptor in debug mode
    assert(() {
      _instance!.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => dev.log(obj.toString(), name: 'DIO'),
      ));
      return true;
    }());
  }

  /// Synchronous initialization without cookie persistence (for quick health checks)
  static void initializeSync(String baseUrl) {
    _baseUrl = baseUrl;
    _instance = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));
  }

  static Dio get instance {
    if (_instance == null) {
      throw StateError('DioClient not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static String get baseUrl => _baseUrl ?? '';

  static bool get isInitialized => _instance != null;

  static PersistCookieJar? get cookieJar => _cookieJar;

  static void reset() {
    _instance?.close();
    _instance = null;
    _baseUrl = null;
  }

  /// Clear all stored cookies (used on logout)
  static Future<void> clearCookies() async {
    await _cookieJar?.deleteAll();
  }

  /// Check server health
  static Future<bool> checkHealth() async {
    if (!isInitialized) return false;
    try {
      final response = await instance.get('/api/health');
      return response.statusCode == 200 && response.data?['ok'] == true;
    } catch (_) {
      return false;
    }
  }
}
