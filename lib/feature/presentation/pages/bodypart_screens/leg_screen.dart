import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/models/exercise_model.dart';
import 'package:flutter_application_1/core/shared/machine_grid.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_application_1/core/di/injection_container.dart';
import 'package:flutter_application_1/core/repositories/gym_repository.dart';

class LegScreen extends StatefulWidget {
  const LegScreen({super.key});

  @override
  State<LegScreen> createState() => _LegScreenState();
}

class _LegScreenState extends State<LegScreen> {
  Future<List<ExerciseModel>> fetchExercises() async {
    final allExercises = await sl<GymRepository>().getAllExercises();
    // Filter for Leg exercises
    return allExercises.where((e) {
      return e.targetMuscles.any((m) => 
        m.toLowerCase().contains('leg') || 
        m.toLowerCase().contains('quad') ||
        m.toLowerCase().contains('hamstring') ||
        m.toLowerCase().contains('calf') ||
        m.toLowerCase().contains('glute')
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${AppLocalizations.of(context)!.legs} ${AppLocalizations.of(context)!.workouts}")),
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
