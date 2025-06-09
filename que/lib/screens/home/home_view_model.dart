import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:que/helpers/app_logs.dart';
import 'package:que/helpers/constants.dart';
import 'package:que/helpers/db_helper.dart';
import 'package:que/helpers/functions.dart';
import 'package:que/models/que_user.dart';
import 'package:que/models/task.dart';
import 'package:que/resources/string_manager.dart';
import 'package:que/screens/base/base_view_model.dart';
import 'package:que/services/notification_service.dart';
import 'package:rxdart/rxdart.dart';

class HomeViewModel extends BaseViewModel with HomeViewModelInputs, HomeViewModelOutputs {
  final StreamController _taskStreamController = BehaviorSubject<List<Task>>();
  final StreamController _taskStartStreamController = BehaviorSubject<List<Task>>();
  final StreamController _taskInProgressStreamController = BehaviorSubject<List<Task>>();
  final StreamController _taskOnHoldStreamController = BehaviorSubject<List<Task>>();
  final StreamController _taskCompleteStreamController = BehaviorSubject<List<Task>>();

  late final StreamSubscription<QuerySnapshot<Task>> _taskSnapshot;

  HomeViewModel();

  @override
  void start() {
    super.start();
  }

  @override
  void initProviders(BuildContext context) {
    super.initProviders(context);
    getUserCollectionRef().doc(authProvider.user.uid).get().then((docRef) {
      late QueUser queUser;
      if (!docRef.exists) {
        queUser = QueUser(
          queUserId: docRef.id,
          email: authProvider.email,
          displayName: authProvider.displayName,
          mobileNo: authProvider.phoneNumber,
          photoUrl: authProvider.photoURL,
          color: (math.Random().nextDouble() * 0xFFFFFF).toInt(),
          company: '', role: '',
        );
      }
      else {
        queUser = QueUser(
          queUserId: docRef.data()?['queUserId'],
          email: docRef.data()?['email'],
          displayName: docRef.data()?['displayName'],
          mobileNo: docRef.data()?['mobileNo'],
          photoUrl: docRef.data()?['photoUrl'],
          color: docRef.data()?['color'],
          company: docRef.data()?['company'],
          role: docRef.data()?['role'],
        );
      }
      AppLogs().writeLog(Constants.HOME_VIEW_MODEL_TAG, '${queUser.toString()}');
      getUserCollectionRef().doc(authProvider.user.uid)
          .withConverter(fromFirestore: QueUser.fromFirestore, toFirestore: (QueUser queUser, options) => queUser.toFirestore())
          .set(queUser);
      authProvider.sharedPreferences.setString(PrefStrings.QUE_USER_COMPANY, queUser.company);
      DbHelper.getDbHelper.insertQueUser(queUser);

      addTasks();
    });

    final _preferences = taskProvider.sharedPreferences;
    AppLogs().writeLog(Constants.HOME_VIEW_MODEL_TAG, 'Priority: ${_preferences.getInt(PrefStrings.TASK_PRIORITY)} | Company: ${_preferences.getString(PrefStrings.QUE_USER_COMPANY)}');
    DbHelper.getDbHelper.removeAllQueUser();
    getUserCollectionRef()
        .where(QueUserFields.company.name, isEqualTo: _preferences.getString(PrefStrings.QUE_USER_COMPANY))
        .withConverter(fromFirestore: QueUser.fromFirestore, toFirestore: (QueUser queUser, options) => queUser.toFirestore())
        .snapshots().listen((event) {
      event.docs.forEach((doc) {
        taskProvider.addOrUpdateQueUser(doc.data());
      });
    });
  }

  @override
  Sink get streamTasks => _taskStreamController.sink;

  @override
  Sink get streamTasksStart => _taskStartStreamController.sink;

  @override
  Sink get streamTasksInProgress => _taskInProgressStreamController.sink;

  @override
  Sink get streamTasksOnHold => _taskOnHoldStreamController.sink;

  @override
  Sink get streamTasksComplete => _taskCompleteStreamController.sink;

  @override
  void addTasks() {
    AppLogs().writeLog(Constants.HOME_VIEW_MODEL_TAG, 'Getting Tasks..........');
    final tasksCollectionRef = FirebaseFirestore.instance.collection(References.QUE_COLLECTION_REF)
        .doc(References.QUE_TESTING_DOC_REF).collection(References.TASKS_COLLECTION_REF);
    late final snapshot;
    final queUser = DbHelper.getDbHelper.getQueUser(authProvider.user.uid);
    String company = '';

    if (queUser == null) {
      AppLogs().writeLog(Constants.HOME_VIEW_MODEL_TAG, 'Adding Que User Locally.........');
      authProvider.addNewUser();
      company = preferences.getString(PrefStrings.QUE_USER_COMPANY) ?? '';
    }
    else {
      company = queUser.company;
    }
    snapshot = tasksCollectionRef.orderBy('createdOn')
        .where(QueUserFields.company.name, isEqualTo: company);

    _taskSnapshot = (snapshot as Query<Map<String, dynamic>>).withConverter(
        fromFirestore: Task.fromFirestore,
        toFirestore: (Task task, options) => task.toFirestore())
        .snapshots().listen((event) {
      DbHelper.getDbHelper.deleteTasks();
      taskProvider.startTasks.clear();
      taskProvider.inProgressTasks.clear();
      taskProvider.onHoldTasks.clear();
      taskProvider.completedTasks.clear();
      final taskDoc = event.docs;
      taskDoc.map((task) {
        if (!task.data().isNotified && task.data().assignedTo == authProvider.displayName) {
          final updateTaskRef = getTaskCollectionRef().doc(task.data().taskId);
          updateTaskRef.update({
            TaskFields.isNotified.name: true,
          });
          NotificationService().showNotification(
            id: 1, title: task.data().title, body: task.data().description,
          );
        }
        taskProvider.addOrUpdateTask(task.data());
      }).toList();
      AppLogs().writeLog(Constants.HOME_VIEW_MODEL_TAG, 'All Tasks Added Locally.');
    });
  }

  @override
  Stream<List<Task>> streamGetTasks(int priority) {
    return DbHelper.getDbHelper.getTasks(priority);
  }

  @override
  int taskExpiryInHours(Task task) {
    DateTime expiryTime;
    if (TaskTimeUnitEnum.Hours.index == task.timeUnit) {
      expiryTime = task.createdOn.add(Duration(hours: task.timeValue));
    }
    else if (TaskTimeUnitEnum.Days.index == task.timeUnit) {
      expiryTime = task.createdOn.add(Duration(days: task.timeValue));
    }
    else {
      expiryTime = task.createdOn.add(Duration(days: task.timeValue * 7));
    }
    return expiryTime.difference(DateTime.now()).inHours;
  }

  @override
  String taskRemainingTime(int expiryInHours) {
    String remainingTime = '';
    if (expiryInHours < 0) {
      remainingTime = '0';
    }
    else {
      int getDays = expiryInHours ~/ 24;
      if (getDays == 1) {
        remainingTime = '${getDays}day ';
      }
      else if (getDays > 1) {
        remainingTime = '${getDays}days ';
      }
      int getHours = expiryInHours % 24;
      if (getHours == 1) {
        remainingTime += '${getHours}hr';
      }
      else if (getHours > 1) {
        remainingTime += '${getHours}hrs';
      }
      if (remainingTime.isEmpty) {
        remainingTime = '0';
      }
    }
    return remainingTime;
  }

  @override
  Stream<List<Task>> streamStartTasks() => DbHelper.getDbHelper.getStartTasks();

  @override
  Stream<List<Task>> streamInProgressTasks() => DbHelper.getDbHelper.getInProgressTasks();

  @override
  Stream<List<Task>> streamOnHoldTasks() => DbHelper.getDbHelper.getOnHoldTasks();

  @override
  Stream<List<Task>> streamCompleteTasks() => DbHelper.getDbHelper.getCompleteTasks();

  @override
  void dispose() {
    _taskStreamController.close();
    _taskStartStreamController.close();
    _taskInProgressStreamController.close();
    _taskOnHoldStreamController.close();
    _taskCompleteStreamController.close();
    _taskSnapshot.cancel();
    super.dispose();
  }
}

abstract mixin class HomeViewModelInputs {
  Sink get streamTasks;
  Sink get streamTasksStart;
  Sink get streamTasksInProgress;
  Sink get streamTasksOnHold;
  Sink get streamTasksComplete;
}

abstract mixin class HomeViewModelOutputs {
  void addTasks();
  Stream<List<Task>> streamGetTasks(int priority);
  Stream<List<Task>> streamStartTasks();
  Stream<List<Task>> streamInProgressTasks();
  Stream<List<Task>> streamOnHoldTasks();
  Stream<List<Task>> streamCompleteTasks();
  int taskExpiryInHours(Task task);
  String taskRemainingTime(int expiryInHours);
}