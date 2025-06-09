import 'package:flutter/foundation.dart';
import 'package:que/models/sub_task.dart';

class SubTaskProvider with ChangeNotifier {
  List<SubTask> _subTasks = [];
  Map<String, Object> _subTaskByTaskId = {};

  List<SubTask> get subTasks {
    return _subTasks;
  }

  void addOrUpdateTask(String taskId, SubTask task) {
    int index = _subTasks.indexWhere((element) => element.subTaskId == task.subTaskId);
    if (index == -1) {
      _subTasks.add(task);
    }
    else {
      _subTasks.removeAt(index);
      _subTasks.insert(index, task);
    }
    _saveSubTaskByTaskId(taskId, task);
  }

  void _saveSubTaskByTaskId(String taskId, SubTask subTask) {
    List<SubTask> presentSubTask = (_subTaskByTaskId[taskId] as List<SubTask>?) == null ? [] : (_subTaskByTaskId[taskId] as List<SubTask>);
    presentSubTask.firstWhere(
          (element) {
            return element.subTaskId == subTask.subTaskId;
          },
          orElse: () {
            presentSubTask.add(subTask);
            return subTask;
          }
    );
    _subTaskByTaskId[taskId] = presentSubTask;
  }

  List<SubTask> subTasksByTaskId(String taskId) {
    if (taskId.isNotEmpty) {
      List<SubTask> list = (_subTaskByTaskId[taskId] as List<SubTask>?) == null ? [] : (_subTaskByTaskId[taskId] as List<SubTask>);
      return list;
    }
    return [];
  }

  void getUpdates() {
    notifyListeners();
  }
}