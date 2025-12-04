import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkConnectivityServiceState {
  const NetworkConnectivityServiceState({
    this.connectivityResults = const [],
    this.isConnected = false,
    this.isInitialized = false,
  });

  final List<ConnectivityResult> connectivityResults;
  final bool isConnected;
  final bool isInitialized;

  NetworkConnectivityServiceState copyWith({
    List<ConnectivityResult>? connectivityResults,
    bool? isConnected,
    bool? isInitialized,
  }) {
    return NetworkConnectivityServiceState(
      connectivityResults: connectivityResults ?? this.connectivityResults,
      isConnected: isConnected ?? this.isConnected,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}
