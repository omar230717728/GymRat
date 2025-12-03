import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/models/exercise_model.dart';
import 'package:flutter_application_1/core/shared/machine_grid.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_application_1/core/di/injection_container.dart';
import 'package:flutter_application_1/core/repositories/gym_repository.dart';

class ArmScreen extends StatefulWidget {
  const ArmScreen({super.key});

  @override
  State<ArmScreen> createState() => _ArmScreenState();
}

class _ArmScreenState extends State<ArmScreen> {
  Future<List<ExerciseModel>> fetchExercises() async {
    final allExercises = await sl<GymRepository>().getAllExercises();
    // Filter for Arm exercises
    return allExercises.where((e) {
      return e.targetMuscles.any((m) => 
        m.toLowerCase().contains('arm') || 
        m.toLowerCase().contains('bicep') ||
        m.toLowerCase().contains('tricep') ||
        m.toLowerCase().contains('forearm')
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${AppLocalizations.of(context)!.arms} ${AppLocalizations.of(context)!.workouts}")),
      body: FutureBuilder<List<ExerciseModel>>(
        future: fetchExercises(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
             return Center(child: Text('Error: ${snapshot.error}'));
          }

          final exercises = snapshot.data ?? [];

          if (exercises.isEmpty) {
             return Center(child: Text(AppLocalizations.of(context)!.noResults));
          }

          return buildMachinesGrid(context, exercises);
        },
      ),
    );
  }
}
