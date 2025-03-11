import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class WifiController {
  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _internetChecker = InternetConnectionChecker.instance;

  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectionController.stream;

  WifiController() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _internetChecker.hasConnection.then((hasInternet) {
        _connectionController.add(hasInternet);
      });
    });
  }

  Future<bool> checkConnection () async {
    bool hasInternet = await _internetChecker.hasConnection;
    _connectionController.add(hasInternet);
    return hasInternet;
  }

  void dispose() {
    _connectionController.close();
  }

}