import 'package:cloud_firestore/cloud_firestore.dart';

class SubTask {
  final String subTaskId;
  String title;
  String description;
  final DateTime createdOn;

  SubTask({
    required this.subTaskId,
    required this.title,
    required this.description,
    required this.createdOn,
  });

  factory SubTask.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
    return SubTask(
      subTaskId: data?['subTaskId'], title: data?['title'], description: data?['description'],
      createdOn: (data?['createdOn'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'subTaskId': subTaskId, 'title': title, 'description': description,
      'createdOn': createdOn,
    };
  }

  @override
  String toString() {
    return 'SubTask: $subTaskId\n'
        'Title: $title\nDescription: $description\n';
  }
}
