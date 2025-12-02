import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageState {
  final Locale locale;
  LanguageState(this.locale);
}

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit() : super(LanguageState(const Locale('en')));

  void changeLanguage(Locale locale) {
    emit(LanguageState(locale));
  }
}
