class Machine {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String videoUrl;
  final List<String> instructions;
  final String bodyPart; // ⭐ added back for search filters

  Machine({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.videoUrl,
    required this.instructions,
    required this.bodyPart,
  });

  // ⭐ Restore this to fix ALL your body part screens
  factory Machine.fromMap(String id, Map<String, dynamic> data) {
    return Machine(
      id: id,
      name: data['name'] ?? 'Unknown',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      bodyPart: data['bodyPart'] ?? '',           // ⭐ required
      instructions: List<String>.from(data['instructions'] ?? []),
    );
  }

  // ⭐ The one used for Firebase favorites
  factory Machine.fromFirestore(Map<String, dynamic> data, String docId) {
    return Machine(
      id: docId,
      name: data['name'] ?? 'Unknown',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      bodyPart: data['bodyPart'] ?? '',
      instructions: List<String>.from(data['instructions'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'bodyPart': bodyPart,
      'instructions': instructions,
    };
  }
}
