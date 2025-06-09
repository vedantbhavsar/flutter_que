import 'dart:isolate';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:que/helpers/constants.dart';
import 'package:que/screens/home/home_screen.dart';

class SyncDataService {
  static final SyncDataService _syncDataService = SyncDataService._internal();
  factory SyncDataService() {
    return _syncDataService;
  }
  SyncDataService._internal();

  void initSyncService() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: '${Constants.SYNC_SERVICE_NOTIFICATION_ID}',
        channelName: 'Sync Data',
        channelDescription: 'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: '@drawable/icon',
        ),
        buttons: [
          const NotificationButton(id: 'sendButton', text: 'Send'),
          const NotificationButton(id: 'testButton', text: 'Test'),
        ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }
}

class DataTask extends TaskHandler {
  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    print('Task destroy................................');
  }

  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    print('Task event................................');
  }

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    print('Task started................................');
  }

  @override
  void onNotificationPressed() {
    super.onNotificationPressed();
    FlutterForegroundTask.launchApp(HomeScreen.routeName);
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) {
    // TODO: implement onRepeatEvent
  }
}