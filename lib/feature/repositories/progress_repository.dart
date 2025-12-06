import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/core/models/workout_model.dart';
import 'package:flutter_application_1/core/models/workout_entry.dart';

class ProgressRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ProgressRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<void> saveWorkout(WorkoutModel workout) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to save a workout');
    }

    // CRITICAL for Security Rules: userId must exactly match auth.uid
    var workoutWithUserId = workout.copyWith(userId: user.uid);

    try {
      // HYDRATION STEP: Populate missing names if IDs are present
      List<WorkoutEntry> hydratedExercises = [];
      for (var exercise in workoutWithUserId.exercises) {
        String machineName = exercise.machineName;
        String muscleName = exercise.muscleName;

        // Fetch Machine Name if missing
        if (machineName.isEmpty && exercise.machineId.isNotEmpty) {
          try {
            final machineDoc = await _firestore.collection('machines').doc(exercise.machineId).get();
            if (machineDoc.exists) {
              final data = machineDoc.data();
              // Handle potential map for localized names or string
              if (data != null) {
                if (data['name'] is String) {
                  machineName = data['name'];
                } else if (data['name'] is Map) {
                  machineName = data['name']['en'] ?? 'Unknown';
                }
              }
            }
          } catch (e) {
            print('Error hydrating machine name: $e');
          }
        }

        // Fetch Muscle Name if missing
        if (muscleName.isEmpty && exercise.muscleId.isNotEmpty) {
          try {
            final muscleDoc = await _firestore.collection('muscles').doc(exercise.muscleId).get();
            if (muscleDoc.exists) {
              final data = muscleDoc.data();
              if (data != null && data['name'] != null) {
                 muscleName = data['name'] is String ? data['name'] : (data['name']['en'] ?? 'Unknown');
              }
            }
          } catch (e) {
            print('Error hydrating muscle name: $e');
          }
        }

        hydratedExercises.add(exercise.copyWith(
          machineName: machineName.isNotEmpty ? machineName : 'Unknown',
          muscleName: muscleName.isNotEmpty ? muscleName : 'Unknown',
        ));
      }
      
      // Update the workout with hydrated exercises
      workoutWithUserId = workoutWithUserId.copyWith(exercises: hydratedExercises);

      final batch = _firestore.batch();

      // 1. Prepare Progress Document
      final progressDocRef = workoutWithUserId.id.isEmpty
          ? _firestore.collection('progress').doc()
          : _firestore.collection('progress').doc(workoutWithUserId.id);

      final finalWorkout = workoutWithUserId.copyWith(id: progressDocRef.id);
      batch.set(progressDocRef, finalWorkout.toJson());

      // 2. Prepare Stats Update
      final statsRef =
          _firestore.collection('users').doc(user.uid).collection('stats').doc('summary');

      // Collect unique machine and muscle names
      final machineNames = workoutWithUserId.exercises
          .map((e) => e.machineName)
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList();
          
      final muscleNames = workoutWithUserId.exercises
          .map((e) => e.muscleName)
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList();

      // Calculate muscle score increments (1 per occurrence as per plan)
      // Note: If 'muscle_scores' is a map, we need to use dot notation for nested fields.
      // However, Firestore increment works on specific fields.
      // Map<String, dynamic> statsUpdate = {};
      
      // We will perform the stats update. 
      // Note: We cannot easily do dynamic map key construction in a single 'update' call for nested fields 
      // if we want to be clean, but we can build a map of changes.
      // BUT for FieldValue.increment inside a map, we usually must provide the dot-notation path 
      // if the parent field is a map. e.g. "muscle_scores.Chest": FieldValue.increment(1)
      
      Map<String, dynamic> updates = {};
      
      if (machineNames.isNotEmpty) {
        updates['explored_machine_names'] = FieldValue.arrayUnion(machineNames);
      }
      if (muscleNames.isNotEmpty) {
        updates['studied_muscle_names'] = FieldValue.arrayUnion(muscleNames);
      }
      
      // Aggregate scores per muscle for this workout
      final muscleCounts = <String, int>{};
      for (var exercise in workoutWithUserId.exercises) {
        if (exercise.muscleName.isNotEmpty) {
          muscleCounts[exercise.muscleName] = (muscleCounts[exercise.muscleName] ?? 0) + 1;
        }
      }

      muscleCounts.forEach((muscle, count) {
        updates['muscle_scores.$muscle'] = FieldValue.increment(count);
      });

      // Use SetOptions(merge: true) to ensure we create the document if it doesn't exist
      // and merge our updates.
      batch.set(statsRef, updates, SetOptions(merge: true));

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to save workout batch: $e');
    }
  }
}
