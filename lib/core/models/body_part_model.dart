import 'package:cloud_firestore/cloud_firestore.dart';

class BodyPartModel {
  final String id;
  final String name; // Keeping simple string as per user request "name", but can handle map if needed.
  // Actually user said "name", seed has "name": "Chest".
  // But previous code had localization. I'll stick to String for now to match "Fields: id, name, image".
  // If I need localization I can add it back or use a getter.
  // Let's keep it flexible: store as String, but if it comes as Map, pick 'en'.
  final String image;

  BodyPartModel({
    required this.id,
    required this.name,
    required this.image,
  });

  factory BodyPartModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    String nameVal = 'Unknown';
    if (data['name'] is String) {
      nameVal = data['name'];
    } else if (data['name'] is Map) {
      nameVal = data['name']['en'] ?? 'Unknown';
    }

    return BodyPartModel(
      id: doc.id,
      name: nameVal,
      image: data['image'] ?? data['imageUrl'] ?? '', // Handle both for safety
    );
  }
}
