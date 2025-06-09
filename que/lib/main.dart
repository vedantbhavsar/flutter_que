// ignore_for_file: must_be_immutable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:que/helpers/app_logs.dart';
import 'package:que/helpers/constants.dart';
import 'package:que/helpers/db_helper.dart';
import 'package:que/screens/attachments/attachments_screen.dart';
import 'package:que/services/notification_service.dart';
import 'package:que/providers/auth_provider.dart' as AuthProvider;
import 'package:que/providers/connection_provider.dart';
import 'package:que/providers/sub_task_provider.dart';
import 'package:que/providers/task_provider.dart';
import 'package:que/resources/assets_manager.dart';
import 'package:que/resources/string_manager.dart';
import 'package:que/resources/theme_manager.dart';
import 'package:que/screens/add_company_screen.dart';
import 'package:que/screens/edit_task/edit_task_screen.dart';
import 'package:que/screens/home/home_screen.dart';
import 'package:que/screens/profile_screen.dart';
import 'package:que/screens/sign_in_screen.dart';
import 'package:que/screens/sign_up_screen.dart';
import 'package:que/screens/task/task_screen.dart';
import 'package:que/services/sync_data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:workmanager/workmanager.dart';

import 'firebase_options.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  AppLogs().writeLog(Constants.MAIN_TAG, 'notification-------------------------------------(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    AppLogs().writeLog(Constants.MAIN_TAG,
        'notification action tapped with input: ${notificationResponse.input}');
  }

  FlutterForegroundTask.setTaskHandler(DataTask());
}

@pragma('vm:entry-point')
void getData() {
  // ignore: avoid_print
  Workmanager().executeTask((taskName, inputData) {
    switch (taskName) {
      case Constants.GET_DATA_SYNC_MANAGER:
        AppLogs().writeLog(Constants.MAIN_TAG, '${Constants.GET_DATA_SYNC_MANAGER} was executed. inputData = $inputData');
        break;
      case Workmanager.iOSBackgroundTask:
        AppLogs().writeLog(Constants.MAIN_TAG, 'The iOS background fetch was triggered');
        break;
    }
    return Future.value(true);
  });
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage remoteMessage) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AppLogs().writeLog(Constants.MAIN_TAG, '---------------------Message ${remoteMessage.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await NotificationService().init();
  // NotificationService().requestIOSPermissions(FlutterLocalNotificationsPlugin());
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final dbHelper = await DbHelper.init();
  DbHelper.setDbHelper(dbHelper);

  final notificationService = NotificationService();
  await notificationService
      .flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(notificationService.androidChannel);

  final preferences = await SharedPreferences.getInstance();

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  preferences.setString(PrefStrings.APP_NAME, packageInfo.appName);
  preferences.setString(PrefStrings.APP_VERSION, packageInfo.version);

  // SyncDataService().initSyncService();
  // if (await FlutterForegroundTask.isRunningService) {
  //   await FlutterForegroundTask.restartService();
  // } else {
  //   FlutterForegroundTask.startService(
  //     notificationTitle: 'Foreground Service is running',
  //     notificationText: 'Tap to return to the app',
  //   );
  // }
  // FlutterForegroundTask.setTaskHandler(DataTask());

  // await Workmanager().initialize(getData);

  runApp(MyApp(preferences));
}

class MyApp extends StatefulWidget {
  static late SharedPreferences sharedPreferences;
  MyApp._internal(); // private named constructor
  int appState = 0;
  static final MyApp instance = MyApp._internal(); // Single Instance -- Singleton

  factory MyApp(SharedPreferences preferences) {
    sharedPreferences = preferences;
    return instance;
  } // factory for the class instance

  @override
  State<MyApp> createState() => _MyAppState();

  SharedPreferences get sharedPreference => sharedPreferences;
}

class _MyAppState extends State<MyApp> {
  bool _isPermissionShown = false;

  Future<void> addNewUser(AuthProvider.AuthProvider authProvider) async {
    await authProvider.addNewUser();
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    }
    else {
      final result = await permission.request();
      if (result == PermissionStatus.granted) {
        AppLogs().writeLog(Constants.MAIN_TAG, 'Permission Granted');
        return true;
      }
      return false;
    }
  }

  Future<void> _checkPermissions() async {
    final storagePermission = widget.sharedPreference.getBool(PrefStrings.STORAGE_PERMISSION) ?? false;
    if (!storagePermission) {
      if (!_isPermissionShown) {
        _isPermissionShown = true;
        await _requestPermission(Permission.storage);
      }
    }
    else {
      AppLogs().writeLog(Constants.MAIN_TAG, 'Permission Granted');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _checkPermissions();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ConnectionProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProvider.AuthProvider(widget.sharedPreference),
        ),
        ChangeNotifierProvider(
          create: (context) => TaskProvider(widget.sharedPreference),
        ),
        ChangeNotifierProvider(
          create: (context) => SubTaskProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: getApplicationTheme(),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapShot) {
            if (snapShot.connectionState == ConnectionState.waiting && snapShot.data == null) {
              return Center(
                child: Image.asset('${ImageAssets.splashLogo}'),
              );
            }
            else if (snapShot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            else if (snapShot.hasData) {
              final authProvider = Provider.of<AuthProvider.AuthProvider>(context);
              final user = snapShot.data;
              if (user != null) {
                authProvider.setUser(user);
              }
              else {
                return SignInScreen();
              }

              if (user.displayName == null) {
                return AddCompanyScreen();
              }

              authProvider.addNewUser().then((_) => {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                  ),
                )
              });
            }
            else if (!snapShot.hasData) {
              return SignInScreen();
            }

            return Center(
              child: Image.asset('${ImageAssets.splashLogo}'),
            );
          },
        ),
        routes: {
          SignInScreen.routeName: (context) => SignInScreen(),
          SignUpScreen.routeName: (context) => SignUpScreen(),
          // LoginScreen.routeName: (context) => LoginScreen(),
          ProfileScreen.routeName: (context) => const ProfileScreen(),
          AddCompanyScreen.routeName: (context) => const AddCompanyScreen(),
          HomeScreen.routeName: (context) => HomeScreen(),
          TaskScreen.routeName: (context) => TaskScreen(),
          EditTaskScreen.routeName: (context) => EditTaskScreen(),
          AttachmentsScreen.routeName: (context) => AttachmentsScreen(),
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
