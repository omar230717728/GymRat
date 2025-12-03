import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/themes/app_theme.dart';
import 'package:flutter_application_1/feature/cubit/favorites_cubit.dart';
import 'package:flutter_application_1/feature/cubit/theme_cubit.dart';
import 'package:flutter_application_1/feature/presentation/pages/main_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'core/di/injection_container.dart' as di;
import 'package:flutter_application_1/feature/cubit/language_cubit.dart';
import 'package:flutter_application_1/feature/cubit/body_parts_cubit.dart';
import 'package:flutter_application_1/feature/cubit/muscle_list_cubit.dart';
import 'package:flutter_application_1/feature/cubit/machine_list_cubit.dart';
import 'package:flutter_application_1/feature/cubit/exercise_list_cubit.dart';
import 'package:flutter_application_1/core/repositories/gym_repository.dart';
import 'package:flutter_application_1/feature/cubit/progress_cubit.dart';
import 'package:flutter_application_1/core/repositories/activity_repository.dart';
import 'package:flutter_application_1/feature/repositories/progress_repository.dart';
import 'package:flutter_application_1/core/services/user_session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await di.init();
  await UserSessionService.instance.init();
  
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory((await getApplicationDocumentsDirectory()).path),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => FavoritesCubit()),
        BlocProvider(create: (_) => LanguageCubit()),
        BlocProvider(create: (_) => BodyPartsCubit(gymRepository: di.sl<GymRepository>())),
        BlocProvider(create: (_) => MuscleListCubit(gymRepository: di.sl<GymRepository>())),
        BlocProvider(create: (_) => MachineListCubit(gymRepository: di.sl<GymRepository>())),
        BlocProvider(create: (_) => ExerciseListCubit(gymRepository: di.sl<GymRepository>())),
        BlocProvider(create: (_) => ProgressCubit(activityRepository: di.sl<ActivityRepository>())..startSession()), // Auto-start session? Or just init. loadProgress is gone/internal.
        // Actually, the new ProgressCubit calls _onUserChanged in constructor, so it loads automatically.
        // But we might want to trigger startSession or similar.
        // The previous code had `..loadProgress()`.
        // Let's just create it.
        BlocProvider(create: (_) => ProgressCubit(activityRepository: di.sl<ActivityRepository>())),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LanguageCubit, LanguageState>(
            builder: (context, languageState) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'GymRat',
                theme: ThemeManager.getTheme(themeState.currentTheme),
                locale: languageState.locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en'), // English
                  Locale('tr'), // Turkish
                  Locale('de'), // German
                  Locale('ar'), // Arabic
                  Locale('ru'), // Russian
                ],
                home: const MyHomePage(),
              );
            },
          );
        },
      ),
    );
  }
}