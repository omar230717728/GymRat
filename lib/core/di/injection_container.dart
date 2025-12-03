import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/feature/repositories/workout_repository.dart';
import 'package:flutter_application_1/feature/repositories/machine_repository.dart';
import 'package:flutter_application_1/core/repositories/gym_repository.dart';
import 'package:flutter_application_1/core/repositories/activity_repository.dart';
import 'package:flutter_application_1/core/services/firestore_service.dart';
import 'package:flutter_application_1/feature/repositories/progress_repository.dart';
import 'package:flutter_application_1/feature/cubit/progress_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - GymRat
  // Bloc
  sl.registerFactory(() => ProgressCubit(
        activityRepository: sl(),
      ));

  // Use cases

  // Repository
  sl.registerLazySingleton(() => WorkoutRepository(firestoreService: sl()));
  sl.registerLazySingleton(() => MachineRepository());
  sl.registerLazySingleton(() => GymRepository(firestoreService: sl()));
  sl.registerLazySingleton(() => ActivityRepository());
  sl.registerLazySingleton(() => ProgressRepository());

  // Data sources
  sl.registerLazySingleton(() => FirestoreService());

  //! Core

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
