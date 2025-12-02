import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/core/models/workout_entry.dart';

class WorkoutRepository {
  final FirebaseFirestore _firestore;

  WorkoutRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> logWorkout(String userId, WorkoutEntry entry) async {
    // Save to user's workout history
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .doc(entry.id)
        .set(entry.toMap());
        
    // Also update stats (e.g. total workouts) - could be a cloud function, but doing it here for simplicity
    await _firestore.collection('users').doc(userId).update({
      'totalWorkouts': FieldValue.increment(1),
      'lastWorkout': Timestamp.fromDate(entry.timestamp),
    });
  }

  Stream<List<WorkoutEntry>> getWorkouts(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => WorkoutEntry.fromMap(doc.data()))
          .toList();
    });
  }

  Stream<List<WorkoutEntry>> getMachineWorkouts(String userId, String machineId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .where('machineId', isEqualTo: machineId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => WorkoutEntry.fromMap(doc.data()))
          .toList();
    });
  }
}
