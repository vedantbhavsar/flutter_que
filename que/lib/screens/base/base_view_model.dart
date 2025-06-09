import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:que/providers/auth_provider.dart';
import 'package:que/providers/connection_provider.dart';
import 'package:que/providers/sub_task_provider.dart';
import 'package:que/providers/task_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class BaseViewModel extends BaseViewModelInputs {
  late final SharedPreferences preferences;
  late final ConnectionProvider connectionProvider;
  late final AuthProvider authProvider;
  late final TaskProvider taskProvider;
  late final SubTaskProvider subTaskProvider;

  @override
  void start() {}

  @override
  void initProviders(BuildContext context) {
    connectionProvider = Provider.of<ConnectionProvider>(context, listen: false);
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    preferences = authProvider.sharedPreferences;
    taskProvider = Provider.of<TaskProvider>(context, listen: false);
    subTaskProvider = Provider.of<SubTaskProvider>(context, listen: false);
  }

  @override
  void dispose() {}
}

abstract class BaseViewModelInputs {
  void start();
  void initProviders(BuildContext context);
  void dispose();
}
