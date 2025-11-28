
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/core/themes/app_theme.dart';

/// State: holds current AppTheme
class ThemeState {
  final AppTheme currentTheme;
  ThemeState(this.currentTheme);
}

/// Cubit: manages switching themes
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(AppTheme.green)); // default

  void changeTheme(AppTheme theme) {
    emit(ThemeState(theme));
  }
}
