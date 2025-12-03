import 'package:cloud_firestore/cloud_firestore.dart';

class MuscleModel {
  final String id;
  final Map<String, String> name;
  final String imageUrl;
  final int order;

  MuscleModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.order,
  });

  factory MuscleModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    Map<String, String> nameMap;
    if (data['name'] is String) {
      nameMap = {'en': data['name']};
    } else if (data['name'] is Map) {
      nameMap = Map<String, String>.from(data['name']);
    } else {
      nameMap = {'en': 'Unknown'};
    }

    return MuscleModel(
      id: doc.id,
      name: nameMap,
      imageUrl: data['imageUrl'] ?? '',
      order: data['order'] ?? 0,
    );
  }
}
