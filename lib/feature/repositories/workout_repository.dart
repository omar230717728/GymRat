import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/core/models/workout_entry.dart';
import 'package:flutter_application_1/core/services/firestore_service.dart';

class WorkoutRepository {
  final FirestoreService _firestoreService;

  WorkoutRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Future<void> logWorkout(String userId, WorkoutEntry entry) async {
    // Save to user's workout history
    await _firestoreService.setDocument(
      path: 'users/$userId/workouts',
      docId: entry.id,
      data: entry.toMap(),
    );
        
    // Also update stats (e.g. total workouts)
    await _firestoreService.updateDocument(
      path: 'users',
      docId: userId,
      data: {
        'totalWorkouts': FieldValue.increment(1),
        'lastWorkout': Timestamp.fromDate(entry.timestamp),
      },
    );
  }

  Stream<List<WorkoutEntry>> getWorkouts(String userId) {
    return _firestoreService.getCollectionStream(
      path: 'users/$userId/workouts',
      orderByField: 'timestamp',
      descending: true,
    ).map((docs) {
      return docs.map((doc) => WorkoutEntry.fromMap(doc.data() as Map<String, dynamic>)).toList();
    });
  }

  Stream<List<WorkoutEntry>> getMachineWorkouts(String userId, String machineId) {
    return _firestoreService.getCollectionStream(
      path: 'users/$userId/workouts',
      whereField: 'machineId',
      whereValue: machineId,
      orderByField: 'timestamp',
      descending: true,
    ).map((docs) {
      return docs.map((doc) => WorkoutEntry.fromMap(doc.data() as Map<String, dynamic>)).toList();
    });
  }
}
