import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:que/helpers/app_logs.dart';
import 'package:que/helpers/constants.dart';
import 'package:que/helpers/functions.dart';
import 'package:que/models/attachment.dart';
import 'package:que/models/que_user.dart';
import 'package:que/models/sub_task.dart';
import 'package:que/models/task.dart';
import 'package:que/screens/base/base_view_model.dart';

class EditTaskViewModel extends BaseViewModel with EditTaskViewModelInputs {
  EditTaskViewModel();

  @override
  void start() {
    super.start();
  }

  @override
  void initProviders(BuildContext context) {
    super.initProviders(context);
  }

  @override
  void editTasks(BuildContext context, Task? updateTask, String newTaskRefId, Map<String, dynamic> _initialTask, List<SubTask> subTasks, List<QueUser> queUsers) {
    if (updateTask == null) {
      final task = Task(
        taskId: newTaskRefId, title: _initialTask['title'],
        description: _initialTask['description'],
        timeUnit: (_initialTask['timeUnit'] as int) == TaskTimeUnitEnum.Hours.index
            ? TaskTimeUnitEnum.Hours.index : _initialTask['timeUnit'],
        timeValue: _initialTask['timeValue'],
        assignee: authProvider.displayName,
        assignedTo: (_initialTask['assignedTo'] as String).isEmpty
            ? queUsers[0].displayName : _initialTask['assignedTo'],
        createdOn: _initialTask['createdOn'],
        priority: _initialTask['priority'].toString().isEmpty ? PriorityEnum.Normal.name : _initialTask['priority'],
        status: TaskStatusEnum.Start.name,
        company: authProvider.company,
        isNotified: false,
      );
      AppLogs().writeLog(Constants.EDIT_TASK_VIEW_MODEL_TAG, 'Add Tasks: ${task.toString()}');
      getTaskCollectionRef().doc(newTaskRefId).withConverter(
        fromFirestore: Task.fromFirestore,
        toFirestore: (Task task, options) => task.toFirestore(),
      ).set(task);
      // FirebaseMessaging.instance.sendMessage(
      //   messageId: task.taskId,
      //   messageType: task.title,
      //   data: {'description': task.description},
      //   collapseKey: task.taskId,
      //   ttl: 5,
      // );
      editSubsTasks(context, updateTask, newTaskRefId, subTasks);
    }
    else {
      final updateTaskRef = getTaskCollectionRef().doc(updateTask.taskId);
      final task = Task(
        taskId: updateTaskRef.id, title: _initialTask['title'],
        description: _initialTask['description'],
        timeUnit: (_initialTask['timeUnit'] as int) == TaskTimeUnitEnum.Hours.index
            ? TaskTimeUnitEnum.Hours.index : _initialTask['timeUnit'],
        timeValue: _initialTask['timeValue'],
        assignee: authProvider.displayName,
        assignedTo: (_initialTask['assignedTo'] as String).isEmpty
            ? queUsers[0].displayName : _initialTask['assignedTo'],
        createdOn: _initialTask['createdOn'],
        priority: _initialTask['priority'].toString().isEmpty ? PriorityEnum.Normal.name : _initialTask['priority'],
        status: _initialTask['status'],
        company: authProvider.company,
        isNotified: _initialTask['isNotified'],
      );
      updateTaskRef.withConverter(
        fromFirestore: Task.fromFirestore,
        toFirestore: (Task task, options) => task.toFirestore(),
      ).set(task, SetOptions(merge: true));
      AppLogs().writeLog(Constants.EDIT_TASK_SCREEN_TAG, 'Update Tasks: ${task.toString()}');
      taskProvider.addOrUpdateTask(task);
      editSubsTasks(context, updateTask, updateTaskRef.id, subTasks);
    }
  }

  @override
  void editSubsTasks(BuildContext context, Task? updateTask, String taskRefId, List<SubTask> subTasks) {
    if (updateTask == null) {
      if (subTasks.length < 1) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      else if (subTasks.length >= 1) {
        subTasks.forEach((subTask) {
          getSubTaskCollectionRef(taskRefId)
              .doc(subTask.subTaskId)
              .withConverter(fromFirestore: SubTask.fromFirestore, toFirestore: (SubTask subTask, options) => subTask.toFirestore())
              .set(subTask);
        });
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
    else {
      if (subTasks.length < 1) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      else if (subTasks.length >= 1) {
        subTasks.forEach((subTask) {
          getSubTaskCollectionRef(taskRefId)
              .doc(subTask.subTaskId)
              .withConverter(fromFirestore: SubTask.fromFirestore, toFirestore: (SubTask subTask, options) => subTask.toFirestore())
              .set(subTask);
          subTaskProvider.addOrUpdateTask(taskRefId, subTask);
        });
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }
  
  @override
  Future<void> deleteSubTaskAttachments(String taskId, String subTaskId) async {
    final attachmentsQuerySnapshot = await getAttachmentsCollectionRef(subTaskId)
        .withConverter(fromFirestore: Attachment.fromFirestore, toFirestore: (Attachment attachment, _) => attachment.toFirestore())
        .get();
    attachmentsQuerySnapshot.docs.forEach((element) async {
      print('Deleting docs: ${element.data().toString()}');
      await element.reference.delete();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}

abstract mixin class EditTaskViewModelInputs {
  void editTasks(BuildContext context, Task? updateTask, String newTaskRefId, Map<String, dynamic> _initialTask, List<SubTask> subTasks, List<QueUser> queUsers);
  void editSubsTasks(BuildContext context, Task? updateTask, String newTaskRefId, List<SubTask> subTasks);
  Future<void> deleteSubTaskAttachments(String taskId, String subTaskId);
}
