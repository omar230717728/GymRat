import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/themes/app_theme.dart';
import 'package:flutter_application_1/feature/cubit/favorites_cubit.dart';
import 'package:flutter_application_1/feature/cubit/theme_cubit.dart';
import 'package:flutter_application_1/feature/presentation/pages/main_page.dart';
import 'package:flutter_application_1/feature/presentation/pages/profile_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => FavoritesCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'GymRat',
            theme: ThemeManager.getTheme(state.currentTheme),
            home: ProfileScreen(),
            
          );
        },
      ),
    );
  }
}