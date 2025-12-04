import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import 'network_connectivity_service_state.dart';

part 'network_connectivity_service.g.dart';

/// Service for monitoring network connectivity status.
///
/// This service provides functionality to:
/// - Monitor real-time network connectivity changes
/// - Log connectivity changes for debugging
@Riverpod(keepAlive: true)
class NetworkConnectivityService extends _$NetworkConnectivityService {
  NetworkConnectivityService() : super();
  static const _logKey = 'NETCONNSVC';

  late final AppLogger _logger = ref.read(appLoggerProvider);
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  NetworkConnectivityServiceState build() {
    ref.onDispose(() {
      _connectivitySubscription?.cancel();
    });

    _initializeConnectivityMonitoring();

    return const NetworkConnectivityServiceState();
  }

  void _initializeConnectivityMonitoring() {
    _logger.info('Initializing network connectivity monitoring', name: _logKey);

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _handleConnectivityChange,
    );

    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      _logger.info(
        'Initial connectivity check: $connectivityResults',
        name: _logKey,
      );
      _handleConnectivityChange(connectivityResults);
    } catch (error) {
      _logger.error(
        'Failed to check initial connectivity',
        error: error,
        name: _logKey,
      );
    }
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final isConnected = _isConnected(results);

    _logger.info(
      'Network connectivity changed: $results (connected: $isConnected)',
      name: _logKey,
    );

    if (isConnected) {
      _logger.info('Network connectivity established', name: _logKey);
    } else {
      _logger.warning('No network connectivity', name: _logKey);
    }

    state = state.copyWith(
      connectivityResults: results,
      isConnected: isConnected,
      isInitialized: true,
    );
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);
  }

  bool get isConnected => state.isConnected;

  List<ConnectivityResult> get connectivityResults => state.connectivityResults;

  bool get isInitialized => state.isInitialized;

  String get connectivityTypeString {
    if (!isConnected) return 'No Connection';

    final results = connectivityResults;
    if (results.contains(ConnectivityResult.wifi)) return 'WiFi';
    if (results.contains(ConnectivityResult.mobile)) return 'Mobile';
    if (results.contains(ConnectivityResult.ethernet)) return 'Ethernet';

    return 'Unknown';
  }
}
