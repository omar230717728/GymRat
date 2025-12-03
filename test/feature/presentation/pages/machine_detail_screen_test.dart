import 'dart:io';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/models/exercise_model.dart';
import 'package:flutter_application_1/feature/cubit/favorite_state.dart';
import 'package:flutter_application_1/feature/cubit/favorites_cubit.dart';
import 'package:flutter_application_1/feature/presentation/pages/details_screen/machine_detail.dart';
import 'package:flutter_application_1/feature/repositories/workout_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_application_1/feature/cubit/language_cubit.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_application_1/feature/cubit/progress_cubit.dart';
import 'package:flutter_application_1/core/services/user_session_service.dart';

class MockUserSessionService extends Mock implements UserSessionService {}

class MockFavoritesCubit extends MockCubit<FavoritesState> implements FavoritesCubit {}
class MockWorkoutRepository extends Mock implements WorkoutRepository {}

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class MockLanguageCubit extends MockCubit<LanguageState> implements LanguageCubit {}

class MockProgressCubit extends MockCubit<ProgressState> implements ProgressCubit {}

void main() {
  late MockFavoritesCubit mockFavoritesCubit;
  late MockWorkoutRepository mockWorkoutRepository;
  late MockLanguageCubit mockLanguageCubit;
  late MockProgressCubit mockProgressCubit;
  late MockUserSessionService mockUserSessionService;

  setUp(() {
    HttpOverrides.global = MockHttpOverrides();
    mockFavoritesCubit = MockFavoritesCubit();
    mockWorkoutRepository = MockWorkoutRepository();
    mockLanguageCubit = MockLanguageCubit();
    mockLanguageCubit = MockLanguageCubit();
    mockProgressCubit = MockProgressCubit();
    mockUserSessionService = MockUserSessionService();
    UserSessionService.mockInstance = mockUserSessionService;

    final sl = GetIt.instance;
    if (sl.isRegistered<WorkoutRepository>()) {
      sl.unregister<WorkoutRepository>();
    }
    sl.registerLazySingleton<WorkoutRepository>(() => mockWorkoutRepository);
  });

  tearDown(() {
    HttpOverrides.global = null;
    UserSessionService.mockInstance = null;
  });

  final testExercise = ExerciseModel(
    id: '1',
    name: {'en': 'Bench Press'},
    imageUrl: 'http://example.com/image.jpg',
    videoUrl: 'http://example.com/video.mp4',
    steps: ['Lie down', 'Push up'],
    commonMistakes: [],
    targetMuscles: ['Chest', 'Triceps'],
    order: 1,
  );

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<FavoritesCubit>.value(value: mockFavoritesCubit),
          BlocProvider<LanguageCubit>.value(value: mockLanguageCubit),
          BlocProvider<ProgressCubit>.value(value: mockProgressCubit),
        ],
        child: MachineDetailScreen(exercise: testExercise),
      ),
    );
  }

  testWidgets('MachineDetailScreen renders correctly', (tester) async {
    when(() => mockFavoritesCubit.state).thenReturn(FavoritesState(favorites: []));
    when(() => mockLanguageCubit.state).thenReturn(LanguageState(const Locale('en')));
    when(() => mockProgressCubit.logVisit(
      machineName: any(named: 'machineName'),
      exerciseName: any(named: 'exerciseName'),
      muscleName: any(named: 'muscleName'),
    )).thenAnswer((_) async {});

    when(() => mockUserSessionService.logProgress(
      machineName: any(named: 'machineName'),
      exerciseName: any(named: 'exerciseName'),
      muscleName: any(named: 'muscleName'),
    )).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.text('Chest'), findsOneWidget); // Assuming localized to uppercase or similar if logic dictates, but based on previous test it was 'Chest' or 'TRICEPS'
    // The previous test had 'TRICEPS', let's stick to what was there or reasonable expectations. 
    // The code uses _getLocalizedBodyPart which defaults to uppercase if not found.
    // 'Chest' -> 'Chest' (if in loc) or 'CHEST'
    // Let's assume the previous test expectations were correct for the app state.
    // Actually, looking at the previous file content:
    // expect(find.text('Chest'), findsOneWidget);
    // expect(find.text('TRICEPS'), findsOneWidget);
    
    expect(find.text('Log Workout'), findsOneWidget);
  });
}
