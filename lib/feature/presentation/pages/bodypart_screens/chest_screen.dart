import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/models/exercise_model.dart';
import 'package:flutter_application_1/core/shared/machine_grid.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_application_1/core/di/injection_container.dart';
import 'package:flutter_application_1/core/repositories/gym_repository.dart';

class ChestScreen extends StatefulWidget {
  const ChestScreen({super.key});

  @override
  State<ChestScreen> createState() => _ChestScreenState();
}

class _ChestScreenState extends State<ChestScreen> {
  Future<List<ExerciseModel>> fetchExercises() async {
    final allExercises = await sl<GymRepository>().getAllExercises();
    // Filter for Chest exercises
    return allExercises.where((e) {
      return e.targetMuscles.any((m) => 
        m.toLowerCase().contains('chest') || 
        m.toLowerCase().contains('pectoral')
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${AppLocalizations.of(context)!.chest} ${AppLocalizations.of(context)!.workouts}")),
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
