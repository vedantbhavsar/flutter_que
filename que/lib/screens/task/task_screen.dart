import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:que/helpers/constants.dart';
import 'package:que/helpers/functions.dart';
import 'package:que/models/sub_task.dart';
import 'package:que/models/task.dart';
import 'package:que/providers/auth_provider.dart';
import 'package:que/providers/sub_task_provider.dart';
import 'package:que/providers/task_provider.dart';
import 'package:que/resources/style_manager.dart';
import 'package:que/screens/attachments/attachments_screen.dart';
import 'package:que/screens/edit_task/edit_task_screen.dart';
import 'package:que/widgets/function_widgets.dart';
import 'package:que/widgets/sub_task_widget.dart';

class TaskScreen extends StatefulWidget {
  static const routeName = '/task-screen';

  const TaskScreen({Key? key}) : super(key: key);

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late int expiryInHours;
  String remainingTime = '';

  void _editTask(BuildContext context, Task task) {
    Navigator.of(context).pushNamed(EditTaskScreen.routeName, arguments: task);
  }

  void _remainingTimeForTask(Task task) {
    DateTime expiryTime;
    if (TaskTimeUnitEnum.Hours.index == task.timeUnit) {
      expiryTime = task.createdOn.add(Duration(hours:task.timeValue));
    }
    else if (TaskTimeUnitEnum.Days.index == task.timeUnit) {
      expiryTime = task.createdOn.add(Duration(days: task.timeValue));
    }
    else {
      expiryTime = task.createdOn.add(Duration(days: task.timeValue * 7));
    }
    _getTimeRemainingForTask(expiryTime);
    // _checkTaskHours();
  }

  void _getTimeRemainingForTask(DateTime expiryTime) {
    remainingTime = '';
    expiryInHours = expiryTime.difference(DateTime.now()).inHours;
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
  }

  // void _checkTaskHours() {
  //   if (expiryInHours > 48) {
  //     borderColor = Colors.green;
  //     backgroundColor = Colors.green[100];
  //   }
  //   if (expiryInHours < 48 && expiryInHours >= 24) {
  //     borderColor = Colors.orangeAccent;
  //     backgroundColor = Colors.orangeAccent[100];
  //   }
  //   if (expiryInHours < 24) {
  //     borderColor = Colors.redAccent;
  //     backgroundColor = Colors.redAccent[100];
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    final task = ModalRoute.of(context)!.settings.arguments as Task;
    final currentUserName = authProvider.displayName;
    final enableForUser = task.assignedTo == currentUserName;
    final queUser = taskProvider.queUsers.firstWhere(
            (element) => element.displayName == task.assignedTo
    );
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

    _remainingTimeForTask(task);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Row(children: [
            initialCircleWidget(task.assignedTo, queUser.color),
            const SizedBox(width: 8.0,),
            Expanded(
              child: Column(children: [
                Text(task.title),
                Text(
                  'Assigned To: ${task.assignedTo}',
                  style: getMediumFont(color: Colors.white, fontSize: 12.0,),
                ),
              ], mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start,),
            ),
          ],),
          actions: [
            if (enableForUser && task.status != TaskStatusEnum.Complete.name)
              IconButton(
                onPressed: () => _editTask(context, task),
                icon: Icon(
                  Icons.edit,
                ),
              ),
          ],
        ),
        body: Column(children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(children: [
                Expanded(
                  child: Column(children: [
                    Row(children: [
                      Text(
                        'Priority: ',
                        style: getRegularFont(
                          // color: borderColor ?? Theme.of(context).primaryColor,
                          color: Theme.of(context).primaryColor,
                          fontSize: 14.0,
                        ),
                      ),
                      if (task.priority == PriorityEnum.High.name || task.priority == PriorityEnum.Highest.name)
                        Icon(
                          Icons.priority_high_rounded,
                          color: Colors.orange,
                        ),
                      if (task.priority == PriorityEnum.Medium.name)
                        Icon(
                          Icons.priority_high,
                          color: Colors.orange,
                        ),
                      if (task.priority == PriorityEnum.Normal.name)
                        Icon(
                          Icons.low_priority_rounded,
                          color: Colors.green,
                        ),
                      if (task.priority == PriorityEnum.Blocker.name)
                        Icon(
                          Icons.block_rounded,
                          color: Colors.red,
                        ),
                      Text(
                        ' ${task.priority}',
                        style: getRegularFont(
                          // color: borderColor ?? Theme.of(context).primaryColor,
                          color: Colors.black,
                          fontSize: 14.0,
                        ),
                      ),
                    ],),
                  ], crossAxisAlignment: CrossAxisAlignment.start,),
                ),
                const SizedBox(width: 8.0,),
                Row(children: [
                  if (enableForUser)
                    Text(
                      'Status: ',
                      style: getRegularFont(
                        // color: borderColor ?? Theme.of(context).primaryColor,
                        color: Theme.of(context).primaryColor,
                        fontSize: 14.0,
                      ),
                    ),
                  Container(
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
                ],),
                const SizedBox(width: 8.0,),
              ],),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            // child: Divider(height: 1.0, thickness: 1.0, color: borderColor ?? Theme.of(context).primaryColor,),
            child: Divider(height: 1.0, thickness: 1.0, color: Theme.of(context).primaryColor,),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Column(children: [
                  Row(children: [
                    Text(
                      'Description',
                      style: getMediumFont(
                        color: Theme.of(context).primaryColor,
                        fontSize: 20.0,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed(AttachmentsScreen.routeName, arguments: task);
                      },
                      icon: Icon(
                        Icons.attach_file_outlined,
                        size: 16.0,
                      ),
                      label: Text(
                        'Attachments',
                        style: getMediumFont(
                          color: Theme.of(context).primaryColor,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ], mainAxisAlignment: MainAxisAlignment.spaceBetween,),
                  const SizedBox(height: 8.0,),
                  Text(
                    task.description,
                    style: getMediumFont(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                  ),
                ], crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start,),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            // child: Divider(height: 1.0, thickness: 1.0, color: borderColor ?? Theme.of(context).primaryColor,),
            child: Divider(height: 1.0, thickness: 1.0, color: Theme.of(context).primaryColor,),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Column(children: [
                  Text(
                    'Sub-Tasks',
                    style: getMediumFont(
                      color: Theme.of(context).primaryColor,
                      fontSize: 20.0,
                    ),
                  ),
                  const SizedBox(height: 8.0,),
                  StreamBuilder(
                    stream: getSubTaskCollectionRef(task.taskId).withConverter(fromFirestore: SubTask.fromFirestore, toFirestore: (SubTask subTask, options) => subTask.toFirestore())
                        .snapshots(),
                    builder: (context, subTaskSnapshot) {
                      if (subTaskSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: Container(child: CircularProgressIndicator(),));
                      }
                      if (!subTaskSnapshot.hasData) {
                        return Center(child: Container(child: CircularProgressIndicator(),));
                      }

                      final subTaskProvider = Provider.of<SubTaskProvider>(context, listen: false);
                      final subTaskDocs = (subTaskSnapshot.data as QuerySnapshot<SubTask>).docs;
                      subTaskDocs.map((subTaskDoc) {
                        final subTask = subTaskDoc.data();
                        print('Sub Tasks: ${subTask.toString()}');
                        subTaskProvider.addOrUpdateTask(subTask.subTaskId, subTask);
                      });
                      if (subTaskDocs.length <= 0) {
                        return Expanded(
                          child: const Center(
                            child: Text(
                              'No Sub Tasks',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 28.0,
                              ),
                          ),),
                        );
                      }
                      return Expanded(
                        child: ListView.builder(
                          itemCount: subTaskDocs.length,
                          itemBuilder: (context, index) {
                            final subTask = subTaskDocs.elementAt(index).data();
                            return SubTaskWidget.view(
                              key: ValueKey(subTask.subTaskId),
                              subTask: subTask,
                              taskId: task.taskId,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ], crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start,),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                // child: Divider(height: 1.0, thickness: 1.0, color: borderColor ?? Theme.of(context).primaryColor,),
                child: Divider(height: 1.0, thickness: 1.0, color: Theme.of(context).primaryColor,),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: Text(
                        'Created On:\n${DateFormat('dd MMM, yyyy hh:mm a').format(task.createdOn)}',
                        style: getRegularFont(
                          color: Colors.black,
                        ),
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
            ],),
          ),
        ], mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start,),
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

}
