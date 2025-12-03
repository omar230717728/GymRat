part of 'progress_cubit.dart';

abstract class ProgressState extends Equatable {
  const ProgressState();

  @override
  List<Object?> get props => [];
}

class ProgressInitial extends ProgressState {}

class ProgressLoading extends ProgressState {}

class ProgressLoaded extends ProgressState {
  final List<ActivityLog> logs;
  final int streak;
  final String avgSessionTime;
  final Map<String, int> muscleCounts;
  final int uniqueExercisesCount;
  final int uniqueMachinesCount;
  final int uniqueMusclesCount;
  final List<String> suggestions;
  final String? topMuscle;
  final String? secondaryMuscle;
  final List<Map<String, String>> recentActivity;

  const ProgressLoaded({
    required this.logs,
    required this.streak,
    required this.avgSessionTime,
    required this.muscleCounts,
    required this.uniqueExercisesCount,
    required this.uniqueMachinesCount,
    required this.uniqueMusclesCount,
    required this.suggestions,
    this.topMuscle,
    this.secondaryMuscle,
    this.recentActivity = const [],
  });

  @override
  List<Object?> get props => [
        logs,
        streak,
        avgSessionTime,
        muscleCounts,
        uniqueExercisesCount,
        uniqueMachinesCount,
        uniqueMusclesCount,
        suggestions,
        topMuscle,
        secondaryMuscle,
        recentActivity,
      ];
}

class ProgressError extends ProgressState {
  final String message;

  const ProgressError(this.message);

  @override
  List<Object?> get props => [message];
}
