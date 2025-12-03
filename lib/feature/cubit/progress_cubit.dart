import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_application_1/core/models/activity_log.dart';
import 'package:flutter_application_1/core/repositories/activity_repository.dart';
import 'package:flutter_application_1/core/services/user_session_service.dart';
import 'package:flutter_application_1/core/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'progress_state.dart';

class ProgressCubit extends Cubit<ProgressState> {
  final ActivityRepository _activityRepository;
  DateTime? _sessionStartTime;

  ProgressCubit({
    required ActivityRepository activityRepository,
  })  : _activityRepository = activityRepository,
        super(ProgressInitial()) {
    // Listen to User Session
    UserSessionService.instance.currentUser.addListener(_onUserChanged);
    // Initial load
    _onUserChanged();
  }

  void _onUserChanged() {
    final user = UserSessionService.instance.currentUser.value;
    if (user != null) {
      _emitLoadedState(user);
    } else {
      emit(ProgressInitial());
    }
  }

  Future<void> _emitLoadedState(UserModel user) async {
    try {
      // 1. Update Daily Streak
      // Now handled by UserSessionService
      final streak = user.currentStreak;
      
      // 2. Calculate Session Time
      // Now handled by UserSessionService
      final lastSessionMinutes = user.lastSessionDuration;
      String lastSessionDisplay = "0m";
      
      if (lastSessionMinutes > 60) {
        lastSessionDisplay = "${lastSessionMinutes ~/ 60}h ${lastSessionMinutes % 60}m";
      } else {
        lastSessionDisplay = "${lastSessionMinutes}m";
      }

      // 3. Process Stats from User Model
      final stats = user.stats;
      
      // Muscle Scores
      final muscleScores = Map<String, int>.from(stats['muscle_scores'] ?? {});
      
      // Sort for suggestions/top muscles
      final sortedMuscles = muscleScores.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      final suggestions = sortedMuscles.take(3).map((e) => e.key).toList();
      if (suggestions.isEmpty) {
        suggestions.addAll(['Chest', 'Back', 'Legs']);
      }

      String? topMuscle;
      String? secondaryMuscle;

      if (sortedMuscles.isNotEmpty) {
        topMuscle = sortedMuscles.first.key;
        if (sortedMuscles.length > 1) {
          secondaryMuscle = sortedMuscles[1].key;
        }
      }

      // Counts
      final machinesExplored = (stats['explored_machine_names'] as List?)?.length ?? 0;
      final exercisesLearned = (stats['learned_exercise_names'] as List?)?.length ?? 0;
      final musclesStudied = muscleScores.length;

      // Legacy Logs (Optional: Fetch if we want to show recent activity list)
      // The UI shows "Recent Activity". We still need logs for that.
      final logs = await _activityRepository.fetchActivityLogs();

      emit(ProgressLoaded(
        logs: logs,
        streak: streak,
        avgSessionTime: lastSessionDisplay,
        muscleCounts: muscleScores,
        uniqueExercisesCount: exercisesLearned,
        uniqueMachinesCount: machinesExplored,
        uniqueMusclesCount: musclesStudied,
        suggestions: suggestions,
        topMuscle: topMuscle,
        secondaryMuscle: secondaryMuscle,
        recentActivity: user.recentActivity,
      ));
    } catch (e) {
      print("Error loading progress state: $e");
    }
  }

  // Wrapper for legacy calls, but UI should prefer Service directly
  Future<void> logVisit({
    String? machineName,
    String? exerciseName,
    String? muscleName,
    String? bodyPart,
  }) async {
    // Log to Service (Optimistic + Sync)
    await UserSessionService.instance.logProgress(
      machineName: machineName,
      exerciseName: exerciseName,
      muscleName: muscleName,
    );

    // Log legacy activity for "Recent Activity" list and Streak
    if (machineName != null || exerciseName != null || bodyPart != null) {
      await _activityRepository.logActivity(
        bodyPart: bodyPart,
        muscle: muscleName,
        machine: machineName,
        exercise: exerciseName,
      );
    }
    
    // State update is handled by listener
  }

  Future<void> updateSessionTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_session_start', DateTime.now().toIso8601String());
  }

  void startSession() {
    _sessionStartTime = DateTime.now();
    updateSessionTime();
  }

  Future<void> stopSession() async {
    if (_sessionStartTime == null) return;
    final duration = DateTime.now().difference(_sessionStartTime!);
    _sessionStartTime = null;

    final prefs = await SharedPreferences.getInstance();
    final sessions = prefs.getStringList('session_durations') ?? [];
    sessions.add(duration.inSeconds.toString());
    await prefs.setStringList('session_durations', sessions);
  }

  Future<String> _calculateAvgSessionTime() async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = prefs.getStringList('session_durations') ?? [];
    if (sessions.isEmpty) return "0m";

    final totalSeconds = sessions.fold(0, (sum, item) => sum + int.parse(item));
    final avgSeconds = totalSeconds ~/ sessions.length;

    final minutes = avgSeconds ~/ 60;
    final seconds = avgSeconds % 60;
    return "${minutes}m ${seconds}s";
  }
  
  @override
  Future<void> close() {
    UserSessionService.instance.currentUser.removeListener(_onUserChanged);
    return super.close();
  }
}
