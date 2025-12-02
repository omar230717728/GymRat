import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/feature/repositories/workout_repository.dart';
import 'package:flutter_application_1/feature/repositories/machine_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - GymRat
  // Bloc

  // Use cases

  // Repository
  sl.registerLazySingleton(() => WorkoutRepository());
  sl.registerLazySingleton(() => MachineRepository());

  // Data sources

  //! Core

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
