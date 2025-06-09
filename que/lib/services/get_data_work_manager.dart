import 'package:que/helpers/constants.dart';
import 'package:workmanager/workmanager.dart';

class GetDataWorkManager {
  static final GetDataWorkManager _getDataWorkManager = GetDataWorkManager._internal();
  factory GetDataWorkManager() {
    return _getDataWorkManager;
  }
  GetDataWorkManager._internal();

  static Future<void> getData() async {
    Workmanager().executeTask((taskName, inputData) {
      switch (taskName) {
        case Constants.GET_DATA_SYNC_MANAGER:
          print("${Constants.GET_DATA_SYNC_MANAGER} was executed. inputData = $inputData");
          break;
        case Workmanager.iOSBackgroundTask:
          print("The iOS background fetch was triggered");
          break;
      }
      return Future.value(true);
    });
  }
}