import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/models/exercise_model.dart';
import 'package:flutter_application_1/core/shared/machine_grid.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_application_1/core/di/injection_container.dart';
import 'package:flutter_application_1/core/repositories/gym_repository.dart';

class BackScreen extends StatefulWidget {
  const BackScreen({super.key});

  @override
  State<BackScreen> createState() => _BackScreenState();
}

class _BackScreenState extends State<BackScreen> {
  Future<List<ExerciseModel>> fetchExercises() async {
    final allExercises = await sl<GymRepository>().getAllExercises();
    // Filter for Back exercises
    // This is a loose filter. Ideally we should use the hierarchy or a bodyPart field.
    return allExercises.where((e) {
      return e.targetMuscles.any((m) => 
        m.toLowerCase().contains('back') || 
        m.toLowerCase().contains('lats') || 
        m.toLowerCase().contains('traps')
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${AppLocalizations.of(context)!.back} ${AppLocalizations.of(context)!.workouts}")),
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
