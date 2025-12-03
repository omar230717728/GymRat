import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseModel {
  final String id;
  final Map<String, String> name;
  final String imageUrl;
  final String videoUrl;
  final List<String> steps;
  final List<String> commonMistakes;
  final List<String> targetMuscles;
  final int order;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.videoUrl,
    required this.steps,
    required this.commonMistakes,
    required this.targetMuscles,
    required this.order,
  });

  factory ExerciseModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    Map<String, String> nameMap;
    if (data['name'] is String) {
      nameMap = {'en': data['name']};
    } else if (data['name'] is Map) {
      nameMap = Map<String, String>.from(data['name']);
    } else {
      nameMap = {'en': 'Unknown'};
    }

    return ExerciseModel(
      id: doc.id,
      name: nameMap,
      imageUrl: data['imageUrl'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      steps: List<String>.from(data['steps'] ?? []),
      commonMistakes: List<String>.from(data['commonMistakes'] ?? []),
      targetMuscles: List<String>.from(data['targetMuscles'] ?? []),
      order: data['order'] ?? 0,
    );
  }
}
