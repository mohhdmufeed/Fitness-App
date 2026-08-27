import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionChangeController =
      StreamController<bool>.broadcast();

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen(_checkStatus);
  }

  Stream<bool> get connectionStream => _connectionChangeController.stream;

  void _checkStatus(List<ConnectivityResult> results) {
    final hasConnection = !results.contains(ConnectivityResult.none);
    _connectionChangeController.add(hasConnection);
  }

  /// One-time check for active internet connection
  Future<bool> hasInternet() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return !results.contains(ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _connectionChangeController.close();
  }
}
