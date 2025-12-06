import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_application_1/core/models/exercise_model.dart';
import 'package:flutter_application_1/core/repositories/gym_repository.dart';

// States
abstract class ExerciseListState extends Equatable {
  const ExerciseListState();

  @override
  List<Object> get props => [];
}

class ExerciseListInitial extends ExerciseListState {}

class ExerciseListLoading extends ExerciseListState {}

class ExerciseListLoaded extends ExerciseListState {
  final List<ExerciseModel> exercises;

  const ExerciseListLoaded(this.exercises);

  @override
  List<Object> get props => [exercises];
}

class ExerciseListError extends ExerciseListState {
  final String message;

  const ExerciseListError(this.message);

  @override
  List<Object> get props => [message];
}

// Cubit
class ExerciseListCubit extends Cubit<ExerciseListState> {
  final GymRepository _gymRepository;

  ExerciseListCubit({required GymRepository gymRepository})
      : _gymRepository = gymRepository,
        super(ExerciseListInitial());

  Future<void> loadExercises(String muscleId) async {
    emit(ExerciseListLoading());
    try {
      final exercises = await _gymRepository.getExercisesByMuscle(muscleId);
      emit(ExerciseListLoaded(exercises));
    } catch (e) {
      emit(ExerciseListError(e.toString()));
    }
  }
}
