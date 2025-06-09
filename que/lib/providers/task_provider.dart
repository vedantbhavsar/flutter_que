import 'package:flutter/foundation.dart';
import 'package:que/helpers/constants.dart';
import 'package:que/helpers/db_helper.dart';
import 'package:que/models/que_user.dart';
import 'package:que/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  List<Task> _startTasks = [];
  List<Task> _inProgressTasks = [];
  List<Task> _onHoldTasks = [];
  List<Task> _completedTasks = [];
  List<QueUser> _queUsers = [];
  Map<String, dynamic> _filters = {};
  bool _clearAllFilter = true;
  bool _selectAllFilter = true;
  late SharedPreferences _sharedPreferences;

  TaskProvider(SharedPreferences sharedPreferences) {
    this._sharedPreferences = sharedPreferences;
  }

  SharedPreferences get sharedPreferences {
    return _sharedPreferences;
  }

  List<Task> get tasks {
    return _tasks;
  }

  List<Task> get startTasks {
    return _startTasks;
  }

  List<Task> get inProgressTasks {
    return _inProgressTasks;
  }

  List<Task> get onHoldTasks {
    return _onHoldTasks;
  }

  List<Task> get completedTasks {
    return _completedTasks;
  }

  List<QueUser> get queUsers {
    final users = DbHelper.getDbHelper.getAllQueUsers();
    if (users.length <= 0) {
      return [];
    }
    else {
      return users;
    }
  }

  List<String> get names {
    List<String> displayNames = [];
    _queUsers.forEach((element) {
      displayNames.add(element.displayName);
    });
    return displayNames;
  }

  Map<String, dynamic> get filters {
    return _filters;
  }

  bool get clearAllFilter {
    return _clearAllFilter;
  }

  bool get selectAllFilter {
    return _selectAllFilter;
  }

  void addOrUpdateQueUser(QueUser queUser) {
    _filters.putIfAbsent(queUser.displayName, () => true);
    int index = _queUsers.indexWhere((element) => element.queUserId == queUser.queUserId);
    if (index == -1) {
      _queUsers.add(queUser);
    }
    else {
      _queUsers.removeAt(index);
      _queUsers.insert(index, queUser);
    }
    // DbHelper.getDbHelper.removeAllQueUser();
    DbHelper.getDbHelper.insertQueUser(queUser);
  }

  void addOrUpdateTask(Task task) {
    _saveTask(_tasks, task);
    if (task.status == TaskStatusEnum.Complete.name) {
      _saveTask(_completedTasks, task);
    }
    else if (task.status == TaskStatusEnum.In_Progress.name.replaceAll('_', ' ')) {
      _saveTask(_inProgressTasks, task);
    }
    else if (task.status == TaskStatusEnum.On_Hold.name.replaceAll('_', ' ')) {
      _saveTask(_onHoldTasks, task);
    }
    else if (task.status == TaskStatusEnum.Start.name) {
      _saveTask(_startTasks, task);
    }
  }

  void _saveTask(List<Task> _tasks, Task task) {
    int index = _tasks.indexWhere((element) => element.taskId == task.taskId);
    if (index == -1) {
      _tasks.add(task);
    }
    else {
      _tasks.removeAt(index);
      _tasks.insert(index, task);
    }
    DbHelper.getDbHelper.insertTask(task);
  }

  void removeTaskFromList(Task task) {
    if (task.status == TaskStatusEnum.Complete.name) {
      _removeTask(_completedTasks, task);
    }
    else if (task.status == TaskStatusEnum.In_Progress.name.replaceAll('_', ' ')) {
      _removeTask(_inProgressTasks, task);
    }
    else if (task.status == TaskStatusEnum.On_Hold.name.replaceAll('_', ' ')) {
      _removeTask(_onHoldTasks, task);
    }
    else if (task.status == TaskStatusEnum.Start.name) {
      _removeTask(_startTasks, task);
    }
  }

  void _removeTask(List<Task> _tasks, Task task) {
    _tasks.remove(task);
  }
  void reset() {
    _startTasks.clear();
    _completedTasks.clear();
    _onHoldTasks.clear();
    _inProgressTasks.clear();
    _filters.clear();
    getUpdates();
  }

  void getUpdates() {
    _tasks.clear();
    notifyListeners();
  }

  void reorderTasks(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final items = _tasks.removeAt(oldIndex);
    _tasks.insert(newIndex, items);
    notifyListeners();
  }

  void applyFilter(String filterName, bool isChecked) {
    _filters.update(filterName, (value) => isChecked);
    List<Task> filterTask = [];
    int count = 0;
    _filters.forEach((key, value) {
      if (value) {
        final tasks = _tasks.where((task) => task.assignedTo == key);
        filterTask.addAll(tasks);
        count++;
      }
    });
    _clearAllFilter = false;
    _selectAllFilter = false;
    if (count == 0) {
      _clearAllFilter = true;
    }
    if (count == _filters.length) {
      _selectAllFilter = true;
    }
    _tasks.clear();
    _tasks.addAll(filterTask);
    notifyListeners();
  }

  void clearFilter() {
    _clearAllFilter = true;
    _filters.updateAll((key, value) => false);
    notifyListeners();
  }

  void allFilter() {
    _selectAllFilter = true;
    _filters.updateAll((key, value) => true);
    notifyListeners();
  }
}