import 'package:cloud_firestore/cloud_firestore.dart';

class Role {
  final String roleId;
  final String role;

  Role({
    required this.roleId, required this.role,
  });

  factory Role.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
    return Role(
      roleId: data?['roleId'], role: data?['role'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'roleId': roleId, 'role': role,
    };
  }

  @override
  String toString() {
    return 'Role: $roleId\nRole Name: $role\n';
  }
}