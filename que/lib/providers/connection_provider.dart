import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:que/helpers/app_logs.dart';
import 'package:que/helpers/constants.dart';

class ConnectionProvider with ChangeNotifier {
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  ConnectionProvider() {
    InternetConnectionChecker checker = InternetConnectionChecker();
    checker.onStatusChange.listen((status) {
      switch (status) {
        case InternetConnectionStatus.connected:
          AppLogs().writeLog(Constants.CONNECTION_PROVIDER_TAG, 'Device Connected');
          _isConnected = true;
          break;
        case InternetConnectionStatus.disconnected:
          AppLogs().writeLog(Constants.CONNECTION_PROVIDER_TAG, 'Device Disconnected');
          _isConnected = false;
          break;
      }
      notifyListeners();
    });
  }
}