import 'package:cloud_firestore/cloud_firestore.dart';

class Company {
  final String companyId;
  final String companyName;
  final int color;

  Company({
    required this.companyId, required this.companyName, required this.color
  });

  factory Company.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
    return Company(
      companyId: data?['companyId'], companyName: data?['companyName'], color: data?['color'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'companyId': companyId, 'companyName': companyName, 'color': color,
    };
  }

  @override
  String toString() {
    return 'Company: $companyId\ncompanyName: $companyName\ncolor: $color\n';
  }
}