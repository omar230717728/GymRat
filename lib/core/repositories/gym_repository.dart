import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/core/models/body_part_model.dart';
import 'package:flutter_application_1/core/models/exercise_model.dart';
import 'package:flutter_application_1/core/models/machine_model.dart';
import 'package:flutter_application_1/core/models/muscle_model.dart';

class GymRepository {
  final FirebaseFirestore _firestore;

  GymRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Fetch Body Parts
  Future<List<BodyPartModel>> fetchBodyParts() async {
    try {
      final snapshot = await _firestore.collection('bodyParts').get();
      return snapshot.docs.map((doc) => BodyPartModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch body parts: $e');
    }
  }

  // Fetch Muscles by BodyPartId
  Future<List<MuscleModel>> fetchMuscles(String bodyPartId) async {
    try {
      final snapshot = await _firestore
          .collection('muscles')
          .where('bodyPartId', isEqualTo: bodyPartId)
          .get();
      return snapshot.docs.map((doc) => MuscleModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch muscles: $e');
    }
  }

  // Fetch Exercises by MuscleId
  Future<List<ExerciseModel>> fetchExercises(String muscleId) async {
    try {
      final snapshot = await _firestore
          .collection('exercises')
          .where('muscleId', isEqualTo: muscleId)
          .get();
      return snapshot.docs.map((doc) => ExerciseModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch exercises: $e');
    }
  }

  // Alias for fetchExercises to satisfy strict requirement
  Future<List<ExerciseModel>> getExercisesByMuscle(String muscleId) async {
    return fetchExercises(muscleId);
  }

  // Fetch Exercises by MachineId
  Future<List<ExerciseModel>> fetchExercisesByMachineId(String machineId) async {
    try {
      final snapshot = await _firestore
          .collection('exercises')
          .where('machineId', isEqualTo: machineId)
          .get();
      return snapshot.docs.map((doc) => ExerciseModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch exercises by machine: $e');
    }
  }

  final Map<String, MachineModel> _machineCache = {};

  // Fetch Machine by MachineId
  Future<MachineModel?> fetchMachine(String machineId) async {
    if (_machineCache.containsKey(machineId)) {
      return _machineCache[machineId];
    }

    try {
      final doc = await _firestore.collection('machines').doc(machineId).get();
      if (doc.exists) {
        final machine = MachineModel.fromSnapshot(doc);
        _machineCache[machineId] = machine;
        return machine;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch machine: $e');
    }
  }

  // Fetch All Exercises
  Future<List<ExerciseModel>> getAllExercises() async {
    try {
      final snapshot = await _firestore.collection('exercises').get();
      return snapshot.docs.map((doc) => ExerciseModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch all exercises: $e');
    }
  }

  // Fetch Machines by IDs (Chunked)
  Future<List<MachineModel>> getMachinesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    
    final List<MachineModel> machines = [];
    // Firestore limits 'whereIn' to 10 values (or 30 in some versions, sticking to 10 for safety)
    final chunkSize = 10;
    
    for (var i = 0; i < ids.length; i += chunkSize) {
      final chunk = ids.sublist(i, i + chunkSize > ids.length ? ids.length : i + chunkSize);
      try {
        final snapshot = await _firestore
            .collection('machines')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        machines.addAll(snapshot.docs.map((doc) => MachineModel.fromSnapshot(doc)));
      } catch (e) {
        // Log error but continue fetching other chunks
        print('Error fetching machine chunk: $e');
      }
    }
    return machines;
  }
}