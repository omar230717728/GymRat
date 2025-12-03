// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'GymRat';

  @override
  String get home => 'Главная';

  @override
  String get search => 'Поиск';

  @override
  String get favorites => 'Избранное';

  @override
  String get profile => 'Профиль';

  @override
  String get progress => 'Прогресс';

  @override
  String get settings => 'Настройки';

  @override
  String get logWorkout => 'Записать тренировку';

  @override
  String get sets => 'Подходы';

  @override
  String get reps => 'Повторения';

  @override
  String get weight => 'Вес';

  @override
  String get notes => 'Заметки';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get language => 'Язык';

  @override
  String get theme => 'Тема';

  @override
  String get logout => 'Выйти';

  @override
  String get welcomeBack => 'С возвращением';

  @override
  String get weeklyStreak => 'Недельная серия';

  @override
  String get totalWorkouts => 'Всего тренировок';

  @override
  String get recentProgress => 'Недавний прогресс';

  @override
  String get muscleDistribution => 'Распределение мышц';

  @override
  String get volumeTrend => 'Тенденция объема';

  @override
  String get todaysSummary => 'Сводка за сегодня';

  @override
  String get instructions => 'Инструкции';

  @override
  String get targetMuscles => 'Целевые мышцы';

  @override
  String get description => 'Описание';

  @override
  String get difficulty => 'Сложность';

  @override
  String get beginner => 'Новичок';

  @override
  String get intermediate => 'Средний';

  @override
  String get advanced => 'Продвинутый';

  @override
  String get equipment => 'Оборудование';

  @override
  String get variation => 'Вариация';

  @override
  String get relatedMachines => 'Похожие тренажеры';

  @override
  String get noFavorites => 'Пока нет избранного';

  @override
  String get startWorkout => 'Начать тренировку';

  @override
  String get history => 'История';

  @override
  String get bodyParts => 'Части тела';

  @override
  String get chest => 'Грудь';

  @override
  String get back => 'Спина';

  @override
  String get legs => 'Ноги';

  @override
  String get arms => 'Руки';

  @override
  String get shoulders => 'Плечи';

  @override
  String get abs => 'Пресс';

  @override
  String get cardio => 'Кардио';

  @override
  String get other => 'Другое';

  @override
  String get login => 'Login';

  @override
  String get signup => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get send => 'Send';

  @override
  String get googleSignIn => 'Continue with Google';

  @override
  String get fullName => 'Full Name';

  @override
  String get createAccount => 'Create Account';

  @override
  String get verifyEmailMessage =>
      'Please verify your email before logging in.';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get signupFailed => 'Signup failed';

  @override
  String get accountCreated =>
      'Account created! Please check your email to verify.';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get passwordResetSent => 'Password reset email sent.';

  @override
  String get failedToSendReset => 'Failed to send reset email.';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get validEmail => 'Enter a valid email';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get minCharacters => 'Minimum 6 characters';

  @override
  String get nameRequired => 'Full name is required';

  @override
  String get verificationNote =>
      'A verification email will be sent to you.\nYou must verify before logging in.';

  @override
  String get welcomeBackBeast => 'Welcome back, beast mode!';

  @override
  String get or => 'OR';

  @override
  String get filterByDifficulty => 'Filter by Difficulty';

  @override
  String get done => 'Done';

  @override
  String get searchHint => 'Search machines…';

  @override
  String get noResults => 'No results';

  @override
  String get startAddingFavorites =>
      'Start adding machines to your collection.';

  @override
  String get removedFromFavorites => 'removed from favorites';

  @override
  String get weightKg => 'Weight (kg)';

  @override
  String get workoutLogged => 'Workout logged successfully!';

  @override
  String get videoMode => 'Video Mode';

  @override
  String get workoutCategories => 'Workout Categories';

  @override
  String get pleaseLoginProgress => 'Please login to view progress';

  @override
  String get yourProgress => 'Your Progress';

  @override
  String get noWorkoutsLogged => 'No workouts logged yet.';

  @override
  String get weeklyActivity => 'Weekly Activity';

  @override
  String get recentHistory => 'Recent History';

  @override
  String get volume => 'Volume';

  @override
  String get workouts => 'Workouts';

  @override
  String get workoutVideo => 'Workout Video';

  @override
  String get signInToSaveFavorites => 'Sign in to save favorites';

  @override
  String get createAccountToSave =>
      'Create an account to save machines and track your progress.';

  @override
  String get loginCreateAccount => 'Login / Create Account';

  @override
  String editTitle(String title) {
    return 'Edit $title';
  }

  @override
  String get profilePictureUpdated => 'Profile picture updated!';

  @override
  String errorUploadingImage(String error) {
    return 'Error uploading image: $error';
  }

  @override
  String get dataUploaded => 'Data uploaded successfully!';

  @override
  String get seedData => 'Seed Data (Dev Only)';

  @override
  String get loginRequired => 'Login Required';

  @override
  String get loginRequiredMessage => 'Please login to continue.';
}
