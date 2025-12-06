import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/core/models/workout_entry.dart';

class WorkoutModel {
  final String id;
  final String userId;
  final String name;
  final DateTime timestamp;
  final int durationInSeconds;
  final List<WorkoutEntry> exercises;

  WorkoutModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.timestamp,
    required this.durationInSeconds,
    required this.exercises,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'timestamp': Timestamp.fromDate(timestamp),
      'durationInSeconds': durationInSeconds,
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
  }

  factory WorkoutModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkoutModel.fromMap(data, doc.id);
  }

  factory WorkoutModel.fromMap(Map<String, dynamic> data, String documentId) {
    return WorkoutModel(
      id: documentId,
      userId: data['userId'] ?? '',
      name: data['name'] ?? 'Workout',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      durationInSeconds: data['durationInSeconds'] ?? 0,
      exercises: (data['exercises'] as List<dynamic>?)
              ?.map((e) => WorkoutEntry.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
  
  // Create a copyWith to allow easy modification (e.g. updating ID after creation if needed, though usually handled by repo)
  WorkoutModel copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? timestamp,
    int? durationInSeconds,
    List<WorkoutEntry>? exercises,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      timestamp: timestamp ?? this.timestamp,
      durationInSeconds: durationInSeconds ?? this.durationInSeconds,
      exercises: exercises ?? this.exercises,
    );
  }
}
