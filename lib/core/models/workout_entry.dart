import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutEntry {
  final String id;
  final String machineId;
  final String machineName;
  final int sets;
  final int reps;
  final double weight;
  final String notes;
  final DateTime timestamp;

  WorkoutEntry({
    required this.id,
    required this.machineId,
    required this.machineName,
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
      sets: map['sets']?.toInt() ?? 0,
      reps: map['reps']?.toInt() ?? 0,
      weight: (map['weight'] ?? 0).toDouble(),
      notes: map['notes'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
