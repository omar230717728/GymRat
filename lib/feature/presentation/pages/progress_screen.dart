import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/feature/cubit/progress_cubit.dart';
import 'package:flutter_application_1/feature/cubit/favorites_cubit.dart';
import 'package:flutter_application_1/feature/cubit/favorite_state.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Force dark theme for this screen to match "Nike-Style"
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF5722), // Vibrant Orange
          surface: Color(0xFF1E1E1E),
          surfaceContainerHighest: Color(0xFF2C2C2C),
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: SafeArea(
          child: BlocBuilder<ProgressCubit, ProgressState>(
            builder: (context, state) {
              if (state is ProgressLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProgressLoaded) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: 16.0, 
                    right: 16.0, 
                    top: 16.0, 
                    bottom: 100.0
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, state),
                      const SizedBox(height: 24),
                      _buildActivityOverview(context, state),
                      const SizedBox(height: 24),
                      _buildSectionTitle(context, 'RECENT VIEWS'),
                      const SizedBox(height: 12),
                      _buildRecentViews(context, state),
                      const SizedBox(height: 24),
                      _buildSectionTitle(context, 'FAVORITES'),
                      const SizedBox(height: 12),
                      _buildFavorites(context),
                    ],
                  ),
                );
              } else if (state is ProgressError) {
                return Center(child: Text('Error: ${state.message}'));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ProgressLoaded state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Streak & Session
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          
              
              const SizedBox(height: 20),
              _buildStatItem(
                context,
                iconPath: 'assets/images/fire.svg',
                value: '${state.streak}',
                label: 'Day streak',
                iconColor: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              _buildStatItem(
                context,
                iconPath: 'assets/images/clock.svg',
                value: state.avgSessionTime,
                label: 'Last session',
                iconColor: Colors.grey[400]!,
              ),
            ],
          ),
        ),
        // Right Widget: Heatmap Image
        Expanded(
          flex: 1,
          child: Center(
            child: SvgPicture.asset(
              'assets/images/heatmap_static.svg',
              height: 200,
              fit: BoxFit.contain,
              placeholderBuilder: (context) => Icon(
                Icons.accessibility_new,
                size: 150,
                color: Colors.grey[800],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, {
    required String iconPath,
    required String value,
    required String label,
    required Color iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              iconPath,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              width: 45,
              height: 28,
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityOverview(BuildContext context, ProgressLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 177, 177, 177), // Light grey contrast
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACTIVITY OVERVIEW',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildOverviewStat(context, '${state.uniqueExercisesCount}', 'Exercises\nlearned'),
                Container(width: 1, height: 70, color: Colors.black),
                _buildOverviewStat(context, '${state.uniqueMachinesCount}', 'Machines\nexplored'),
                Container(width: 1, height: 70, color: Colors.black),
                _buildOverviewStat(context, '${state.uniqueMusclesCount}', 'Muscles\nstudied'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.black,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.grey[500],
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildRecentViews(BuildContext context, ProgressLoaded state) {
    if (state.recentActivity.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'Start exploring to see history',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: state.recentActivity.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final activity = state.recentActivity[index];
          final name = activity['name'] ?? 'Unknown';
          final type = activity['type'] ?? 'Activity';
          
          return Container(
            width: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Center(
                      child: Icon(
                        type == 'Machine' ? Icons.fitness_center : Icons.directions_run,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        type,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavorites(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              child: _buildFavoriteCard(
                context,
                '${state.favorites.length}',
                'Total\nFavorites',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFavoriteCard(
                context,
                context.read<ProgressCubit>().state is ProgressLoaded 
                    ? (context.read<ProgressCubit>().state as ProgressLoaded).topMuscle ?? '-' 
                    : '-',
                'Primary\nFocus',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFavoriteCard(
                context,
                context.read<ProgressCubit>().state is ProgressLoaded 
                    ? (context.read<ProgressCubit>().state as ProgressLoaded).secondaryMuscle ?? '-' 
                    : '-',
                'Secondary\nFocus',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFavoriteCard(BuildContext context, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFD6D6D6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD32F2F), // Red accent
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
