import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/core/di/injection_container.dart';
import 'package:flutter_application_1/core/models/workout_entry.dart';
import 'package:flutter_application_1/feature/repositories/workout_repository.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/feature/cubit/language_cubit.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(child: Text(AppLocalizations.of(context)!.pleaseLoginProgress));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.yourProgress),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<List<WorkoutEntry>>(
        stream: sl<WorkoutRepository>().getWorkouts(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)!.noWorkoutsLogged));
          }

          final workouts = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                _buildSummaryCards(context, workouts),
                const SizedBox(height: 24),

                // Weekly Activity Chart
                Text(
                  AppLocalizations.of(context)!.weeklyActivity,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _buildWeeklyChart(context, workouts),
                ),
                const SizedBox(height: 24),

                // Recent History
                Text(
                  AppLocalizations.of(context)!.recentHistory,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                _buildHistoryList(context, workouts),
                
                const SizedBox(height: 80), // Bottom padding
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, List<WorkoutEntry> workouts) {
    final totalWorkouts = workouts.length;
    final totalSets = workouts.fold(0, (sum, item) => sum + item.sets);
    final totalVolume = workouts.fold(0.0, (sum, item) => sum + (item.sets * item.reps * item.weight));

    return Row(
      children: [
        Expanded(child: _statCard(context, AppLocalizations.of(context)!.workouts, "$totalWorkouts", Icons.fitness_center, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _statCard(context, AppLocalizations.of(context)!.sets, "$totalSets", Icons.repeat, Colors.orange)),
        const SizedBox(width: 12),
        Expanded(child: _statCard(context, AppLocalizations.of(context)!.volume, "${(totalVolume / 1000).toStringAsFixed(1)}k", Icons.scale, Colors.purple)),
      ],
    );
  }

  Widget _statCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, List<WorkoutEntry> workouts) {
    // Group by day of week
    final Map<int, int> dayCounts = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    for (var workout in workouts) {
      if (workout.timestamp.isAfter(startOfWeek)) {
        dayCounts[workout.timestamp.weekday - 1] = (dayCounts[workout.timestamp.weekday - 1] ?? 0) + 1;
      }
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (dayCounts.values.reduce((a, b) => a > b ? a : b) + 2).toDouble(),
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                );
                Widget text;
                switch (value.toInt()) {
                  case 0: text = const Text('M', style: style); break;
                  case 1: text = const Text('T', style: style); break;
                  case 2: text = const Text('W', style: style); break;
                  case 3: text = const Text('T', style: style); break;
                  case 4: text = const Text('F', style: style); break;
                  case 5: text = const Text('S', style: style); break;
                  case 6: text = const Text('S', style: style); break;
                  default: text = const Text('', style: style);
                }
                return SideTitleWidget(axisSide: meta.axisSide, child: text);
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: dayCounts.entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.toDouble(),
                color: Theme.of(context).colorScheme.primary,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, List<WorkoutEntry> workouts) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: workouts.length > 5 ? 5 : workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(Icons.fitness_center, color: Theme.of(context).colorScheme.primary),
            ),
            title: Text(workout.machineName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${workout.sets} sets x ${workout.reps} reps @ ${workout.weight}kg"),
            trailing: Text(
              DateFormat('MMM d', context.read<LanguageCubit>().state.locale.languageCode).format(workout.timestamp),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}
