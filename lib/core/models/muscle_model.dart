import 'package:cloud_firestore/cloud_firestore.dart';

class MuscleModel {
  final String id;
  final String name;
  final String bodyPartId;
  final String image;

  MuscleModel({
    required this.id,
    required this.name,
    required this.bodyPartId,
    required this.image,
  });

  factory MuscleModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    String nameVal = 'Unknown';
    if (data['name'] is String) {
      nameVal = data['name'];
    } else if (data['name'] is Map) {
      nameVal = data['name']['en'] ?? 'Unknown';
    }

    return MuscleModel(
      id: doc.id,
      name: nameVal,
      bodyPartId: data['bodyPartId'] ?? '',
      image: data['image'] ?? data['imageUrl'] ?? '',
    );
  }
}
