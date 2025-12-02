class Machine {
  final String id;
  final Map<String, dynamic> name;
  final Map<String, dynamic> description;
  final String imageUrl;
  final String videoUrl;
  final Map<String, dynamic> instructions;
  final String bodyPart;
  final String difficulty;
  final Map<String, dynamic> targetMuscles;

  Machine({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.videoUrl,
    required this.instructions,
    required this.bodyPart,
    this.difficulty = 'beginner',
    this.targetMuscles = const {},
  });

  factory Machine.fromMap(String id, Map<String, dynamic> data) {
    return Machine(
      id: id,
      name: data['name'] is Map ? data['name'] : {'en': data['name'] ?? 'Unknown'},
      description: data['description'] is Map ? data['description'] : {'en': data['description'] ?? ''},
      imageUrl: data['imageUrl'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      bodyPart: data['bodyPart'] ?? '',
      instructions: data['instructions'] is Map 
          ? data['instructions'] 
          : {'en': List<String>.from(data['instructions'] ?? [])},
      difficulty: data['difficulty'] ?? 'beginner',
      targetMuscles: data['targetMuscles'] is Map
          ? data['targetMuscles']
          : {'en': List<String>.from(data['targetMuscles'] ?? [])},
    );
  }

  factory Machine.fromFirestore(Map<String, dynamic> data, String docId) {
    return Machine.fromMap(docId, data);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'bodyPart': bodyPart,
      'instructions': instructions,
      'difficulty': difficulty,
      'targetMuscles': targetMuscles,
    };
  }

  String getName(String locale) {
    return name[locale] ?? name['en'] ?? 'Unknown';
  }

  String getDescription(String locale) {
    return description[locale] ?? description['en'] ?? '';
  }

  List<String> getInstructions(String locale) {
    final inst = instructions[locale] ?? instructions['en'];
    if (inst is List) {
      return List<String>.from(inst);
    }
    return [];
  }

  List<String> getTargetMuscles(String locale) {
    final muscles = targetMuscles[locale] ?? targetMuscles['en'];
    if (muscles is List) {
      return List<String>.from(muscles);
    }
    return [];
  }
}
