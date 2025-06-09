// ignore_for_file: must_be_immutable

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:que/helpers/constants.dart';
import 'package:que/helpers/db_helper.dart';
import 'package:que/helpers/functions.dart';
import 'package:que/models/task.dart';
import 'package:que/providers/auth_provider.dart';
import 'package:que/providers/task_provider.dart';
import 'package:que/resources/style_manager.dart';
import 'package:que/screens/home/home_view_model.dart';
import 'package:que/widgets/function_widgets.dart';

class TaskWidget extends StatefulWidget {
  final HomeViewModel homeViewModel;
  final Task task;
  final Function editTask;
  bool isExpand;
  TaskWidget({
    Key? key, required this.homeViewModel, required this.task, required this.editTask,
    this.isExpand = false
  }) : super(key: key);

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  Color? borderColor;
  Color? backgroundColor;
  Timer? _taskTimer;
  late int expiryInHours;
  String remainingTime = '';

  @override
  void initState() {
    super.initState();
    expiryInHours = widget.homeViewModel.taskExpiryInHours(widget.task);
    remainingTime = widget.homeViewModel.taskRemainingTime(expiryInHours);
    // AppLogs().writeLog(Constants.TASK_WIDGET_TAG, '${widget.task.toString()}\nTime Remaining: $remainingTime\nExpiry Time: $expiryInHours');
    checkTaskHours();
    _taskTimer = Timer.periodic(Duration(seconds: 10), (timer) => setBackgroundBorderColor());
  }

  void checkTaskHours() {
    if (expiryInHours >= 48) {
      borderColor = Colors.green;
      backgroundColor = Colors.green[100];
    }
    if (expiryInHours < 48 && expiryInHours >= 24) {
      borderColor = Colors.orangeAccent;
      backgroundColor = Colors.orangeAccent[100];
    }
    if (expiryInHours < 24) {
      borderColor = Colors.redAccent;
      backgroundColor = Colors.redAccent[100];
    }
  }

  void setBackgroundBorderColor() {
    setState(() {
      checkTaskHours();
    });
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final currentUserName = Provider.of<AuthProvider>(context, listen: false).displayName;
    final enableForUser = task.assignedTo == currentUserName;
    final queUser = DbHelper.getDbHelper.getAllQueUsers()
        .firstWhere((element) => element.displayName == task.assignedTo);
    List<String> status = [];
    if (task.status == TaskStatusEnum.Start.name) {
      status = [
        TaskStatusEnum.In_Progress.name.replaceAll('_', ' '),
      ];
    }
    else if (task.status == TaskStatusEnum.In_Progress.name.replaceAll('_', ' ')) {
      status = [
        TaskStatusEnum.On_Hold.name.replaceAll('_', ' '),
        TaskStatusEnum.Complete.name,
      ];
    }
    else if (task.status == TaskStatusEnum.On_Hold.name.replaceAll('_', ' ')) {
      status = [
        TaskStatusEnum.In_Progress.name.replaceAll('_', ' '),
      ];
    }

    return Padding(
      padding: !widget.isExpand ? const EdgeInsets.only(top: 6.0) : const EdgeInsets.only(top: 0.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor ?? Theme.of(context).primaryColor, width: 0.5),
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
          color: backgroundColor == null
              ? Theme.of(context).primaryColor.withOpacity(0.3)
              : backgroundColor!.withOpacity(0.3),
        ),
        child: Column(children: [
          Row(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: initialCircleWidget(queUser.displayName, queUser.color),
            ),
            Expanded(
              child: Column(children: [
                Text(
                  task.title,
                  style: getMediumFont(
                    color: borderColor ?? Theme.of(context).primaryColor,
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 6.0,),
                Text(
                  '${DateFormat('dd MMM, yyyy hh:mm a').format(task.createdOn)}',
                  style: getMediumFont(
                    color: Colors.black45,
                    fontSize: 10.0,
                  ),
                ),
              ], crossAxisAlignment: CrossAxisAlignment.start,),
            ),
            const SizedBox(width: 8.0,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: !enableForUser
                    ? Text('Status: ${task.status}', style: getSemiBoldFont(color: Colors.black, fontSize: 14.0),)
                    : DropdownButton(
                  hint: Text('${task.status}'),
                  underline: Divider(height: 1.0, color: Colors.black, thickness: 1.5,),
                  style: getMediumFont(color: Colors.black),
                  items: status.map((element) {
                    return DropdownMenuItem(
                      value: element,
                      child: Text(element),
                    );
                  }).toList(),
                  onChanged: (itemIdentifier) {
                    setState(() {
                      _updateTaskStatus(task, itemIdentifier as String);
                    });
                  },
                ),
              ),
            ),
            if (widget.isExpand && enableForUser)
              IconButton(
                onPressed: () => widget.editTask(context, task),
                icon: Icon(
                  Icons.edit,
                  color: borderColor ?? Theme.of(context).primaryColor,
                ),
              ),
            if (task.priority == PriorityEnum.High.name || task.priority == PriorityEnum.Highest.name)
              Icon(
                Icons.priority_high_rounded,
                color: Colors.orange,
              ),
            if (task.priority == PriorityEnum.Normal.name)
              Icon(
                Icons.low_priority_rounded,
                color: Colors.green,
              ),
            if (task.priority == PriorityEnum.Medium.name)
              Icon(
                Icons.priority_high,
                color: Colors.orange,
              ),
            if (task.priority == PriorityEnum.Blocker.name)
              Icon(
                Icons.block_rounded,
                color: Colors.red,
              ),
            const SizedBox(width: 8.0,),
          ],),
          // if (widget.isExpand)
          //   expandedTaskWidget(task),
        ],),
      ),
    );
  }
  
  void _updateTaskStatus(Task task, String itemIdentifier) {
    Provider.of<TaskProvider>(context, listen: false).removeTaskFromList(task);
    final updateTask = Task(
        taskId: task.taskId, title: task.title, description: task.description,
        timeUnit: task.timeUnit, timeValue: task.timeValue, assignee: task.assignee,
        assignedTo: task.assignedTo, createdOn: task.createdOn,
        priority: task.priority, status: itemIdentifier, company: task.company, isNotified: task.isNotified,
    );
    getTaskCollectionRef().doc(task.taskId)
        .withConverter(fromFirestore: Task.fromFirestore, toFirestore: (Task task, options) => task.toFirestore())
        .set(updateTask, SetOptions(merge: true));
    Provider.of<TaskProvider>(context, listen: false).addOrUpdateTask(updateTask);
    Provider.of<TaskProvider>(context, listen: false).getUpdates();
  }
  
  Widget expandedTaskWidget(Task task) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: Divider(height: 1.0, thickness: 1.0, color: borderColor ?? Theme.of(context).primaryColor,),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(children: [
          Expanded(
            flex: 1,
            child: Container(
              child: Text(
                'Assigned to: ${task.assignedTo}',
                style: getRegularFont(color: Colors.black),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: Text(
                remainingTime == '0' ? 'Time Up!!!' : 'Remaining: $remainingTime',
                style: getRegularFont(color: Colors.black),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ], mainAxisAlignment: MainAxisAlignment.spaceBetween,),
      ),
    ],);
  }

  @override
  void dispose() {
    super.dispose();
    _taskTimer!.cancel();
  }
}
