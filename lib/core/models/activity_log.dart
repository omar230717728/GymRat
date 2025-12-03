import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityLog {
  final String id;
  final DateTime timestamp;
  final String? bodyPart;
  final String? muscle;
  final String? machine;
  final String? exercise;

  ActivityLog({
    required this.id,
    required this.timestamp,
    this.bodyPart,
    this.muscle,
    this.machine,
    this.exercise,
  });

  factory ActivityLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityLog(
      id: doc.id,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      bodyPart: data['bodyPart'],
      muscle: data['muscle'],
      machine: data['machine'],
      exercise: data['exercise'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': FieldValue.serverTimestamp(),
      'bodyPart': bodyPart,
      'muscle': muscle,
      'machine': machine,
      'exercise': exercise,
    };
  }
}
