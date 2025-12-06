import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/core/repositories/gym_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - GymRat
  // Bloc

  // Use cases
  sl.registerLazySingleton(() => GymRepository());

  // Data sources

  //! Core

  //! Core

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
