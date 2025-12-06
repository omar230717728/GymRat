import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressModel {
  final String userId;
  final String exerciseId;
  final DateTime completedAt;
  final String? bodyPartId;

  ProgressModel({
    required this.userId,
    required this.exerciseId,
    required this.completedAt,
    this.bodyPartId,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'exerciseId': exerciseId,
      'completedAt': Timestamp.fromDate(completedAt),
      if (bodyPartId != null) 'bodyPartId': bodyPartId,
    };
  }

  factory ProgressModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProgressModel(
      userId: data['userId'] ?? '',
      exerciseId: data['exerciseId'] ?? '',
      completedAt: (data['completedAt'] as Timestamp).toDate(),
      bodyPartId: data['bodyPartId'],
    );
  }
}
