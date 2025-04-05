import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class WifiController {
  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _internetChecker = InternetConnectionChecker.instance;

  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectionController.stream;

  bool _lastStatus = false;
  Timer? _periodicTimer;

  WifiController({Duration checkInterval = const Duration(seconds: 5)}) {
    _connectivity.onConnectivityChanged.listen((_) => _checkStatus());
    _periodicTimer = Timer.periodic(checkInterval, (_) => _checkStatus());
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final hasInternet = await _internetChecker.hasConnection;
    if (hasInternet != _lastStatus) {
      _lastStatus = hasInternet;
      _connectionController.add(hasInternet);
    }
  }

  Future<bool> checkConnection () async {
    final hasInternet = await _internetChecker.hasConnection;
    _connectionController.add(hasInternet);
    return hasInternet;
  }

  void dispose() {
    _periodicTimer?.cancel();
    _connectionController.close();
  }

}