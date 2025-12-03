// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'GymRat';

  @override
  String get home => 'الرئيسية';

  @override
  String get search => 'بحث';

  @override
  String get favorites => 'المفضلة';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get progress => 'التقدم';

  @override
  String get settings => 'الإعدادات';

  @override
  String get logWorkout => 'سجل التمرين';

  @override
  String get sets => 'مجموعات';

  @override
  String get reps => 'تكرار';

  @override
  String get weight => 'وزن';

  @override
  String get notes => 'ملاحظات';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get language => 'اللغة';

  @override
  String get theme => 'السمة';

  @override
  String get logout => 'تسجيل خروج';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get weeklyStreak => 'سلسلة أسبوعية';

  @override
  String get totalWorkouts => 'إجمالي التمارين';

  @override
  String get recentProgress => 'التقدم الأخير';

  @override
  String get muscleDistribution => 'توزيع العضلات';

  @override
  String get volumeTrend => 'اتجاه الحجم';

  @override
  String get todaysSummary => 'ملخص اليوم';

  @override
  String get instructions => 'تعليمات';

  @override
  String get targetMuscles => 'العضلات المستهدفة';

  @override
  String get description => 'الوصف';

  @override
  String get difficulty => 'صعوبة';

  @override
  String get beginner => 'مبتدئ';

  @override
  String get intermediate => 'متوسط';

  @override
  String get advanced => 'متقدم';

  @override
  String get equipment => 'معدات';

  @override
  String get variation => 'تغيير';

  @override
  String get relatedMachines => 'آلات ذات صلة';

  @override
  String get noFavorites => 'لا توجد مفضلات بعد';

  @override
  String get startWorkout => 'ابدأ التمرين';

  @override
  String get history => 'تاريخ';

  @override
  String get bodyParts => 'أجزاء الجسم';

  @override
  String get chest => 'صدر';

  @override
  String get back => 'ظهر';

  @override
  String get legs => 'أرجل';

  @override
  String get arms => 'أذرع';

  @override
  String get shoulders => 'أكتاف';

  @override
  String get abs => 'بطن';

  @override
  String get cardio => 'كارديو';

  @override
  String get other => 'أخرى';

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
