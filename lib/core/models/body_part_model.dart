import 'package:cloud_firestore/cloud_firestore.dart';

class BodyPartModel {
  final String id;
  final Map<String, String> name;
  final String imageUrl;
  final int order;

  BodyPartModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.order,
  });

  factory BodyPartModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    Map<String, String> nameMap;
    if (data['name'] is String) {
      nameMap = {'en': data['name']};
    } else if (data['name'] is Map) {
      nameMap = Map<String, String>.from(data['name']);
    } else {
      nameMap = {'en': 'Unknown'};
    }

    return BodyPartModel(
      id: doc.id,
      name: nameMap,
      imageUrl: data['imageUrl'] ?? '',
      order: data['order'] ?? 0,
    );
  }
}
