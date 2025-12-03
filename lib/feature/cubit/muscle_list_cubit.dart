import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_application_1/core/models/muscle_model.dart';
import 'package:flutter_application_1/core/repositories/gym_repository.dart';

// States
abstract class MuscleListState extends Equatable {
  const MuscleListState();

  @override
  List<Object> get props => [];
}

class MuscleListInitial extends MuscleListState {}

class MuscleListLoading extends MuscleListState {}

class MuscleListLoaded extends MuscleListState {
  final List<MuscleModel> muscles;

  const MuscleListLoaded(this.muscles);

  @override
  List<Object> get props => [muscles];
}

class MuscleListError extends MuscleListState {
  final String message;

  const MuscleListError(this.message);

  @override
  List<Object> get props => [message];
}

// Cubit
class MuscleListCubit extends Cubit<MuscleListState> {
  final GymRepository _gymRepository;

  MuscleListCubit({required GymRepository gymRepository})
      : _gymRepository = gymRepository,
        super(MuscleListInitial());

  Future<void> loadMuscles(String bodyPartId) async {
    emit(MuscleListLoading());
    try {
      final muscles = await _gymRepository.fetchMuscles(bodyPartId);
      emit(MuscleListLoaded(muscles));
    } catch (e) {
      emit(MuscleListError(e.toString()));
    }
  }
}
