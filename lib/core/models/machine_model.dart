import 'package:cloud_firestore/cloud_firestore.dart';

class MachineModel {
  final String id;
  final String name;
  final String image;
  final String equipmentType;
  final List<String> bodyParts;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;

  MachineModel({
    required this.id,
    required this.name,
    required this.image,
    required this.equipmentType,
    required this.bodyParts,
    required this.primaryMuscles,
    required this.secondaryMuscles,
  });

  factory MachineModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    String nameVal = 'Unknown';
    if (data['name'] is String) {
      nameVal = data['name'];
    } else if (data['name'] is Map) {
      nameVal = data['name']['en'] ?? 'Unknown';
    }

    return MachineModel(
      id: doc.id,
      name: nameVal,
      image: data['image'] ?? data['imageUrl'] ?? '',
      equipmentType: data['equipmentType'] ?? '',
      bodyParts: List<String>.from(data['bodyParts'] ?? []),
      primaryMuscles: List<String>.from(data['primaryMuscles'] ?? []),
      secondaryMuscles: List<String>.from(data['secondaryMuscles'] ?? []),
    );
  }
}
