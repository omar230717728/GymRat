import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/models/user_model.dart';
import 'package:flutter_application_1/core/services/user_session_service.dart';
import 'package:flutter_application_1/core/repositories/gym_repository.dart';
import 'package:flutter_application_1/feature/presentation/pages/details_screen/machine_detail.dart'; // Checked singular 'detail'
import 'package:flutter_application_1/feature/presentation/widgets/exercise_card.dart';
import 'package:flutter_application_1/core/di/injection_container.dart' as di;
import 'package:flutter_svg/flutter_svg.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  @override
  void initState() {
    super.initState();
    UserSessionService.instance.refreshUser();
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

    return Scaffold(
      backgroundColor: bgBlack,
      appBar: AppBar(
        backgroundColor: bgBlack,
        title: const Text(
          'YOUR PROGRESS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            fontSize: 20,
          ),
        ),
        centerTitle: false, // Modern left-align or keep center if you prefer
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {}, // Placeholder for settings
          ),
        ],
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
              top: 16,
              bottom: 130,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. HERO SECTION (Streak & Heatmap) ---
                SizedBox(
                  height: 160, // Fixed height for alignment
                  child: Row(
                    children: [
                      // Left Column: Streak & Session
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            Expanded(
                              child: _buildHeroCard(
                                icon: Icons.local_fire_department_rounded,
                                iconColor: accentOrange,
                                value: '${user.currentStreak}',
                                label: 'Day Streak',
                              ),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: _buildHeroCard(
                                icon: Icons.timer_outlined,
                                iconColor: Colors.blueAccent,
                                value: '${user.lastSessionDuration}m',
                                label: 'Last Session',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Right Column: Heatmap
                      Expanded(
                        flex: 6,
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardDark,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Text(
                                  'BODY\nHEATMAP',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
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
                                    color: Colors.white.withOpacity(0.1),
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

                const SizedBox(height: 32),

                // --- 2. ACTIVITY OVERVIEW (Sleek Dark Panel) ---
                _buildSectionHeader('ACTIVITY OVERVIEW'),
                const SizedBox(height: 16),
                _buildPremiumActivityBox(user),

                const SizedBox(height: 32),

                // --- 3. RECENT VIEWS ---
                if (user.recentActivity.isNotEmpty) ...[
                  _buildSectionHeader('RECENT VIEWS'),
                  const SizedBox(height: 16),
                  _buildRecentViewsList(user),
                  const SizedBox(height: 32),
                ],

                // --- 4. FAVORITES ---
                _buildSectionHeader('FAVORITES'),
                const SizedBox(height: 16),
                _buildFavoritesSection(user),

                const SizedBox(height: 32),

                // --- 5. FOCUS ANALYSIS (Logic Protected) ---
                _buildSectionHeader('FOCUS ANALYSIS'),
                const SizedBox(height: 16),
                _buildSmartFocusRow(user),

                const SizedBox(height: 40),
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
        color: Colors.white.withOpacity(0.6),
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
  }

  // A sleek card for Streak/Timer
  Widget _buildHeroCard({
    required IconData icon,
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
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
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('$exercisesLearned', 'Exercises'),
          Container(
            width: 1,
            height: 40,
            color: Colors.white10,
          ), // Subtle Divider
          _buildStatItem('${user.exploredMachinesCount}', 'Machines'),
          Container(
            width: 1,
            height: 40,
            color: Colors.white10,
          ), // Subtle Divider
          _buildStatItem('${user.studiedMusclesCount}', 'Muscles'),
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
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
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
            onTap: () => _navigateToDetails(context, activity['id']),
          );
        },
      ),
    );
  }

  Widget _buildFavoritesSection(UserModel user) {
    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: user.favoriteIds.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            // "View All" / Total Card
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                width: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.redAccent.withOpacity(0.8),
                      Colors.orangeAccent.withOpacity(0.8),
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
                      const Text(
                        'FAVORITES',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final machineId = user.favoriteIds[index - 1];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FutureBuilder(
              future: di.sl<GymRepository>().fetchMachine(machineId),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  final machine = snapshot.data!;
                  // Inside _buildFavoritesSection -> FutureBuilder:

                  if (snapshot.hasData && snapshot.data != null) {
                    final machine = snapshot.data!;
                    return ExerciseCard(
                      title: machine.name,
                      subtitle: machine.primaryMuscles.isNotEmpty
                          ? machine.primaryMuscles.first
                          : "Machine",
                      imageUrl: machine
                          .image, // <--- ADD THIS LINE (Assuming your model has .image)
                      onTap: () => _navigateToDetails(context, machine.id),
                    );
                  }
                }
                // Sleek loading placeholder
                return Container(
                  width: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  //     RESTORED LOGIC (DO NOT DELETE)
  // ==========================================

  Widget _buildSmartFocusRow(UserModel user) {
    final stats = user.stats;
    final Map<String, int> mergedScores = {};

    // 1. Process Normal Map
    if (stats['muscle_scores'] is Map) {
      (stats['muscle_scores'] as Map).forEach((k, v) {
        mergedScores[k.toString().toUpperCase()] = _toInt(v);
      });
    }

    // 2. Process "Dot Bug" Fields
    stats.forEach((key, value) {
      if (key.startsWith('muscle_scores.')) {
        final parts = key.split('.');
        if (parts.length > 1) {
          final muscleName = parts[1].trim().toUpperCase();
          mergedScores[muscleName] =
              (mergedScores[muscleName] ?? 0) + _toInt(value);
        }
      }
    });

    String primary = 'START TRAINING';
    String secondary = 'KEEP GOING';

    if (mergedScores.isNotEmpty) {
      final sortedEntries = mergedScores.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      if (sortedEntries.isNotEmpty) primary = sortedEntries[0].key;
      if (sortedEntries.length > 1) secondary = sortedEntries[1].key;
    }

    return Row(
      children: [
        Expanded(
          child: _buildGradientFocusBox('PRIMARY', primary, [
            const Color(0xFFFF5722),
            const Color(0xFFFF8A65),
          ]),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildGradientFocusBox('SECONDARY', secondary, [
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
          colors: colors.map((c) => c.withOpacity(0.2)).toList(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.first.withOpacity(0.3)),
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
  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
