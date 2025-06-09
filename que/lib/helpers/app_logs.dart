import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:que/resources/string_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLogs {
  late String prefix;

  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();
    return directory!.path;
  }

  Future<File> get _localFile async {
    final pref = await SharedPreferences.getInstance();
    final version = pref.getString(PrefStrings.APP_VERSION) ?? '';
    final name = pref.getString(PrefStrings.APP_NAME) ?? '';
    prefix = '${name.toUpperCase()} :: $version';

    final path = await _localPath;
    final file = File('$path/app_rec.txt');
    if (await file.exists()) {
      return file;
    }
    return await file.create();
  }

  Future<void> readLog() async {
    try {
      final file = await _localFile;
      // Read the file
      final contents = await file.readAsString();
      print(contents);
    } catch (error) {
      print(error.toString());
    }
  }

  void writeLog(String TAG, String error) {
    _localFile.then((file) async {
      // Write the file
      String message = '${DateFormat.yMMMd().add_jm().format(DateTime.now())} :: $prefix :: $TAG :: $error\n';
      print('$message');
      file.writeAsStringSync('$message', mode: FileMode.append);
    }, onError: (error) {
      print('App Log write error: ${error.toString()}');
    }).catchError((error) {
      print('App Log write error: ${error.toString()}');
    });
  }
}