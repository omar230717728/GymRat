import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/core/models/body_part_model.dart';
import 'package:flutter_application_1/core/models/exercise_model.dart';
import 'package:flutter_application_1/core/models/machine_model.dart';
import 'package:flutter_application_1/core/models/muscle_model.dart';
import 'package:flutter_application_1/core/services/firestore_service.dart';

class GymRepository {
  final FirestoreService _firestoreService;

  GymRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  // Fetch Body Parts
  Future<List<BodyPartModel>> fetchBodyParts() async {
    try {
      final docs = await _firestoreService.getCollection(
        path: 'bodyParts',
        orderByField: 'order',
      );
      return docs.where((doc) {
        if (doc.data() is! Map<String, dynamic>) {
          print('Warning: Skipped invalid body part document: ${doc.id}');
          return false;
        }
        return true;
      }).map((doc) => BodyPartModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch body parts: $e');
    }
  }

  // Fetch Muscles for a Body Part
  Future<List<MuscleModel>> fetchMuscles(String bodyPartId) async {
    try {
      final docs = await _firestoreService.getCollection(
        path: 'bodyParts/$bodyPartId/muscles',
        orderByField: 'order',
      );
      return docs.where((doc) {
        if (doc.data() is! Map<String, dynamic>) {
          print('Warning: Skipped invalid muscle document: ${doc.id}');
          return false;
        }
        return true;
      }).map((doc) => MuscleModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch muscles: $e');
    }
  }

  // Fetch Machines for a Muscle
  Future<List<MachineModel>> fetchMachines(
      String bodyPartId, String muscleId) async {
    try {
      final docs = await _firestoreService.getCollection(
        path: 'bodyParts/$bodyPartId/muscles/$muscleId/machines',
        orderByField: 'order',
      );
      return docs.where((doc) {
        if (doc.data() is! Map<String, dynamic>) {
          print('Warning: Skipped invalid machine document: ${doc.id}');
          return false;
        }
        return true;
      }).map((doc) => MachineModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch machines: $e');
    }
  }

  // Fetch Exercises for a Machine
  Future<List<ExerciseModel>> fetchExercises(
      String bodyPartId, String muscleId, String machineId) async {
    try {
      final docs = await _firestoreService.getCollection(
        path:
            'bodyParts/$bodyPartId/muscles/$muscleId/machines/$machineId/exercises',
        orderByField: 'order',
      );
      return docs.where((doc) {
        if (doc.data() is! Map<String, dynamic>) {
          print('Warning: Skipped invalid exercise document: ${doc.id}');
          return false;
        }
        return true;
      }).map((doc) => ExerciseModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch exercises: $e');
    }
  }

  // Fetch Exercise Details (Optional if we pass the whole model, but good to have)
  Future<ExerciseModel> fetchExerciseDetails(
      String bodyPartId, String muscleId, String machineId, String exerciseId) async {
    try {
      final doc = await _firestoreService.getDocument(
        path:
            'bodyParts/$bodyPartId/muscles/$muscleId/machines/$machineId/exercises/$exerciseId',
      );
      return ExerciseModel.fromSnapshot(doc);
    } catch (e) {
      throw Exception('Failed to fetch exercise details: $e');
    }
  }

  // Fetch All Exercises (for Search)
  Future<List<ExerciseModel>> getAllExercises() async {
    try {
      // Use collectionGroup to query all 'exercises' collections
      final querySnapshot = await FirebaseFirestore.instance.collectionGroup('exercises').get();
      return querySnapshot.docs.where((doc) {
        if (doc.data() is! Map<String, dynamic>) {
          print('Warning: Skipped invalid exercise document in getAllExercises: ${doc.id}');
          return false;
        }
        return true;
      }).map((doc) => ExerciseModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch all exercises: $e');
    }
  }
}
