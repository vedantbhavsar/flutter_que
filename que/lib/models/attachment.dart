import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
// @Sync()
class Attachment {
  int? id;
  @Unique(onConflict: ConflictStrategy.replace)
  final String attachmentId;
  final String fileName;
  final String uploadedBy;
  final DateTime createdOn;
  final String storeUrl;
  final String extension;

  Attachment({
    int? id,
    required this.attachmentId,
    required this.fileName,
    required this.uploadedBy,
    required this.createdOn,
    required this.storeUrl,
    required this.extension,
  });

  factory Attachment.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
    return Attachment(
      attachmentId: data?['attachmentId'], fileName: data?['fileName'], storeUrl: data?['storeUrl'],
      uploadedBy: data?['uploadedBy'],
      extension: data?['extension'], createdOn: (data?['createdOn'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'attachmentId': attachmentId, 'fileName': fileName, 'storeUrl': storeUrl, 'extension': extension,
      'uploadedBy': uploadedBy, 'createdOn': createdOn,
    };
  }

  @override
  String toString() {
    return 'Attachment{fileName: $fileName, createdOn: $createdOn, extension: $extension, storeUrl: $storeUrl}';
  }
}
