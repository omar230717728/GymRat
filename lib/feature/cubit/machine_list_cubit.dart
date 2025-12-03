import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_application_1/core/models/machine_model.dart';
import 'package:flutter_application_1/core/repositories/gym_repository.dart';

// States
abstract class MachineListState extends Equatable {
  const MachineListState();

  @override
  List<Object> get props => [];
}

class MachineListInitial extends MachineListState {}

class MachineListLoading extends MachineListState {}

class MachineListLoaded extends MachineListState {
  final List<MachineModel> machines;

  const MachineListLoaded(this.machines);

  @override
  List<Object> get props => [machines];
}

class MachineListError extends MachineListState {
  final String message;

  const MachineListError(this.message);

  @override
  List<Object> get props => [message];
}

// Cubit
class MachineListCubit extends Cubit<MachineListState> {
  final GymRepository _gymRepository;

  MachineListCubit({required GymRepository gymRepository})
      : _gymRepository = gymRepository,
        super(MachineListInitial());

  Future<void> loadMachines(String bodyPartId, String muscleId) async {
    emit(MachineListLoading());
    try {
      final machines = await _gymRepository.fetchMachines(bodyPartId, muscleId);
      emit(MachineListLoaded(machines));
    } catch (e) {
      emit(MachineListError(e.toString()));
    }
  }
}
