import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutEntry {
  final String id;
  final String machineId;
  final String machineName;
  final String muscleId;
  final String muscleName;
  final int sets;
  final int reps;
  final double weight;
  final String notes;
  final DateTime timestamp;

  WorkoutEntry({
    required this.id,
    required this.machineId,
    required this.machineName,
    required this.muscleId,
    required this.muscleName,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.notes,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'machineId': machineId,
      'machineName': machineName,
      'muscleId': muscleId,
      'muscleName': muscleName,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'notes': notes,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory WorkoutEntry.fromMap(Map<String, dynamic> map) {
    return WorkoutEntry(
      id: map['id'] ?? '',
      machineId: map['machineId'] ?? '',
      machineName: map['machineName'] ?? '',
      muscleId: map['muscleId'] ?? '',
      muscleName: map['muscleName'] ?? 'Unknown',
      sets: map['sets']?.toInt() ?? 0,
      reps: map['reps']?.toInt() ?? 0,
      weight: (map['weight'] ?? 0).toDouble(),
      notes: map['notes'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
  
  WorkoutEntry copyWith({
    String? id,
    String? machineId,
    String? machineName,
    String? muscleId,
    String? muscleName,
    int? sets,
    int? reps,
    double? weight,
    String? notes,
    DateTime? timestamp,
  }) {
    return WorkoutEntry(
      id: id ?? this.id,
      machineId: machineId ?? this.machineId,
      machineName: machineName ?? this.machineName,
      muscleId: muscleId ?? this.muscleId,
      muscleName: muscleName ?? this.muscleName,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
