import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
// @Sync()
class Task {
  int? id;
  @Unique(onConflict: ConflictStrategy.replace)
  final String taskId;
  final String title;
  final String description;
  final int timeUnit;
  final int timeValue;
  final String assignee;
  final String assignedTo;
  final DateTime createdOn;
  final String priority;
  final String status;
  final String company;
  final bool isNotified;

  Task({
    int? id,
    required this.taskId,
    required this.title,
    required this.description,
    required this.timeUnit,
    required this.timeValue,
    required this.assignee,
    required this.assignedTo,
    required this.createdOn,
    required this.priority,
    required this.status,
    required this.company,
    required this.isNotified,
  });

  factory Task.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
    return Task(
      taskId: data?['taskId'], title: data?['title'], description: data?['description'],
      timeUnit: data?['timeUnit'], timeValue: data?['timeValue'],
      assignee: data?['assignee'], assignedTo: data?['assignedTo'],
      createdOn: (data?['createdOn'] as Timestamp).toDate(),
      priority: data?['priority'] == null ? '' : data?['priority'],
      status: data?['status'] == null ? 'Start' : data?['status'],
      company: data?['company'] == null ? 'TCS' : data?['company'],
      isNotified: data?['isNotified'] == null ? false : data?['isNotified'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'taskId': taskId, 'title': title, 'description': description, 'timeUnit': timeUnit,
      'timeValue': timeValue, 'assignee': assignee, 'assignedTo': assignedTo,
      'createdOn': createdOn, 'priority': priority, 'status': status,
      'company': company, 'isNotified': isNotified,
    };
  }

  @override
  String toString() {
    return 'Task: $taskId\n'
        'Title: $title\nDescription: $description\nTimeUnit: $timeUnit\n'
        'TimeValue: $timeValue\nAssignee: $assignee\nAssignedTo: $assignedTo\n'
        'Created On: $createdOn\nPriority: $priority\nStatus: $status\n'
        'company: $company\n';
  }
}
