import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/auth/login_required_popup.dart';
import 'package:flutter_application_1/feature/cubit/language_cubit.dart';
import 'package:flutter_application_1/feature/presentation/pages/details_screen/youtube_video_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/core/di/injection_container.dart' as di;
import 'package:flutter_application_1/core/models/exercise_model.dart';
import 'package:flutter_application_1/core/models/machine_model.dart';
import 'package:flutter_application_1/core/models/user_model.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_application_1/core/services/user_session_service.dart';
import 'package:flutter_application_1/core/repositories/gym_repository.dart';

class MachineDetailScreen extends StatefulWidget {
  final ExerciseModel? exercise;
  final String? machineId;
  final String? bodyPartId;

  const MachineDetailScreen({
    super.key, 
    this.exercise,
    this.machineId,
    this.bodyPartId,
  });

  @override
  State<MachineDetailScreen> createState() => _MachineDetailScreenState();
}

class _MachineDetailScreenState extends State<MachineDetailScreen>
    with WidgetsBindingObserver {
  bool isLandscape = false;
  MachineModel? _machine;
  ExerciseModel? _currentExercise;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _initData() async {
    try {
      if (widget.exercise != null) {
        _currentExercise = widget.exercise;
        // Load machine details
        if (_currentExercise!.machineId.isNotEmpty) {
          _machine = await di.sl<GymRepository>().fetchMachine(_currentExercise!.machineId);
        }
      } else if (widget.machineId != null) {
        // Load machine and exercises
        _machine = await di.sl<GymRepository>().fetchMachine(widget.machineId!);
        final exercises = await di.sl<GymRepository>().fetchExercisesByMachineId(widget.machineId!);
        if (exercises.isNotEmpty) {
          _currentExercise = exercises.first;
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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

  void _toggleFavorite() {
    if (!isUserLoggedIn()) {
      _showLoginPopup();
      return;
    }
    final mid = _machine?.id ?? _currentExercise?.machineId;
    if (mid != null && mid.isNotEmpty) {
      UserSessionService.instance.toggleFavorite(mid);
    }
  }

  void _openVideo() {
    if (_currentExercise != null && _currentExercise!.videoUrl.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => YouTubeVideoScreen(videoUrl: _currentExercise!.videoUrl),
        ),
      );
    }
  }

  bool isUserLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }

  void _showLoginPopup() {
    showDialog(
      context: context,
      builder: (_) => LoginRequiredPopup(
        onConfirm: () {
          // Navigation handled by popup
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  Future<void> _completeWorkout() async {
    if (!isUserLoggedIn()) {
      _showLoginPopup();
      return;
    }

    if (_currentExercise == null) return;

    try {
      // We need bodyPartId. If not passed, we might need to fetch it or use 'Unknown'.
      // For now, use widget.bodyPartId or try to get it from muscle?
      // UserSessionService.logProgress needs bodyPartId (optional in model but required in method? Let's check method).
      // Method: logProgress({required String exerciseId, required String bodyPartId})
      // I should make bodyPartId optional in logProgress or fetch it.
      // But for now I'll use widget.bodyPartId ?? 'Unknown'.
      
      String? muscleName;
      if (_machine != null && _machine!.primaryMuscles.isNotEmpty) {
        muscleName = _machine!.primaryMuscles.first;
      }

      await UserSessionService.instance.logProgress(
        exerciseId: _currentExercise!.id,
        bodyPartId: widget.bodyPartId ?? 'Unknown',
        machineName: _machine?.name ?? _currentExercise?.name ?? 'Unknown Machine',
        muscleName: muscleName,
        machineId: _machine?.id ?? _currentExercise?.machineId,
        imageUrl: _machine?.image ?? _currentExercise?.imageUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.workoutLogged)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to log workout: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_currentExercise == null && _machine == null) {
      return const Scaffold(body: Center(child: Text("Details not found")));
    }

    return StreamBuilder<UserModel?>(
      stream: UserSessionService.instance.userStream,
      initialData: UserSessionService.instance.currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final machineId = _machine?.id ?? _currentExercise?.machineId;
        final isFavorite = (machineId != null) ? (user?.favoriteIds.contains(machineId) ?? false) : false;

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
  // ---------------- PORTRAIT MODE ----------------
  Widget _buildPortraitView(BuildContext context, bool isFavorite) {
    final imageUrl = _currentExercise?.videoUrl.isNotEmpty == true
        ? 'https://img.youtube.com/vi/${_extractVideoId(_currentExercise!.videoUrl)}/0.jpg'
        : (_machine?.image.isNotEmpty == true 
            ? _machine!.image 
            : "assets/body_part_images/Screenshot 2025-09-30 232210.jpg"); // Fallback

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
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                   ClipRRect(
                     borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                     child: imageUrl.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(color: Colors.grey[900]),
                            errorWidget: (context, url, error) => Container(color: Colors.grey[900]),
                          )
                        : Image.asset(imageUrl, fit: BoxFit.cover),
                   ),
                   Container(
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
                ],
              ),
            ),
          ),
        ),

        // Content
        Expanded(flex: 3, child: _buildContent(context, isFavorite)),
      ],
    );
  }

  String _extractVideoId(String url) {
    final regExp = RegExp(r'^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#&?]*).*');
    final match = regExp.firstMatch(url);
    return (match != null && match.group(7) != null) ? match.group(7)! : '';
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
    final name = _currentExercise?.name ?? _machine?.name ?? 'Unknown';
    
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
                onPressed: _toggleFavorite,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Machine Info
          if (_machine != null) ...[
            Text(
              "Machine: ${_machine!.name}",
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTag(context, _machine!.equipmentType, Colors.blue),
                ..._machine!.primaryMuscles.map((m) => _buildTag(context, m, Colors.red)),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Complete Workout Button
          if (_currentExercise != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _completeWorkout,
                icon: const Icon(Icons.check_circle),
                label: const Text("Complete Workout"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Description
          if (_currentExercise != null && _currentExercise!.description.isNotEmpty) ...[
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
              _currentExercise!.description,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 24),
          ],
          
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
}
