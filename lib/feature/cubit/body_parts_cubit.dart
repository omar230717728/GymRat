import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_application_1/core/models/body_part_model.dart';
import 'package:flutter_application_1/core/repositories/gym_repository.dart';

// States
abstract class BodyPartsState extends Equatable {
  const BodyPartsState();

  @override
  List<Object> get props => [];
}

class BodyPartsInitial extends BodyPartsState {}

class BodyPartsLoading extends BodyPartsState {}

class BodyPartsLoaded extends BodyPartsState {
  final List<BodyPartModel> bodyParts;

  const BodyPartsLoaded(this.bodyParts);

  @override
  List<Object> get props => [bodyParts];
}

class BodyPartsError extends BodyPartsState {
  final String message;

  const BodyPartsError(this.message);

  @override
  List<Object> get props => [message];
}

// Cubit
class BodyPartsCubit extends Cubit<BodyPartsState> {
  final GymRepository _gymRepository;

  BodyPartsCubit({required GymRepository gymRepository})
      : _gymRepository = gymRepository,
        super(BodyPartsInitial());

  Future<void> loadBodyParts() async {
    emit(BodyPartsLoading());
    try {
      final bodyParts = await _gymRepository.fetchBodyParts();
      emit(BodyPartsLoaded(bodyParts));
    } catch (e) {
      emit(BodyPartsError(e.toString()));
    }
  }
}
