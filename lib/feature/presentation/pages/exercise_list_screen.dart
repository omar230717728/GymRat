import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/feature/cubit/exercise_list_cubit.dart';
import 'package:flutter_application_1/feature/cubit/language_cubit.dart';
import 'package:flutter_application_1/core/shared/machine_grid.dart';


class ExerciseListScreen extends StatefulWidget {
  final String bodyPartId;
  final String muscleId;
  final String machineId;
  final Map<String, String> machineName;

  const ExerciseListScreen({
    super.key,
    required this.bodyPartId,
    required this.muscleId,
    required this.machineId,
    required this.machineName,
  });

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ExerciseListCubit>().loadExercises(
        widget.bodyPartId, widget.muscleId, widget.machineId);
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = context.select((LanguageCubit cubit) => cubit.state.locale.languageCode);
    final title = widget.machineName[languageCode] ?? widget.machineName['en'] ?? 'Exercises';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: BlocBuilder<ExerciseListCubit, ExerciseListState>(
        builder: (context, state) {
          if (state is ExerciseListLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ExerciseListLoaded) {
            if (state.exercises.isEmpty) {
              return const Center(child: Text('No exercises found'));
            }
            return buildMachinesGrid(context, state.exercises);
          } else if (state is ExerciseListError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Select a machine'));
        },
      ),
    );
  }
}
