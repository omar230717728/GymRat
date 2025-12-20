import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/models/user_model.dart';
import 'package:flutter_application_1/core/models/machine_model.dart'; // <--- IMPORT
import 'package:flutter_application_1/core/services/user_session_service.dart';
import 'package:flutter_application_1/core/repositories/gym_repository.dart';
import 'package:flutter_application_1/feature/presentation/pages/details_screen/machine_detail.dart'; // Checked singular 'detail'
import 'package:flutter_application_1/feature/presentation/widgets/exercise_card.dart';
import 'package:flutter_application_1/core/di/injection_container.dart' as di;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_application_1/feature/presentation/widgets/keep_alive_wrapper.dart'; // <--- IMPORT

import 'package:lottie/lottie.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart'; // <--- IMPORT

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    // 1. Refresh Data
    await UserSessionService.instance.refreshUser();

    // 2. Artificial Delay to smooth transition (mask rendering lag)
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToDetails(BuildContext context, String? machineId) {
    if (machineId != null && machineId.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MachineDetailScreen(machineId: machineId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Theme Colors
    const Color bgBlack = Colors.black;
    const Color cardDark = Color(0xFF1C1C1E); // Lighter black for cards
    const Color accentOrange = Color(0xFFFF5722);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Lottie.asset(
            'assets/lottie/welcome_loading.json',
            width: 150,
            height: 150,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgBlack,
      appBar: AppBar(
        backgroundColor: bgBlack,
        title: Text(
          AppLocalizations.of(context)!.yourProgress,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            fontSize: 20,
          ),
        ),
        centerTitle: false, // Modern left-align or keep center if you prefer
        elevation: 0,

      ),
      body: StreamBuilder<UserModel?>(
        stream: UserSessionService.instance.userStream,
        initialData: UserSessionService.instance.currentUser,
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(color: accentOrange),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(), // Premium scroll feel
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 9,
              bottom: 130,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. HERO SECTION (Streak & Heatmap) ---
                SizedBox(
                  height: 140, // Fixed height for alignment
                  child: Row(
                    children: [
                      // Left Column: Streak & Session
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            Expanded(
                              child: _buildHeroCard(
                                lottieAsset: 'assets/lottie/Fire.json',
                                iconColor: accentOrange,
                                value: '${user.currentStreak}',
                                label: AppLocalizations.of(context)!.dayStreak,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: _buildHeroCard(
                                lottieAsset: 'assets/lottie/clock time.json',
                                iconColor: Colors.blueAccent,
                                value: '${user.lastSessionDuration}m',
                                label: AppLocalizations.of(context)!.lastSession,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 11),
                      // Right Column: Heatmap
                      Expanded(
                        flex: 6,
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardDark,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal:12, vertical: 8),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Text(
                                  'BODY\nHEATMAP',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Center(
                                child: SvgPicture.asset(
                                  'assets/images/heatmap_static.svg',
                                  fit: BoxFit.contain,
                                  height: 120,
                                  placeholderBuilder: (_) => Icon(
                                    Icons.accessibility_new_rounded,
                                    color: Colors.white.withValues(alpha: 0.1),
                                    size: 60,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),
                // --- 2. ACTIVITY OVERVIEW (Sleek Dark Panel) ---
                _buildSectionHeader(AppLocalizations.of(context)!.activityOverview),
                const SizedBox(height: 13),
                _buildPremiumActivityBox(user),
                const SizedBox(height: 20),

                // --- 3. RECENT VIEWS ---
                if (user.recentActivity.isNotEmpty) ...[
                  _buildSectionHeader(AppLocalizations.of(context)!.recentViews),
                  const SizedBox(height: 14),
                  _buildRecentViewsList(user),
                  const SizedBox(height: 20),
                ],

                // --- 4. FAVORITES ---
                _buildSectionHeader(AppLocalizations.of(context)!.favorites.toUpperCase()),
                const SizedBox(height: 14),
                _buildFavoritesSection(user),

                const SizedBox(height: 20),

                // --- 5. FOCUS ANALYSIS (Logic Protected) ---
                _buildSectionHeader(AppLocalizations.of(context)!.focusAnalysis),
                const SizedBox(height: 14),
                _buildSmartFocusRow(user),      
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  //            MODERN UI WIDGETS
  // ==========================================

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.6),
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
  }

  // A sleek card for Streak/Timer
  Widget _buildHeroCard({
    required String lottieAsset,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Lottie.asset(
              lottieAsset,
              width: 30,
              height: 30,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // The "Dark Panel" for Activity stats
  Widget _buildPremiumActivityBox(UserModel user) {
    // Safer check for exercises
    final exercisesLearned = (user.stats['exercises_learned'] is List)
        ? (user.stats['exercises_learned'] as List).length
        : 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('$exercisesLearned', AppLocalizations.of(context)!.exercisesLearned),
          Container(
            width: 1,
            height: 40,
            color: Colors.white10,
          ), // Subtle Divider
          _buildStatItem('${user.exploredMachinesCount}', AppLocalizations.of(context)!.machinesExplored),
          Container(
            width: 1,
            height: 40,
            color: Colors.white10,
          ), // Subtle Divider
          _buildStatItem('${user.studiedMusclesCount}', AppLocalizations.of(context)!.musclesStudied),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color.fromARGB(255, 254, 252, 252),
            fontSize: 35,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentViewsList(UserModel user) {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: user.recentActivity.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final activity = user.recentActivity[index];
          return ExerciseCard(
            title: activity['name'] ?? 'Unknown',
            subtitle: activity['type'] ?? 'Activity',
            imageUrl: activity['image'],
            onTap: () => _navigateToDetails(context, activity['id']),
          );
        },
      ),
    );
  }

  Widget _buildFavoritesSection(UserModel user) {
    return FutureBuilder<List<MachineModel>>(
      future: di.sl<GymRepository>().getMachinesByIds(
        List<String>.from(user.favoriteIds),
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SizedBox(
            height: 190,
            child: Center(
              child: Text(
                'DB Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          // Loading Shimmer State (Horizontal List of 3 items)
          return SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (_, index) {
                if (index == 0) return _buildTotalFavoritesCard(user);
                return _buildShimmerCard();
              },
            ),
          );
        }

        final machines = snapshot.data!;

        return SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: machines.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildTotalFavoritesCard(user),
                );
              }

              final machine = machines[index - 1];
              return KeepAliveWrapper(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: ExerciseCard(
                    title: machine.name,
                    subtitle: machine.primaryMuscles.isNotEmpty
                        ? machine.primaryMuscles.first
                        : "Machine",
                    imageUrl: machine.image,
                    onTap: () => _navigateToDetails(context, machine.id),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTotalFavoritesCard(UserModel user) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.redAccent.withValues(alpha: 0.8),
            Colors.orangeAccent.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Favorites Page")),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${user.favoritesCount}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.favorites.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white10),
      ),
    );
  }

  // ==========================================
  //     RESTORED LOGIC (DO NOT DELETE)
  // ==========================================

  Widget _buildSmartFocusRow(UserModel user) {
    final mergedScores = user.calculatedMuscleScores;

    String primary = AppLocalizations.of(context)!.startTraining;
    String secondary = AppLocalizations.of(context)!.keepGoing;

    if (mergedScores.isNotEmpty) {
      final sortedEntries = mergedScores.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      if (sortedEntries.isNotEmpty) primary = sortedEntries[0].key;
      if (sortedEntries.length > 1) secondary = sortedEntries[1].key;
    }

    return Row(
      children: [
        Expanded(
          child: _buildGradientFocusBox(AppLocalizations.of(context)!.primaryFocus, primary, [
            const Color(0xFFFF5722),
            const Color(0xFFFF8A65),
          ]),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildGradientFocusBox(AppLocalizations.of(context)!.secondaryFocus, secondary, [
            Colors.blueAccent,
            Colors.lightBlueAccent,
          ]),
        ),
      ],
    );
  }

  Widget _buildGradientFocusBox(
    String label,
    String value,
    List<Color> colors,
  ) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors.map((c) => c.withValues(alpha: 0.2)).toList(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.first.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colors.first,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // --- HELPERS ---

}
