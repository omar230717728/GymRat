import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseModel {
  final String id;
  final String name;
  final String muscleId;
  final String machineId;
  final String videoUrl;
  final String description;
  final String imageUrl;
  final List<String> targetMuscles;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.muscleId,
    required this.machineId,
    required this.videoUrl,
    required this.description,
    this.imageUrl = '',
    this.targetMuscles = const [],
  });

  factory ExerciseModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    String nameVal = 'Unknown';
    if (data['name'] is String) {
      nameVal = data['name'];
    } else if (data['name'] is Map) {
      nameVal = data['name']['en'] ?? 'Unknown';
    }

    return ExerciseModel(
      id: doc.id,
      name: nameVal,
      muscleId: data['muscleId'] ?? '',
      machineId: data['machineId'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? data['image'] ?? '',
      targetMuscles: List<String>.from(data['targetMuscles'] ?? []),
    );
  }
}
