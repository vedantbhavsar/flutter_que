// ignore_for_file: must_be_immutable
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as FS;
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:que/helpers/app_logs.dart';
import 'package:que/helpers/constants.dart';
import 'package:que/helpers/functions.dart';
import 'package:que/models/attachment.dart';
import 'package:que/models/que_user.dart';
import 'package:que/models/sub_task.dart';
import 'package:que/models/task.dart';
import 'package:que/providers/auth_provider.dart';
import 'package:que/providers/connection_provider.dart';
import 'package:que/providers/sub_task_provider.dart';
import 'package:que/providers/task_provider.dart';
import 'package:que/resources/color_manager.dart';
import 'package:que/resources/style_manager.dart';
import 'package:que/resources/value_manager.dart';
import 'package:que/screens/edit_task/edit_task_view_model.dart';
import 'package:que/widgets/function_widgets.dart';
import 'package:que/widgets/no_wifi_widget.dart';
import 'package:que/widgets/sub_task_widget.dart';

class EditTaskScreen extends StatefulWidget {
  static const routeName = '/edit-task';

  EditTaskScreen({Key? key}) : super(key: key);

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _timeValueFocusNode = FocusNode();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeValueController = TextEditingController();
  String taskId = '';
  String appAttachmentFilePath = '';
  bool _isLoading = false;
  String _loadingFileName = '';
  final List<String> filePaths = [];

  late List<QueUser> queUser;
  Map<String, dynamic> _initialTask = {
    'taskId': '',
    'title': '',
    'description': '',
    'timeUnit': TaskTimeUnitEnum.Hours.index,
    'timeValue': 0,
    'assignee': '',
    'assignedTo': '',
    'createdOn': Timestamp.now().toDate(),
    'priority': '',
    'status': '',
    'company': '',
    'isNotified': false,
  };
  bool _init = false;
  Task? updateTask;
  late List<SubTask> subTasks;
  final _viewModel = EditTaskViewModel();

  @override
  void initState() {
    _viewModel.start();
    super.initState();
    getTemporaryDirectory().then((appDocDir) async {
      appAttachmentFilePath = "${appDocDir.path}";
    });
    queUser = Provider.of<TaskProvider>(context, listen: false).queUsers;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_init) {
      _viewModel.initProviders(context);
      subTasks = [];
      updateTask = ModalRoute.of(context)!.settings.arguments as Task?;
      _initialTask = {
        'taskId': updateTask == null ? '' : updateTask!.taskId,
        'title': updateTask == null ? '' : updateTask!.title,
        'description': updateTask == null ? '' : updateTask!.description,
        'timeUnit': updateTask == null ? TaskTimeUnitEnum.Hours.index : updateTask!.timeUnit,
        'timeValue': updateTask == null ? 0 : updateTask!.timeValue,
        'assignee': updateTask == null ? '' : updateTask!.assignee,
        'assignedTo': updateTask == null ? '' : updateTask!.assignedTo,
        'createdOn': Timestamp.now().toDate(),
        'priority': updateTask == null ? '' : updateTask!.priority,
        'status': updateTask == null ? '' : updateTask!.status,
        'company': updateTask == null ? '' : updateTask!.company,
        'isNotified': updateTask == null ? false : updateTask!.isNotified,
      };
      if (updateTask != null) {
        taskId = updateTask!.taskId;
      }
      else {
        taskId = getTaskCollectionRef().doc().id;
      }
      subTasks = Provider.of<SubTaskProvider>(context, listen: false).subTasksByTaskId(_initialTask['taskId']);
      _init = true;
    }
  }

  void _validateAndEditTask() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    try {
      _viewModel.editTasks(context, updateTask, taskId, _initialTask, subTasks, queUser);
    }
    catch (error) {
    AppLogs().writeLog(Constants.EDIT_TASK_SCREEN_TAG, 'Task edit error: ${error.toString()}');
    _showErrorDialog(error.toString());
    }
  }

  Future<void> _deleteAttachmentsFromStorage(String subTaskId) async {
    final listResult = await FS.FirebaseStorage.instance.ref(ImageStorage.BASE_URL)
        .child('attachments').child(subTaskId).listAll();
    listResult.items.forEach((element) async {
      print('Attachments of $subTaskId: ${element.name}');
      await element.delete();
    });
  }

  Future<bool> _onBackClick() async {
    subTasks.forEach((subTask) async {
      await _deleteAttachmentsFromStorage(subTask.subTaskId);
      await _viewModel.deleteSubTaskAttachments(taskId, subTask.subTaskId);
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = Provider.of<ConnectionProvider>(context).isConnected;

    if (!isConnected) {
      return const NoWifiWidget();
    }

    return WillPopScope(
      onWillPop: _onBackClick,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: updateTask == null ? const Text('Add Task') : const Text('Update Task'),
            centerTitle: false,
          ),
          body: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 8.0,
                top: 12.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    TextFormField(
                      initialValue: _initialTask['title'],
                      focusNode: _titleFocusNode,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      style: getRegularFont(color: Theme.of(context).primaryColor, fontSize: 14.0),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: getRegularFont(color: Colors.black),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter title';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _initialTask['title'] = value;
                      },
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(_descriptionFocusNode);
                      },
                    ),
                    const SizedBox(height: 12.0),
                    // Description
                    TextFormField(
                      initialValue: _initialTask['description'],
                      focusNode: _descriptionFocusNode,
                      keyboardType: TextInputType.multiline,
                      minLines: 6,
                      maxLines: 8,
                      textAlign: TextAlign.start,
                      textAlignVertical: TextAlignVertical.top,
                      style: getRegularFont(color: Theme.of(context).primaryColor, fontSize: 14.0),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        alignLabelWithHint: true,
                        labelStyle: getRegularFont(color: Colors.black),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Description.';
                        } else if (value.length < 18) {
                          return 'Please provide more details.';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _initialTask['description'] = value;
                      },
                    ),
                    const SizedBox(height: 12.0),
                    // Time unit Dropdown and it's value
                    Text(
                      'Estimated Time',
                      style: getMediumFont(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                        child: Row(children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1.0),
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              value: _initialTask['timeUnit'] ?? 0,
                              hint: const Text('Time Unit'),
                              alignment: Alignment.center,
                              style: getMediumFont(color: Theme.of(context).primaryColor, fontSize: 14.0),
                              items: [
                                DropdownMenuItem(
                                  value: TaskTimeUnitEnum.Hours.index,
                                  child: const Text('Hours'),
                                ),
                                DropdownMenuItem(
                                  value: TaskTimeUnitEnum.Days.index,
                                  child: const Text('Days'),
                                ),
                                DropdownMenuItem(
                                  value: TaskTimeUnitEnum.Weeks.index,
                                  child: const Text('Weeks'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  if (value == TaskTimeUnitEnum.Hours.index) {
                                    _initialTask['timeUnit'] = value;
                                  } else if (value == TaskTimeUnitEnum.Days.index) {
                                    _initialTask['timeUnit'] = value;
                                  } else if (value == TaskTimeUnitEnum.Weeks.index) {
                                    _initialTask['timeUnit'] = value;
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: TextFormField(
                            initialValue: _initialTask['timeValue'].toString(),
                            focusNode: _timeValueFocusNode,
                            keyboardType: TextInputType.number,
                            style: getRegularFont(color: Theme.of(context).primaryColor, fontSize: 14.0),
                            decoration: InputDecoration(
                              labelText: 'Time Value',
                              labelStyle: getRegularFont(color: Colors.black),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Enter Number.';
                              }
                              else if (int.tryParse(value) == 0) {
                                return 'Enter valid value.';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              _initialTask['timeValue'] = int.tryParse(value);
                            },
                          ),
                        ),],
                    )),
                    const SizedBox(height: 12.0),
                    // Assign task to other or self
                    Row(children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Column(children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0, left: 10.0, bottom: 6.0),
                              child: Text(
                                'Assign To',
                                style: getMediumFont(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Theme.of(context).primaryColor, width: 1.0),
                                borderRadius: BorderRadius.all(Radius.circular(24.0)),
                                color: Colors.white,
                              ),
                              child: Center(
                                child: DropdownButton(
                                  value: _initialTask['assignedTo'].toString().isEmpty ? queUser[0].displayName : _initialTask['assignedTo'],
                                  underline: Container(),
                                  icon: Container(),
                                  hint: const Text('Assign To'),
                                  style: getMediumFont(color: Theme.of(context).primaryColor, fontSize: 14.0),
                                  menuMaxHeight: 200.0,
                                  items: queUser
                                      .map((user) => DropdownMenuItem(
                                    value: user.displayName,
                                    child: _nameDropDownItemWidget(user.displayName, user.color),
                                  )).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _initialTask['assignedTo'] = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ], crossAxisAlignment: CrossAxisAlignment.start,),
                        ),
                      ),
                      const SizedBox(width: 16.0,),
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Column(children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0, left: 10.0, bottom: 6.0),
                              child: Text(
                                'Task Priority',
                                style: getMediumFont(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Theme.of(context).primaryColor, width: 1.0),
                                borderRadius: BorderRadius.all(Radius.circular(24.0)),
                                color: Colors.white,
                              ),
                              child: Center(
                                child: DropdownButton(
                                  value: _initialTask['priority'].toString().isEmpty ? PriorityEnum.Normal.name : _initialTask['priority'],
                                  hint: const Text('Priority'),
                                  underline: Container(),
                                  alignment: Alignment.center,
                                  style: getMediumFont(color: Theme.of(context).primaryColor, fontSize: 14.0),
                                  menuMaxHeight: 200.0,
                                  items: [
                                    DropdownMenuItem(
                                      value: PriorityEnum.Blocker.name,
                                      child: priorityDropDownItemWidget(context, PriorityEnum.Blocker.name),
                                    ),
                                    DropdownMenuItem(
                                      value: PriorityEnum.Highest.name,
                                      child: priorityDropDownItemWidget(context, PriorityEnum.Highest.name),
                                    ),
                                    DropdownMenuItem(
                                      value: PriorityEnum.High.name,
                                      child: priorityDropDownItemWidget(context, PriorityEnum.High.name),
                                    ),
                                    DropdownMenuItem(
                                      value: PriorityEnum.Medium.name,
                                      child: priorityDropDownItemWidget(context, PriorityEnum.Medium.name),
                                    ),
                                    DropdownMenuItem(
                                      value: PriorityEnum.Normal.name,
                                      child: priorityDropDownItemWidget(context, PriorityEnum.Normal.name),
                                    ),
                                  ],
                                  onChanged: (itemIdentifier) {
                                    setState(() {
                                      if (itemIdentifier == PriorityEnum.Blocker.name) {
                                        _initialTask['priority'] = PriorityEnum.Blocker.name;
                                      }
                                      else if (itemIdentifier == PriorityEnum.Highest.name) {
                                        _initialTask['priority'] = PriorityEnum.Highest.name;
                                      }
                                      else if (itemIdentifier == PriorityEnum.High.name) {
                                        _initialTask['priority'] = PriorityEnum.High.name;
                                      }
                                      else if (itemIdentifier == PriorityEnum.Medium.name) {
                                        _initialTask['priority'] = PriorityEnum.Medium.name;
                                      }
                                      else if (itemIdentifier == PriorityEnum.Normal.name) {
                                        _initialTask['priority'] = PriorityEnum.Normal.name;
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                          ], crossAxisAlignment: CrossAxisAlignment.start,),
                        ),
                      ),
                    ],),
                    StreamBuilder(
                      stream: getSubTaskCollectionRef(taskId)
                          .withConverter(fromFirestore: SubTask.fromFirestore, toFirestore: (SubTask subTask, options) => subTask.toFirestore())
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final querySnapshot = snapshot.data as QuerySnapshot<SubTask>;
                        final subTasks = querySnapshot.docs;
                        return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: subTasks.length,
                          itemBuilder: (context, index) {
                            final subTask = subTasks.elementAt(index).data();
                            return SubTaskWidget.edit(
                              key: ValueKey(subTask.subTaskId),
                              subTask: subTask,
                              taskId: taskId,
                              setTitle: _setTitle,
                              setDescription: _setDescription,
                              isEditTask: _isEditTask,
                              deleteTask: _deleteTask,
                              showAttachmentBottomSheet: _showAttachmentBottomSheet,
                              deleteAttachmentsFromStorage: _deleteAttachmentsFromStorage,
                            );
                          },
                        );
                      },
                    ),
                    Row(children: [
                      // Add Sub Task Widget
                      TextButton.icon(
                        onPressed: () {
                          final subTaskRef = getSubTaskCollectionRef(taskId).doc();
                          setState(() {
                            subTasks.add(
                                SubTask(
                                  subTaskId: subTaskRef.id, title: '', description: '',
                                  createdOn: Timestamp.now().toDate(),
                                )
                            );
                          });
                        },
                        icon: Icon(
                          Icons.add,
                          color: Theme.of(context).primaryColor,
                          size: AppSize.s20,
                        ),
                        label: Text(
                          'Sub-Task',
                          style: getMediumFont(color: Theme.of(context).primaryColor, fontSize: 16.0),
                        ),
                      ),
                      // Attachments
                      TextButton.icon(
                        onPressed: () {
                          _showAttachmentBottomSheet(context, taskId, false);
                        },
                        icon: Icon(
                          Icons.attach_file_outlined,
                          size: 20.0,
                        ),
                        label: Text(
                          'Attachments',
                          style: getMediumFont(color: Theme.of(context).primaryColor, fontSize: 16.0),
                        ),
                      ),
                    ], mainAxisAlignment: MainAxisAlignment.spaceBetween,),
                    // Save Task
                    Container(
                      child: Row(children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _validateAndEditTask,
                            child: updateTask == null ? const Text('Add') : const Text('Update'),
                          ),
                        ),
                      ],),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _getFiles(BuildContext context, String taskId, bool isSubTask) async {
    final pickedFiles = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      withData: true,
      allowedExtensions: ['pdf', 'xlsx', 'xls', 'jpg', 'jpeg', 'png', 'csv', 'doc', 'docx', 'ppt', 'pptx'],
    );
    if (pickedFiles != null) {
      try {
        final pickedFile = pickedFiles.files.elementAt(0);
        FS.FirebaseStorage.instance
            .ref('${ImageStorage.BASE_URL}/attachments/$taskId/${pickedFile.name}')
            .putFile(File(pickedFile.path!))
            .then((file) async {
          String url = await file.ref.getDownloadURL();
          final attachmentDoc = isSubTask 
              ? getSubTaskAttachmentsCollectionRef(this.taskId, taskId).doc() 
              : getAttachmentsCollectionRef(taskId).doc();
          final attachment = Attachment(
            attachmentId: attachmentDoc.id,
            fileName: pickedFile.name,
            createdOn: Timestamp.now().toDate(),
            extension: pickedFile.extension ?? 'txt',
            storeUrl: url,
            uploadedBy: Provider.of<AuthProvider>(context, listen: false).displayName,
          );
          await attachmentDoc
              .withConverter(fromFirestore: Attachment.fromFirestore, toFirestore: (Attachment attachment, _) => attachment.toFirestore())
              .set(attachment);
        });
      } catch (error) {
        AppLogs().writeLog(Constants.USERNAME_PROFILE_PIC_WIDGET_TAG, 'Firebase Storage Error: ${error.toString()}');
      }
    }
  }

  Future<String> createFolderStructure(String taskId, Attachment attachment) async {
    _isLoading = true;
    _loadingFileName = attachment.fileName;
    final filePath = '$appAttachmentFilePath/$taskId/${attachment.fileName}';
    final file = File(filePath);
    await file.create(recursive: true);
    filePaths.add(filePath);
    final downloadTask = FS.FirebaseStorage.instance.ref(ImageStorage.BASE_URL)
        .child('attachments').child(taskId).child(attachment.fileName).writeToFile(file);
    await downloadTask.whenComplete(() => null);
    print('File Paths: ${filePaths.toString()}');
    _isLoading = false;
    _loadingFileName = '';
    return filePath;
  }

  Future<void> showNoAppPopup(BuildContext context, String extension) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'No App',
          style: getMediumFont(color: Theme.of(context).primaryColor, fontSize: AppSize.s16,),
        ),
        content: Text(
          'There is no app install on your device which opens .$extension files. '
              'Please install supporting app and try again.',
          style: getRegularFont(color: ColorManager.black, fontSize: AppSize.s16,),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Ok',
              style: getMediumFont(color: Theme.of(context).primaryColor, fontSize: AppSize.s16,),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAttachmentBottomSheet(BuildContext context, String taskId, bool isSubTask) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(children: [
          Row(children: [
            TextButton.icon(
              onPressed: () {},
              icon: Icon(
                Icons.attach_file_outlined,
                size: 20.0,
              ),
              label: Text(
                'Attachments',
                style: getMediumFont(color: Theme.of(context).primaryColor, fontSize: 16.0),
              ),
            ),
            IconButton(
              onPressed: () => _getFiles(context, taskId, isSubTask),
              icon: Icon(
                Icons.add,
                size: 20.0,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ], mainAxisAlignment: MainAxisAlignment.spaceBetween,),
          StreamBuilder(
            stream: isSubTask ? getSubTaskAttachmentsCollectionRef(this.taskId, taskId)
                .withConverter(fromFirestore: Attachment.fromFirestore, toFirestore: (Attachment attachment, _) => attachment.toFirestore())
                .snapshots() : getAttachmentsCollectionRef(taskId)
                .withConverter(fromFirestore: Attachment.fromFirestore, toFirestore: (Attachment attachment, _) => attachment.toFirestore())
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final querySnapshot = snapshot.data as QuerySnapshot<Attachment>;
              final docList = querySnapshot.docs;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: docList.length,
                itemBuilder: (context, index) {
                  final attachment = docList.elementAt(index).data();
                  return ListTile(
                    key: ValueKey(attachment.attachmentId),
                    onTap: !_isLoading && _loadingFileName.isEmpty ? () async {
                      final filePath = await createFolderStructure(taskId, attachment);
                      OpenFilex.open(filePath).then((openResult) {
                        if (ResultType.noAppToOpen == openResult.type) {
                          showNoAppPopup(context, attachment.extension);
                        }
                        AppLogs().writeLog(
                          Constants.ATTACHMENT_SCREEN_TAG,
                          'Open result: ${openResult.message} | ${openResult.type}',
                        );
                      }).catchError((error) {
                        AppLogs().writeLog(
                          Constants.ATTACHMENT_SCREEN_TAG,
                          'Open file error: ${error.toString()}',
                        );
                      });
                    } : () {},
                    leading: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: MediaQuery.of(context).size.height * 0.05,
                      padding: const EdgeInsets.all(AppSize.s8,),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSize.s4,),
                        color: ColorManager.lightGrey.withOpacity(0.3),
                      ),
                      child: Text(
                        attachment.extension.toUpperCase(),
                        style: getMediumFont(color: ColorManager.black, fontSize: AppSize.s20,),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    title: Text(
                      attachment.fileName,
                      style: getMediumFont(color: Theme.of(context).primaryColor, fontSize: AppSize.s16,),
                    ),
                  );
                },
              );
            },
          ),
        ],);
      },
    ).whenComplete(() {
      try {
        filePaths.forEach((element) {
          print('Deleting file $element');
          File(element).deleteSync();
        });
        filePaths.clear();
      }
      catch(error) {
        print('On bottom sheet dismiss error: ${error.toString()}');
      }
    });
  }

  void _setDescription(String subTaskId, String description) {
    subTasks.firstWhere((subTask) => subTaskId == subTask.subTaskId)
        .description = description;
  }

  void _setTitle(String subTaskId, String title) {
    subTasks.firstWhere((subTask) => subTaskId == subTask.subTaskId)
        .title = title;
  }

  void _isEditTask(String isEditTask) {

  }

  void _deleteTask(String subTaskId) {
    _viewModel.deleteSubTaskAttachments(taskId, subTaskId);
    setState(() {
      subTasks.removeWhere((subTask) => subTask.subTaskId == subTaskId);
    });
  }

  Widget _nameDropDownItemWidget(String name, int color) {
    return Row(children: [
      Container(
        child: initialCircleWidget(name, color),
      ),
      const SizedBox(width: 8.0,),
      Text(name, style: getSemiBoldFont(color: Theme.of(context).primaryColor),),
    ],);
  }

  _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error!'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _timeValueFocusNode.dispose();
    _timeValueController.dispose();

    getTaskCollectionRef().doc(taskId).withConverter(fromFirestore: Task.fromFirestore, toFirestore: (Task task, options) => task.toFirestore())
        .get().then((value) {
          if (value.data() == null) {
            getTaskCollectionRef().doc(taskId).delete();
          }
    });
  }
}
