import 'package:que/helpers/app_logs.dart';
import 'package:que/helpers/constants.dart';
import 'package:que/models/que_user.dart';
import 'package:que/models/task.dart';
import 'package:que/objectbox.g.dart';

class DbHelper {
  static late final _dbHelper;
  late final Store _store;
  late final Box<Task> _taskBox;
  late final Box<QueUser> _queUserBox;

  DbHelper._init(this._store) {
    _taskBox = Box<Task>(_store);
    _queUserBox = Box<QueUser>(_store);
  }

  static Future<DbHelper> init() async {
    final store = await openStore();
    return DbHelper._init(store);
  }

  static void setDbHelper(DbHelper dbHelper) {
    DbHelper._dbHelper = dbHelper;
  }

  static DbHelper get getDbHelper => _dbHelper;

  QueUser? getQueUser(String id) {
    final users = _queUserBox.getAll();
    if (users.isEmpty) {
      AppLogs().writeLog(Constants.DB_HELPER_TAG, 'Users List is Empty.............');
      return null;
    }
    return users.singleWhere((element) => element.queUserId == id);
  }

  List<QueUser> getAllQueUsers() {
    final users = _queUserBox.getAll();
    if (users.isEmpty) {
      AppLogs().writeLog(Constants.DB_HELPER_TAG, 'All Users List is Empty.............');
      return [];
    }
    return users;
  }

  int removeAllQueUser() => _queUserBox.removeAll();

  int insertQueUser(QueUser queUser, {bool isUpdate = false}) => _queUserBox.put(
      queUser, mode: isUpdate ? PutMode.update : PutMode.put
  );

  Task? getTask(String id) => _taskBox.getAll().firstWhere((element) => element.taskId == id);

  int insertTask(Task task) => _taskBox.put(task);

  void removeTask(String id) => _taskBox.getAll().removeWhere((element) => element.taskId == id);

  Stream<List<Task>> getTasks(int priority) {
    String name = '';
    if (priority == PriorityEnum.Blocker.index) {
      name = PriorityEnum.Blocker.name;
    }
    else if (priority == PriorityEnum.Highest.index) {
      name = PriorityEnum.Highest.name;
    }
    else if (priority == PriorityEnum.High.index) {
      name = PriorityEnum.High.name;
    }
    else if (priority == PriorityEnum.Medium.index) {
      name = PriorityEnum.Medium.name;
    }
    else if (priority == PriorityEnum.Normal.index) {
      name = PriorityEnum.Normal.name;
    }
    else if (priority == PriorityEnum.Latest.index) {
      name = PriorityEnum.Latest.name;
    }
    else if (priority == PriorityEnum.Oldest.index) {
      name = PriorityEnum.Oldest.name;
    }

    print('Rearranging Tasks for selected Priority: $name');
    if (name == PriorityEnum.Oldest.name) {
      final query = (_taskBox.query()..order(Task_.createdOn));
      return query
          .watch(triggerImmediately: true).map((query) => query.find());
    }
    else if (name == PriorityEnum.Latest.name) {
      final query = (_taskBox.query()..order(Task_.createdOn, flags: Order.descending));
      return query
          .watch(triggerImmediately: true).map((query) => query.find());
    }

    return _taskBox
        .query(Task_.priority.equals(name))
        .watch(triggerImmediately: true).map((query) => query.find());
  }

  Stream<List<Task>> getStartTasks() => _taskBox
      .query(Task_.status.equals(TaskStatusEnum.Start.name))
      .watch(triggerImmediately: true).map((query) => query.find());

  Stream<List<Task>> getInProgressTasks() => _taskBox
      .query(Task_.status.equals(TaskStatusEnum.In_Progress.name.replaceAll('_', ' ')))
      .watch(triggerImmediately: true).map((query) => query.find());

  Stream<List<Task>> getOnHoldTasks() => _taskBox
      .query(Task_.status.equals(TaskStatusEnum.On_Hold.name.replaceAll('_', ' ')))
      .watch(triggerImmediately: true).map((query) => query.find());

  Stream<List<Task>> getCompleteTasks() => _taskBox
      .query(Task_.status.equals(TaskStatusEnum.Complete.name))
      .watch(triggerImmediately: true).map((query) => query.find());

  int deleteTasks() => _taskBox.removeAll();
}