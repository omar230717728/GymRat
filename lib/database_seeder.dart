// lib/database_seeder.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseSeeder {
  final FirebaseFirestore firestore;

  DatabaseSeeder({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  /// Entry point – loads JSON and inserts everything
  Future<void> seedDatabase() async {
    print("🔥 Starting GymRat database seeding...");

    // Load seed.json
    final String jsonString = await rootBundle.loadString('assets/seed.json');
    final Map<String, dynamic> data = json.decode(jsonString);

    final List bodyParts = data['bodyParts'];

    for (var bp in bodyParts) {
      await _insertBodyPart(bp);
    }

    print("✅ GymRat database seeding completed successfully!");
  }

  /// Insert Body Part + nested muscles
  Future<void> _insertBodyPart(Map<String, dynamic> bp) async {
    final String bodyPartId = bp['id'];

    print("➡️ Inserting Body Part: $bodyPartId");

    await firestore.collection('bodyParts').doc(bodyPartId).set({
      'name': bp['name'],
      'imageUrl': bp['imageUrl'],
      'order': bp['order']
    });

    // Insert muscles
    if (bp['muscles'] != null) {
      for (var muscle in bp['muscles']) {
        await _insertMuscle(bodyPartId, muscle);
      }
    }
  }

  /// Insert Muscle + nested machines
  Future<void> _insertMuscle(String bodyPartId, Map<String, dynamic> muscle) async {
    final String muscleId = muscle['id'];

    print("   ➡️ Inserting Muscle: $muscleId under $bodyPartId");

    await firestore
        .collection('bodyParts')
        .doc(bodyPartId)
        .collection('muscles')
        .doc(muscleId)
        .set({
      'name': muscle['name'],
      'description': muscle['description'],
      'imageUrl': muscle['imageUrl'],
      'order': muscle['order']
    });

    // Insert machines
    if (muscle['machines'] != null) {
      for (var machine in muscle['machines']) {
        await _insertMachine(bodyPartId, muscleId, machine);
      }
    }
  }

  /// Insert Machine + nested exercises
  Future<void> _insertMachine(
      String bodyPartId, String muscleId, Map<String, dynamic> machine) async {
    final String machineId = machine['id'];

    print("      ➡️ Inserting Machine: $machineId");

    await firestore
        .collection('bodyParts')
        .doc(bodyPartId)
        .collection('muscles')
        .doc(muscleId)
        .collection('machines')
        .doc(machineId)
        .set({
      'name': machine['name'],
      'imageUrl': machine['imageUrl'],
      'equipmentType': machine['equipmentType'],
      'notes': machine['notes'],
      'order': machine['order']
    });

    // Insert exercises
    if (machine['exercises'] != null) {
      for (var ex in machine['exercises']) {
        await _insertExercise(bodyPartId, muscleId, machineId, ex);
      }
    }
  }

  /// Insert Exercise (final layer)
  Future<void> _insertExercise(
    String bodyPartId,
    String muscleId,
    String machineId,
    Map<String, dynamic> exercise,
  ) async {
    final String exerciseId = exercise['id'];

    print("         ➡️ Inserting Exercise: $exerciseId");

    await firestore
        .collection('bodyParts')
        .doc(bodyPartId)
        .collection('muscles')
        .doc(muscleId)
        .collection('machines')
        .doc(machineId)
        .collection('exercises')
        .doc(exerciseId)
        .set({
      'name': exercise['name'],
      'videoUrl': exercise['videoUrl'],
      'targetedMuscle': exercise['targetedMuscle'],
      'difficulty': exercise['difficulty'],
      'steps': exercise['steps'],
      'order': exercise['order'],
    });
  }
}
