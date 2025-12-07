import 'package:flutter/material.dart';
import 'package:flutter_application_1/feature/presentation/pages/details_screen/machine_detail.dart';
import 'package:flutter_application_1/core/repositories/gym_repository.dart';
import 'package:flutter_application_1/core/di/injection_container.dart' as di;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/feature/cubit/exercise_list_cubit.dart';
import 'package:flutter_application_1/feature/presentation/widgets/exercise_card.dart'; // <--- IMPORT

class ExerciseListScreen extends StatefulWidget {
  final String bodyPartId;
  final String muscleId;
  final String muscleName;

  const ExerciseListScreen({
    super.key,
    required this.bodyPartId,
    required this.muscleId,
    required this.muscleName,
  });

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExerciseListCubit(
        gymRepository: di.sl<GymRepository>(),
      )..loadExercises(widget.muscleId),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.muscleName),
        ),
        body: BlocBuilder<ExerciseListCubit, ExerciseListState>(
          builder: (context, state) {
            if (state is ExerciseListLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ExerciseListError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is ExerciseListLoaded) {
              if (state.exercises.isEmpty) {
                return const Center(child: Text('No exercises found'));
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                itemCount: state.exercises.length,
                itemBuilder: (context, index) {
                  final exercise = state.exercises[index];
                  // Use exercise.imageUrl directly as per new model
                  final imageUrl = exercise.imageUrl;

                  return ExerciseCard(
                    title: exercise.name,
                    subtitle: exercise.targetMuscles.isNotEmpty ? exercise.targetMuscles.first : "Exercise",
                    imageUrl: exercise.imageUrl,
                    width: double.infinity,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MachineDetailScreen(
                            exercise: exercise,
                            bodyPartId: widget.bodyPartId,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
