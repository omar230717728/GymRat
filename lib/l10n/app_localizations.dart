import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('ru'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'GymRat'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logWorkout.
  ///
  /// In en, this message translates to:
  /// **'Log Workout'**
  String get logWorkout;

  /// No description provided for @sets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get sets;

  /// No description provided for @reps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get reps;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @weeklyStreak.
  ///
  /// In en, this message translates to:
  /// **'Weekly Streak'**
  String get weeklyStreak;

  /// No description provided for @totalWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Total Workouts'**
  String get totalWorkouts;

  /// No description provided for @recentProgress.
  ///
  /// In en, this message translates to:
  /// **'Recent Progress'**
  String get recentProgress;

  /// No description provided for @muscleDistribution.
  ///
  /// In en, this message translates to:
  /// **'Muscle Distribution'**
  String get muscleDistribution;

  /// No description provided for @volumeTrend.
  ///
  /// In en, this message translates to:
  /// **'Volume Trend'**
  String get volumeTrend;

  /// No description provided for @todaysSummary.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Summary'**
  String get todaysSummary;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @targetMuscles.
  ///
  /// In en, this message translates to:
  /// **'Target Muscles'**
  String get targetMuscles;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @beginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginner;

  /// No description provided for @intermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediate;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @equipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get equipment;

  /// No description provided for @variation.
  ///
  /// In en, this message translates to:
  /// **'Variation'**
  String get variation;

  /// No description provided for @relatedMachines.
  ///
  /// In en, this message translates to:
  /// **'Related Machines'**
  String get relatedMachines;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavorites;

  /// No description provided for @startWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get startWorkout;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @bodyParts.
  ///
  /// In en, this message translates to:
  /// **'Body Parts'**
  String get bodyParts;

  /// No description provided for @chest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get chest;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @legs.
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get legs;

  /// No description provided for @arms.
  ///
  /// In en, this message translates to:
  /// **'Arms'**
  String get arms;

  /// No description provided for @shoulders.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get shoulders;

  /// No description provided for @abs.
  ///
  /// In en, this message translates to:
  /// **'Abs'**
  String get abs;

  /// No description provided for @cardio.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get cardio;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @googleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get googleSignIn;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @verifyEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email before logging in.'**
  String get verifyEmailMessage;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @signupFailed.
  ///
  /// In en, this message translates to:
  /// **'Signup failed'**
  String get signupFailed;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created! Please check your email to verify.'**
  String get accountCreated;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent.'**
  String get passwordResetSent;

  /// No description provided for @failedToSendReset.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset email.'**
  String get failedToSendReset;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @validEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get validEmail;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @minCharacters.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get minCharacters;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get nameRequired;

  /// No description provided for @verificationNote.
  ///
  /// In en, this message translates to:
  /// **'A verification email will be sent to you.\nYou must verify before logging in.'**
  String get verificationNote;

  /// No description provided for @welcomeBackBeast.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, beast mode!'**
  String get welcomeBackBeast;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @filterByDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Filter by Difficulty'**
  String get filterByDifficulty;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search machines…'**
  String get searchHint;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @startAddingFavorites.
  ///
  /// In en, this message translates to:
  /// **'Start adding machines to your collection.'**
  String get startAddingFavorites;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'removed from favorites'**
  String get removedFromFavorites;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKg;

  /// No description provided for @workoutLogged.
  ///
  /// In en, this message translates to:
  /// **'Workout logged successfully!'**
  String get workoutLogged;

  /// No description provided for @videoMode.
  ///
  /// In en, this message translates to:
  /// **'Video Mode'**
  String get videoMode;

  /// No description provided for @workoutCategories.
  ///
  /// In en, this message translates to:
  /// **'Workout Categories'**
  String get workoutCategories;

  /// No description provided for @pleaseLoginProgress.
  ///
  /// In en, this message translates to:
  /// **'Please login to view progress'**
  String get pleaseLoginProgress;

  /// No description provided for @yourProgress.
  ///
  /// In en, this message translates to:
  /// **'YOUR PROGRESS'**
  String get yourProgress;

  /// No description provided for @noWorkoutsLogged.
  ///
  /// In en, this message translates to:
  /// **'No workouts logged yet.'**
  String get noWorkoutsLogged;

  /// No description provided for @weeklyActivity.
  ///
  /// In en, this message translates to:
  /// **'Weekly Activity'**
  String get weeklyActivity;

  /// No description provided for @recentHistory.
  ///
  /// In en, this message translates to:
  /// **'Recent History'**
  String get recentHistory;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @workouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get workouts;

  /// No description provided for @workoutVideo.
  ///
  /// In en, this message translates to:
  /// **'Workout Video'**
  String get workoutVideo;

  /// No description provided for @signInToSaveFavorites.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save favorites'**
  String get signInToSaveFavorites;

  /// No description provided for @createAccountToSave.
  ///
  /// In en, this message translates to:
  /// **'Create an account to save machines and track your progress.'**
  String get createAccountToSave;

  /// No description provided for @loginCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Login / Create Account'**
  String get loginCreateAccount;

  /// No description provided for @editTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit {title}'**
  String editTitle(String title);

  /// No description provided for @profilePictureUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated!'**
  String get profilePictureUpdated;

  /// No description provided for @errorUploadingImage.
  ///
  /// In en, this message translates to:
  /// **'Error uploading image: {error}'**
  String errorUploadingImage(String error);

  /// No description provided for @dataUploaded.
  ///
  /// In en, this message translates to:
  /// **'Data uploaded successfully!'**
  String get dataUploaded;

  /// No description provided for @seedData.
  ///
  /// In en, this message translates to:
  /// **'Seed Data (Dev Only)'**
  String get seedData;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get loginRequired;

  /// No description provided for @loginRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Please login to continue.'**
  String get loginRequiredMessage;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'Day Streak'**
  String get dayStreak;

  /// No description provided for @lastSession.
  ///
  /// In en, this message translates to:
  /// **'Last Session'**
  String get lastSession;

  /// No description provided for @activityOverview.
  ///
  /// In en, this message translates to:
  /// **'ACTIVITY OVERVIEW'**
  String get activityOverview;

  /// No description provided for @recentViews.
  ///
  /// In en, this message translates to:
  /// **'RECENT VIEWS'**
  String get recentViews;

  /// No description provided for @focusAnalysis.
  ///
  /// In en, this message translates to:
  /// **'FOCUS ANALYSIS'**
  String get focusAnalysis;

  /// No description provided for @exercisesLearned.
  ///
  /// In en, this message translates to:
  /// **'Exercises\nlearned'**
  String get exercisesLearned;

  /// No description provided for @machinesExplored.
  ///
  /// In en, this message translates to:
  /// **'Machines\nexplored'**
  String get machinesExplored;

  /// No description provided for @musclesStudied.
  ///
  /// In en, this message translates to:
  /// **'Muscles\nstudied'**
  String get musclesStudied;

  /// No description provided for @primaryFocus.
  ///
  /// In en, this message translates to:
  /// **'PRIMARY'**
  String get primaryFocus;

  /// No description provided for @secondaryFocus.
  ///
  /// In en, this message translates to:
  /// **'SECONDARY'**
  String get secondaryFocus;

  /// No description provided for @startTraining.
  ///
  /// In en, this message translates to:
  /// **'START TRAINING'**
  String get startTraining;

  /// No description provided for @keepGoing.
  ///
  /// In en, this message translates to:
  /// **'KEEP GOING'**
  String get keepGoing;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Track Your Progress'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'Keep history of all your workouts and see your improvements.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Crush Your Goals'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In en, this message translates to:
  /// **'Analyze your stats and focus on what matters.'**
  String get onboardingBody2;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @trainTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'What do you want\nto train today?'**
  String get trainTodayTitle;

  /// No description provided for @trainNow.
  ///
  /// In en, this message translates to:
  /// **'Train now'**
  String get trainNow;

  /// No description provided for @noBodyParts.
  ///
  /// In en, this message translates to:
  /// **'No body parts found'**
  String get noBodyParts;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @joined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get joined;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'de', 'en', 'ru', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
