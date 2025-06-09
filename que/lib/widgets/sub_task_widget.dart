// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:que/models/sub_task.dart';
import 'package:que/models/task.dart';
import 'package:que/resources/color_manager.dart';
import 'package:que/resources/style_manager.dart';
import 'package:que/resources/value_manager.dart';
import 'package:que/screens/attachments/attachments_screen.dart';

class SubTaskWidget extends StatefulWidget {
  final SubTask subTask;
  final String taskId;
  bool isEdit;
  Function? setTitle;
  Function? setDescription;
  Function? isEditTask;
  Function? deleteTask;
  Function? showAttachmentBottomSheet;
  Function? deleteAttachmentsFromStorage;

  SubTaskWidget.edit({
    Key? key,
    required this.subTask,
    required this.taskId,
    this.isEdit = true,
    required this.setTitle,
    required this.setDescription,
    required this.isEditTask,
    required this.deleteTask,
    required this.showAttachmentBottomSheet,
    required this.deleteAttachmentsFromStorage,
  }) : super(key: key);

  SubTaskWidget.view({
    Key? key,
    required this.subTask,
    required this.taskId,
    this.isEdit = false,
  }) : super(key: key);

  @override
  State<SubTaskWidget> createState() => _SubTaskWidgetState();
}

class _SubTaskWidgetState extends State<SubTaskWidget> {
  final titleController = TextEditingController();

  final descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final subTask = widget.subTask;
    if (subTask.title.isNotEmpty) {
      titleController.text = subTask.title;
    }
    if (subTask.description.isNotEmpty) {
      descController.text = subTask.description;
    }

    if (widget.isEdit) {
      return Container(
        margin: const EdgeInsets.only(top: 12.0,),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor,),
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        child: Column(children: [
          Row(children: [
            Row(children: [
              Icon(
                Icons.task_outlined,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: AppSize.s6,),
              Text(
                'Sub-Task',
                style: getSemiBoldFont(color: Theme.of(context).primaryColor, fontSize: 16.0,),
              ),
            ],),
            Row(children: [
              IconButton(
                onPressed: () {
                  widget.showAttachmentBottomSheet!(context, subTask.subTaskId, true);
                },
                icon: Icon(Icons.attach_file_outlined, color: Theme.of(context).primaryColor,),
              ),
              IconButton(
                onPressed: () async {
                  await widget.deleteAttachmentsFromStorage!(subTask.subTaskId);
                  widget.deleteTask!(subTask.subTaskId);
                },
                icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error,),
              ),
            ],),
          ], mainAxisAlignment: MainAxisAlignment.spaceBetween,),
          TextField(
            controller: titleController,
            keyboardType: TextInputType.text,
            style: getRegularFont(color: Theme.of(context).primaryColor, fontSize: 14.0),
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Title',
              labelStyle: getRegularFont(color: Colors.black),
            ),
            textInputAction: TextInputAction.next,
            onChanged: (value) {
              widget.setTitle!(subTask.subTaskId, value);
            },
          ),
          const SizedBox(height: 12.0,),
          TextField(
            controller: descController,
            keyboardType: TextInputType.text,
            style: getRegularFont(color: Theme.of(context).primaryColor, fontSize: 14.0),
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Description',
              labelStyle: getRegularFont(color: Colors.black),
            ),
            textInputAction: TextInputAction.done,
            onChanged: (value) {
              widget.setDescription!(subTask.subTaskId, value);
            },
          ),
        ],),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSize.s4,),
      child: ListTile(
        tileColor: ColorManager.lightGrey.withOpacity(0.2),
        title: Text(
          '${subTask.title}',
          style: getMediumFont(color: Theme.of(context).primaryColor, fontSize: 14.0),
        ),
        subtitle: Text(
          '${subTask.description}',
          style: getRegularFont(color: Theme.of(context).primaryColor, fontSize: 14.0),
        ),
        trailing: IconButton(
          onPressed: () {
            final task = Task(
              taskId: widget.taskId, title: subTask.title, description: subTask.subTaskId,
              timeUnit: 0, timeValue: 0, assignee: '', assignedTo: '', createdOn: subTask.createdOn,
              priority: '', status: '', company: '', isNotified: true,
            );
            Navigator.of(context).pushNamed(AttachmentsScreen.routeName, arguments: task);
          },
          icon: Icon(
            Icons.attach_file_outlined,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}
