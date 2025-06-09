import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
// @Sync()
class QueUser {
  int? id;
  @Unique(onConflict: ConflictStrategy.replace)
  final String queUserId;
  final String email;
  final String displayName;
  final String mobileNo;
  final String photoUrl;
  final String company;
  final String role;
  final int color;

  QueUser({
    int? id,
    required this.queUserId,
    required this.email,
    required this.displayName,
    required this.mobileNo,
    required this.photoUrl,
    required this.company,
    required this.role,
    required this.color,
  });

  factory QueUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
    return QueUser(
      queUserId: data?['queUserId'], email: data?['email'],
      displayName: data?['displayName'],
      mobileNo: data?['mobileNo'], photoUrl: data?['photoUrl'],
      company: data?['company'], role: data?['role'],
      color: data?['color'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'queUserId': queUserId, 'email': email,
      'displayName': displayName, 'mobileNo': mobileNo, 'photoUrl': photoUrl,
      'company': company, 'role': role, 'color': color,
    };
  }

  @override
  String toString() {
    return 'QueUser: $queUserId\nemail: $email\n'
        'displayName: $displayName\nmobileNo: $mobileNo\nphotoUrl: $photoUrl\n'
        'company: $company\nrole: $role\ncolor: $color\n';
  }
}
