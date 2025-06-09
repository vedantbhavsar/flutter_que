import 'package:cloud_firestore/cloud_firestore.dart';

class References {
  static const QUE_COLLECTION_REF = 'que';
  static const QUE_TESTING_DOC_REF = 'QueProduction';
  static const TASKS_COLLECTION_REF = 'tasks';
  static const USERS_COLLECTION_REF = 'users';
  static const COMPANIES_COLLECTION_REF = 'companies';
  static const ROLES_COLLECTION_REF = 'roles';
  static const SUB_TASKS_COLLECTION_REF = 'subtasks';
  static const ATTACHMENTS_COLLECTION_REF = 'attachments';
}

DocumentReference<Map<String, dynamic>> _getFirestoreInstance() {
  return FirebaseFirestore.instance.collection(References.QUE_COLLECTION_REF)
      .doc(References.QUE_TESTING_DOC_REF);
}

CollectionReference<Map<String, dynamic>> getTaskCollectionRef() {
  return _getFirestoreInstance().collection(References.TASKS_COLLECTION_REF);
}

CollectionReference<Map<String, dynamic>> getSubTaskCollectionRef(String taskId) {
  return _getFirestoreInstance().collection(References.TASKS_COLLECTION_REF).doc(taskId)
      .collection(References.SUB_TASKS_COLLECTION_REF);
}

CollectionReference<Map<String, dynamic>> getUserCollectionRef() {
  return _getFirestoreInstance().collection(References.USERS_COLLECTION_REF);
}

CollectionReference<Map<String, dynamic>> getCompanyCollectionRef() {
  return _getFirestoreInstance().collection(References.COMPANIES_COLLECTION_REF);
}

CollectionReference<Map<String, dynamic>> getRoleCollectionRef() {
  return _getFirestoreInstance().collection(References.ROLES_COLLECTION_REF);
}

CollectionReference<Map<String, dynamic>> getAttachmentsCollectionRef(String taskId) {
  return _getFirestoreInstance().collection(References.TASKS_COLLECTION_REF).doc(taskId)
      .collection(References.ATTACHMENTS_COLLECTION_REF);
}

CollectionReference<Map<String, dynamic>> getSubTaskAttachmentsCollectionRef(String taskId, String subTaskId) {
  return _getFirestoreInstance().collection(References.TASKS_COLLECTION_REF).doc(taskId)
      .collection(References.SUB_TASKS_COLLECTION_REF).doc(subTaskId)
      .collection(References.ATTACHMENTS_COLLECTION_REF);
}
