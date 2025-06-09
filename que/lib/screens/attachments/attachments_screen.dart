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
import 'package:que/models/task.dart';
import 'package:que/providers/auth_provider.dart';
import 'package:que/resources/color_manager.dart';
import 'package:que/resources/style_manager.dart';
import 'package:que/resources/value_manager.dart';

class AttachmentsScreen extends StatefulWidget {
  static const routeName = '/attachment-screen';

  const AttachmentsScreen({Key? key}) : super(key: key);

  @override
  State<AttachmentsScreen> createState() => _AttachmentsScreenState();
}

class _AttachmentsScreenState extends State<AttachmentsScreen> {
  late Task task;
  String appAttachmentFilePath = '';
  bool _isLoading = false;
  String _loadingFileName = '';
  final List<String> filePaths = [];

  @override
  void initState() {
    super.initState();
    getTemporaryDirectory().then((appDocDir) async {
      appAttachmentFilePath = "${appDocDir.path}";
    });
  }

  Future<void> _getFiles(BuildContext context) async {
    final pickedFiles = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      withData: true,
      allowedExtensions: ['pdf', 'xlsx', 'xls', 'jpg', 'jpeg', 'png', 'csv', 'doc', 'docx', 'ppt', 'pptx'],
    );
    if (pickedFiles != null) {
      try {
        final pickedFile = pickedFiles.files.elementAt(0);
        FS.FirebaseStorage.instance
            .ref('${ImageStorage.BASE_URL}/attachments/${task.taskId}/${pickedFile.name}')
            .putFile(File(pickedFile.path!))
            .then((file) async {
              String url = await file.ref.getDownloadURL();
              final attachmentDoc = getAttachmentsCollectionRef(task.taskId).doc();
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

  Future<String> createFolderStructure(Task task, Attachment attachment) async {
    _isLoading = true;
    _loadingFileName = attachment.fileName;
    final filePath = '$appAttachmentFilePath/${task.title}/${attachment.fileName}';
    final file = File(filePath);
    await file.create(recursive: true);
    filePaths.add(filePath);
    final downloadTask = FS.FirebaseStorage.instance.ref(ImageStorage.BASE_URL)
        .child('attachments').child(task.taskId).child(attachment.fileName).writeToFile(file);
    await downloadTask.whenComplete(() => null);
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

  Future<bool> _onBackClick() async {
    try {
      filePaths.forEach((element) {
        print('Deleting file $element');
        File(element).deleteSync();
      });
      filePaths.clear();
    }
    catch(error) {
      print('On Back Click error: ${error.toString()}');
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    task = ModalRoute.of(context)!.settings.arguments as Task;

    return WillPopScope(
      onWillPop: _onBackClick,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Row(children: [
            Expanded(
              child: Column(children: [
                Text('${task.title} attachments'),
                if (task.assignedTo.isNotEmpty)
                  Text(
                    'Assigned To: ${task.assignedTo}',
                    style: getMediumFont(color: Colors.white, fontSize: 12.0,),
                  ),
              ], mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start,),
            ),
          ],),
          actions: [
            IconButton(
              onPressed: () => _getFiles(context),
              icon: Icon(
                Icons.add,
              ),
            ),
          ],
        ),
        body: StreamBuilder(
          stream: task.assignedTo.isNotEmpty ? getAttachmentsCollectionRef(task.taskId)
              .withConverter(fromFirestore: Attachment.fromFirestore, toFirestore: (Attachment attachment, _) => attachment.toFirestore())
              .snapshots() : getSubTaskAttachmentsCollectionRef(task.taskId, task.description)
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
                    final filePath = await createFolderStructure(task, attachment);
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
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
