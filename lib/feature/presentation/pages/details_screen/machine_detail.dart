import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/services/favorites_service.dart';
import 'package:flutter_application_1/core/utils/helper_functions.dart';

import 'package:flutter_application_1/core/utils/machine.dart';
import 'package:flutter_application_1/core/auth/login_required_popup.dart';
import 'package:flutter_application_1/core/auth/login_screen.dart';
import 'package:flutter_application_1/feature/cubit/favorite_state.dart';
import 'package:flutter_application_1/feature/cubit/favorites_cubit.dart';
import 'package:flutter_application_1/feature/presentation/pages/details_screen/youtube_video_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  @override
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        final isFavorite = state.favorites.any(
          (m) => m.id == widget.machine.id,
        );

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
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
      child: const Center(
        child: Text(
          "Video Mode",
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
    );
  }

  // ---------------- CONTENT ----------------
  Widget _buildContent(BuildContext context, bool isFavorite) {
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
                  widget.machine.name,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onBackground,
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

          const SizedBox(height: 16),

          // Description
          Text(
            "Description",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            widget.machine.description,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Theme.of(
                context,
              ).colorScheme.onBackground.withOpacity(0.8),
            ),
          ),

          const SizedBox(height: 24),

          // Instructions
          Text(
            "Instructions",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),

          const SizedBox(height: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.machine.instructions.map((step) {
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
                          ).colorScheme.onBackground.withOpacity(0.8),
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
}
