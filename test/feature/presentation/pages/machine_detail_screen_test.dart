import 'dart:io';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/utils/machine.dart';
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

void main() {
  late MockFavoritesCubit mockFavoritesCubit;
  late MockWorkoutRepository mockWorkoutRepository;
  late MockLanguageCubit mockLanguageCubit;

  setUp(() {
    HttpOverrides.global = MockHttpOverrides();
    mockFavoritesCubit = MockFavoritesCubit();
    mockWorkoutRepository = MockWorkoutRepository();
    mockLanguageCubit = MockLanguageCubit();

    final sl = GetIt.instance;
    if (sl.isRegistered<WorkoutRepository>()) {
      sl.unregister<WorkoutRepository>();
    }
    sl.registerLazySingleton<WorkoutRepository>(() => mockWorkoutRepository);
  });

  tearDown(() {
    HttpOverrides.global = null;
  });

  final testMachine = Machine(
    id: '1',
    name: {'en': 'Bench Press'},
    description: {'en': 'Chest exercise'},
    imageUrl: 'http://example.com/image.jpg',
    videoUrl: 'http://example.com/video.mp4',
    targetMuscles: {'en': ['Chest', 'Triceps']},
    instructions: {'en': ['Lie down', 'Push up']},
    difficulty: 'intermediate',
    bodyPart: 'chest',
  );

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<FavoritesCubit>.value(value: mockFavoritesCubit),
          BlocProvider<LanguageCubit>.value(value: mockLanguageCubit),
        ],
        child: MachineDetailScreen(machine: testMachine),
      ),
    );
  }

  testWidgets('MachineDetailScreen renders correctly', (tester) async {
    when(() => mockFavoritesCubit.state).thenReturn(const FavoritesState(favorites: []));
    when(() => mockLanguageCubit.state).thenReturn(LanguageState(const Locale('en')));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.text('Chest exercise'), findsOneWidget);
    expect(find.text('Intermediate'), findsOneWidget);
    expect(find.text('Chest'), findsOneWidget);
    expect(find.text('TRICEPS'), findsOneWidget);
    expect(find.text('Log Workout'), findsOneWidget);
  });
}
