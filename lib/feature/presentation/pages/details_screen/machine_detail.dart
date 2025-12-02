import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/services/favorites_service.dart';
import 'package:flutter_application_1/core/utils/helper_functions.dart';

import 'package:flutter_application_1/core/utils/machine.dart';
import 'package:flutter_application_1/core/auth/login_required_popup.dart';
import 'package:flutter_application_1/core/auth/login_screen.dart';
import 'package:flutter_application_1/feature/cubit/favorite_state.dart';
import 'package:flutter_application_1/feature/cubit/favorites_cubit.dart';
import 'package:flutter_application_1/feature/cubit/language_cubit.dart';
import 'package:flutter_application_1/feature/presentation/pages/details_screen/youtube_video_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/core/di/injection_container.dart';
import 'package:flutter_application_1/feature/repositories/workout_repository.dart';
import 'package:flutter_application_1/core/models/workout_entry.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';

class MachineDetailScreen extends StatefulWidget {
  final Machine machine;

  const MachineDetailScreen({super.key, required this.machine});

  @override
  State<MachineDetailScreen> createState() => _MachineDetailScreenState();
}

class _MachineDetailScreenState extends State<MachineDetailScreen>
    with WidgetsBindingObserver {
  bool isLandscape = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // Restore after leaving the screen
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final orientation = MediaQuery.of(context).orientation;
    setState(() {
      isLandscape = orientation == Orientation.landscape;
    });

    if (isLandscape) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _toggleFavorite(BuildContext context) {
    context.read<FavoritesCubit>().toggleFavorite(widget.machine);
  }

  void _openVideo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => YouTubeVideoScreen(videoUrl: widget.machine.videoUrl),
      ),
    );
  }

  Future<void> _showLogWorkoutDialog(BuildContext context) async {
    if (!isUserLoggedIn()) {
      showDialog(
        context: context,
        builder: (_) => LoginRequiredPopup(
          onConfirm: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          onCancel: () => Navigator.pop(context),
        ),
      );
      return;
    }

    final setsController = TextEditingController();
    final repsController = TextEditingController();
    final weightController = TextEditingController();
    final notesController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.logWorkout),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: setsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.sets),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: repsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.reps),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.weightKg),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.notes),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final sets = int.tryParse(setsController.text) ?? 0;
                final reps = int.tryParse(repsController.text) ?? 0;
                final weight = double.tryParse(weightController.text) ?? 0.0;
                final notes = notesController.text;

                if (sets > 0 && reps > 0) {
                  final entry = WorkoutEntry(
                    id: const Uuid().v4(),
                    machineId: widget.machine.id,
                    machineName: widget.machine.getName('en'),
                    sets: sets,
                    reps: reps,
                    weight: weight,
                    notes: notes,
                    timestamp: DateTime.now(),
                  );

                  final userId = FirebaseAuth.instance.currentUser!.uid;
                  await sl<WorkoutRepository>().logWorkout(userId, entry);

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.workoutLogged)),
                    );
                  }
                }
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        final isFavorite = state.favorites.any(
          (m) => m.id == widget.machine.id,
        );

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: isLandscape
              ? _buildLandscapeVideo()
              : _buildPortraitView(context, isFavorite),
        );
      },
    );
  }

  // ---------------- PORTRAIT MODE ----------------
  Widget _buildPortraitView(BuildContext context, bool isFavorite) {
    return Column(
      children: [
        // Top video banner
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: _openVideo,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                image: DecorationImage(
                  image: NetworkImage(widget.machine.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 70,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Content
        Expanded(flex: 3, child: _buildContent(context, isFavorite)),
      ],
    );
  }

  // ---------------- LANDSCAPE MODE ----------------
  Widget _buildLandscapeVideo() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Text(
          AppLocalizations.of(context)!.videoMode,
          style: const TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
    );
  }

  // ---------------- CONTENT ----------------
  Widget _buildContent(BuildContext context, bool isFavorite) {
    final locale = context.watch<LanguageCubit>().state.locale.languageCode;
    final name = widget.machine.getName(locale);
    final description = widget.machine.getDescription(locale);
    final instructions = widget.machine.getInstructions(locale);
    final targetMuscles = widget.machine.getTargetMuscles(locale);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Favorite button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                  size: 32,
                ),
                onPressed: () async {
                  if (!isUserLoggedIn()) {
                    showDialog(
                      context: context,
                      barrierColor: Colors.transparent,
                      builder: (_) => LoginRequiredPopup(
                        onConfirm: () async {
                          Navigator.pop(context);
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                          if (result == true) {
                            context.read<FavoritesCubit>().toggleFavorite(
                              widget.machine,
                            );
                          }
                        },
                        onCancel: () => Navigator.pop(context),
                      ),
                    );
                    return;
                  }

                  // No setState here – Cubit handles it
                  context.read<FavoritesCubit>().toggleFavorite(widget.machine);
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Tags Row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTag(
                context,
                _getLocalizedDifficulty(context, widget.machine.difficulty),
                _getDifficultyColor(widget.machine.difficulty),
              ),
              ...targetMuscles.map(
                (m) => _buildTag(context, _getLocalizedBodyPart(context, m), Theme.of(context).colorScheme.secondary),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const SizedBox(height: 16),

          // Log Workout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showLogWorkoutDialog(context),
              icon: const Icon(Icons.edit_note),
              label: Text(AppLocalizations.of(context)!.logWorkout),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            AppLocalizations.of(context)!.description,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),

          const SizedBox(height: 24),

          // Instructions
          Text(
            AppLocalizations.of(context)!.instructions,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: instructions.map((step) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        step,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 70),
        ],
      ),
    );
  }
  Widget _buildTag(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
  String _getLocalizedDifficulty(BuildContext context, String key) {
    final loc = AppLocalizations.of(context)!;
    switch (key.toLowerCase()) {
      case 'beginner': return loc.beginner;
      case 'intermediate': return loc.intermediate;
      case 'advanced': return loc.advanced;
      default: return key.toUpperCase();
    }
  }

  String _getLocalizedBodyPart(BuildContext context, String key) {
    final loc = AppLocalizations.of(context)!;
    switch (key.toLowerCase()) {
      case 'abs': return loc.abs;
      case 'chest': return loc.chest;
      case 'back': return loc.back;
      case 'arms': return loc.arms;
      case 'legs': return loc.legs;
      case 'shoulders': return loc.shoulders;
      default: return key.toUpperCase();
    }
  }
}
