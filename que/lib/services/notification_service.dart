import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:que/helpers/app_logs.dart';
import 'package:que/helpers/constants.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  //Singleton pattern
  static final NotificationService _notificationService = NotificationService._internal();
  factory NotificationService() {
    return _notificationService;
  }
  NotificationService._internal();

  //instance of FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final BehaviorSubject<String?> onNotificationClick = BehaviorSubject();

  FlutterLocalNotificationsPlugin get flutterLocalNotificationsPlugin => _flutterLocalNotificationsPlugin;

  Future<void> init() async {

    tz.initializeTimeZones();

    //Initialization Settings for Android
    final AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@drawable/icon');

    //Initialization Settings for iOS
    final DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
      notificationCategories: [
        DarwinNotificationCategory(
          'demoCategory',
          actions: [
            DarwinNotificationAction.plain('id_1', 'Action 1'),
            DarwinNotificationAction.plain(
              'id_2',
              'Action 2',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.destructive,
              },
            ),
            DarwinNotificationAction.plain(
              'id_3',
              'Action 3',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.foreground,
              },
            ),
          ],
          options: <DarwinNotificationCategoryOption>{
            DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
          },
        )
      ],
    );

    //InitializationSettings for initializing settings for both platforms (Android & iOS)
    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // onDidReceiveBackgroundNotificationResponse: (notificationResponse) {
      //   print('onDidReceiveBackgroundNotificationResponse: ${notificationResponse.toString()}');
      // },
      onDidReceiveNotificationResponse: (notificationResponse) {
        AppLogs().writeLog(Constants.NOTIFICATION_SERVICE, 'onDidReceiveNotificationResponse: ${notificationResponse.toString()}');
      },
    );
  }

  void _onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    AppLogs().writeLog(Constants.NOTIFICATION_SERVICE, 'onDidReceiveLocalNotification Notification ID: $id');
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) => CupertinoAlertDialog(
    //     title: Text(title ?? 'Que'),
    //     content: Text(body ?? 'Que'),
    //     actions: [
    //       CupertinoDialogAction(
    //         isDefaultAction: true,
    //         child: Text('Ok'),
    //         onPressed: () async {
    //           Navigator.of(context, rootNavigator: true).pop();
    //           await Navigator.push(
    //             context,
    //             MaterialPageRoute(
    //               builder: (context) => HomeScreen(),
    //             ),
    //           );
    //         },
    //       )
    //     ],
    //   ),
    // );
  }

  void requestIOSPermissions(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    final details = await _notificationDetails(id);
    _flutterLocalNotificationsPlugin.show(
        id, title, body,
        details,
        payload: payload
    );
  }

  Future showScheduleNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    int? seconds,
  }) async {
    final details = await _notificationDetails(id);
    _flutterLocalNotificationsPlugin.zonedSchedule(
      id, title, body,
      tz.TZDateTime.from(DateTime.now().add(Duration(seconds: seconds ?? 3600)), tz.local),
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future showPayloadNotification({
    int id = 0,
    String? title,
    String? body,
    required String payload,
  }) async {
    final details = await _notificationDetails(id);
    _flutterLocalNotificationsPlugin.show(
      id, title, body,
      details,
      payload: payload,
    );
  }

  Future _notificationDetails(int id) async {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        '${id.toString()}',
        'channel name',
        importance: Importance.max,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  AndroidNotificationChannel get androidChannel => AndroidNotificationChannel(
    'channel_id',
    'channel_title',
    description: 'channel_desc',
    importance: Importance.high,
    playSound: true,
    showBadge: true,
  );
}