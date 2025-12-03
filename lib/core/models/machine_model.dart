import 'package:cloud_firestore/cloud_firestore.dart';

class MachineModel {
  final String id;
  final Map<String, String> name;
  final String imageUrl;
  final Map<String, String> description;
  final int order;

  MachineModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.order,
  });

  factory MachineModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    Map<String, String> nameMap;
    if (data['name'] is String) {
      nameMap = {'en': data['name']};
    } else if (data['name'] is Map) {
      nameMap = Map<String, String>.from(data['name']);
    } else {
      nameMap = {'en': 'Unknown'};
    }

    return MachineModel(
      id: doc.id,
      name: nameMap,
      imageUrl: data['imageUrl'] ?? '',
      description: Map<String, String>.from(data['description'] ?? {}),
      order: data['order'] ?? 0,
    );
  }
}
