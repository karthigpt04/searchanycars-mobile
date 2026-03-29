import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api/dio_client.dart';
import '../utils/cache_manager.dart';

/// Represents the current connectivity status to the backend server.
enum ConnectivityStatus { unknown, connected, disconnected, reconnecting }

/// Immutable state holding the server URL and current connectivity status.
class ConnectivityState {
  final ConnectivityStatus status;
  final String? serverUrl;
  final bool isInitialized;

  const ConnectivityState({
    this.status = ConnectivityStatus.unknown,
    this.serverUrl,
    this.isInitialized = false,
  });

  /// Whether the app is currently connected to the backend.
  bool get isConnected => status == ConnectivityStatus.connected;

  ConnectivityState copyWith({
    ConnectivityStatus? status,
    String? serverUrl,
    bool clearServerUrl = false,
    bool? isInitialized,
  }) {
    return ConnectivityState(
      status: status ?? this.status,
      serverUrl: clearServerUrl ? null : (serverUrl ?? this.serverUrl),
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

/// Manages connectivity to the SearchAnyCars backend.
///
/// Reads the saved server URL on init, performs health checks,
/// and retries every 30 seconds when disconnected.
class ConnectivityNotifier extends StateNotifier<ConnectivityState> {
  Timer? _reconnectTimer;

  ConnectivityNotifier() : super(const ConnectivityState()) {
    _init();
  }

  Future<void> _init() async {
    final savedUrl = CacheManager.getServerUrl();
    if (savedUrl != null && savedUrl.isNotEmpty) {
      state = state.copyWith(serverUrl: savedUrl);
      await checkConnection();
    } else {
      state = state.copyWith(
        status: ConnectivityStatus.disconnected,
        isInitialized: true,
      );
    }
  }

  /// Attempt to reach the backend health endpoint.
  Future<bool> checkConnection() async {
    if (state.serverUrl == null || state.serverUrl!.isEmpty) {
      state = state.copyWith(
        status: ConnectivityStatus.disconnected,
        isInitialized: true,
      );
      return false;
    }

    try {
      if (!DioClient.isInitialized || DioClient.baseUrl != state.serverUrl) {
        await DioClient.initialize(state.serverUrl!);
      }
      final healthy = await DioClient.checkHealth();
      if (healthy) {
        state = state.copyWith(
          status: ConnectivityStatus.connected,
          isInitialized: true,
        );
        _stopReconnectTimer();
        return true;
      } else {
        state = state.copyWith(
          status: ConnectivityStatus.disconnected,
          isInitialized: true,
        );
        _startReconnectTimer();
        return false;
      }
    } catch (_) {
      state = state.copyWith(
        status: ConnectivityStatus.disconnected,
        isInitialized: true,
      );
      _startReconnectTimer();
      return false;
    }
  }

  /// Set a new server URL, test it, and persist if successful.
  Future<bool> setServerUrl(String url) async {
    var normalized = url.trim();
    if (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    if (!normalized.startsWith('http')) {
      normalized = 'http://$normalized';
    }

    state = state.copyWith(
      serverUrl: normalized,
      status: ConnectivityStatus.reconnecting,
    );

    try {
      await DioClient.initialize(normalized);
      final healthy = await DioClient.checkHealth();

      if (healthy) {
        await CacheManager.saveServerUrl(normalized);
        state = state.copyWith(status: ConnectivityStatus.connected);
        _stopReconnectTimer();
        return true;
      } else {
        state = state.copyWith(status: ConnectivityStatus.disconnected);
        return false;
      }
    } catch (_) {
      state = state.copyWith(status: ConnectivityStatus.disconnected);
      _startReconnectTimer();
      return false;
    }
  }

  /// Test connectivity to a URL without saving it.
  Future<bool> testConnection(String url) async {
    var normalized = url.trim();
    if (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    if (!normalized.startsWith('http')) {
      normalized = 'http://$normalized';
    }

    try {
      final tempDio = Dio(
        BaseOptions(
          baseUrl: normalized,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      final response = await tempDio.get('/api/health');
      tempDio.close();
      return response.statusCode == 200 &&
          response.data is Map &&
          response.data['ok'] == true;
    } catch (_) {
      return false;
    }
  }

  void _startReconnectTimer() {
    _stopReconnectTimer();
    _reconnectTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (state.status == ConnectivityStatus.disconnected) {
        checkConnection();
      }
    });
  }

  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  @override
  void dispose() {
    _stopReconnectTimer();
    super.dispose();
  }
}

/// Global provider for backend connectivity state.
final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, ConnectivityState>(
  (ref) => ConnectivityNotifier(),
);
