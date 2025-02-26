import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;

  final _connectivityStreamController = StreamController<bool>.broadcast();
  Stream<bool> get connectivityStream => _connectivityStreamController.stream;

  ConnectivityService._internal() {
    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((results) {
      if (results is List<ConnectivityResult>) {
        // Process list of ConnectivityResult
        final isConnected = results.any((result) =>
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi);
        _connectivityStreamController.sink.add(isConnected);
      } else if (results is ConnectivityResult) {
        // Standard case (single ConnectivityResult)
        _connectivityStreamController.sink.add(_isConnected(results.first));
      }
    });

    // Initialize connectivity state
    _initializeConnectivity();
  }

  Future<void> _initializeConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _connectivityStreamController.sink.add(_isConnected(result.first));
  }

  bool _isConnected(ConnectivityResult result) {
    return result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi;
  }

  void dispose() {
    _connectivityStreamController.close();
  }
}
