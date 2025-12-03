import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Generic method to fetch a collection
  Future<List<QueryDocumentSnapshot>> getCollection({
    required String path,
    String? orderByField,
    bool descending = false,
  }) async {
    try {
      Query query = _firestore.collection(path);

      if (orderByField != null) {
        query = query.orderBy(orderByField, descending: descending);
      }

      final snapshot = await query.get();
      return snapshot.docs;
    } catch (e) {
      throw Exception('Error fetching collection at $path: $e');
    }
  }

  // Generic method to fetch a document
  Future<DocumentSnapshot> getDocument({required String path}) async {
    try {
      final doc = await _firestore.doc(path).get();
      if (!doc.exists) {
        throw Exception('Document does not exist at $path');
      }
      return doc;
    } catch (e) {
      throw Exception('Error fetching document at $path: $e');
    }
  }

  // Generic method to add a document
  Future<DocumentReference> addDocument({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    try {
      return await _firestore.collection(path).add(data);
    } catch (e) {
      throw Exception('Error adding document at $path: $e');
    }
  }

  // Generic method to set a document
  Future<void> setDocument({
    required String path,
    required String docId,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    try {
      await _firestore.collection(path).doc(docId).set(data, SetOptions(merge: merge));
    } catch (e) {
      throw Exception('Error setting document at $path/$docId: $e');
    }
  }

  // Generic method to update a document
  Future<void> updateDocument({
    required String path,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(path).doc(docId).update(data);
    } catch (e) {
      throw Exception('Error updating document at $path/$docId: $e');
    }
  }

  // Generic method to get a collection stream
  Stream<List<QueryDocumentSnapshot>> getCollectionStream({
    required String path,
    String? orderByField,
    bool descending = false,
    String? whereField,
    dynamic whereValue,
  }) {
    try {
      Query query = _firestore.collection(path);

      if (whereField != null) {
        query = query.where(whereField, isEqualTo: whereValue);
      }

      if (orderByField != null) {
        query = query.orderBy(orderByField, descending: descending);
      }

      return query.snapshots().map((snapshot) => snapshot.docs);
    } catch (e) {
      throw Exception('Error getting collection stream at $path: $e');
    }
  }
}
