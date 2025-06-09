import 'package:flutter_foreground_service/flutter_foreground_service.dart';
import 'package:que/helpers/app_logs.dart';
import 'package:que/helpers/constants.dart';

class FetchDataService extends ForegroundService {
  static final FetchDataService _fetchDataService = FetchDataService._internal();
  factory FetchDataService() {
    return _fetchDataService;
  }
  FetchDataService._internal();

  @override
  void start() {
    super.start();
    _onStart();
  }

  void _onStart() {
    AppLogs().writeLog(Constants.FETCH_DATA_SERVICE, 'Fetch Service Started.......................');
    _fetchData();
    stop();
  }

  Future<void> _fetchData() async {
    AppLogs().writeLog(Constants.FETCH_DATA_SERVICE, 'Fetching Data......................');
  }

  @override
  void stop() {
    super.stop();
    _onStop();
  }

  void _onStop() {
    AppLogs().writeLog(Constants.FETCH_DATA_SERVICE, 'Fetch Service Stopped............................');
  }
}