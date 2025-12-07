import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/di/injection_container.dart';
import 'package:flutter_application_1/core/models/machine_model.dart';
import 'package:flutter_application_1/core/repositories/gym_repository.dart';
import 'package:flutter_application_1/core/services/user_session_service.dart';
import 'package:flutter_application_1/feature/presentation/pages/details_screen/machine_detail.dart'; // Ensure correct path
import 'package:flutter_application_1/core/models/user_model.dart';
import 'package:flutter_application_1/feature/presentation/widgets/exercise_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<MachineModel>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    final ids = UserSessionService.instance.favoriteIds;
    if (ids.isEmpty) {
      _favoritesFuture = Future.value([]);
    } else {
      _favoritesFuture = sl<GymRepository>().getMachinesByIds(ids);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'FAVORITES',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<UserModel?>(
        stream: UserSessionService.instance.userStream,
        builder: (context, snapshot) {
          // Reload favorites when user data changes
          _loadFavorites(); 

          return FutureBuilder<List<MachineModel>>(
            future: _favoritesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)));
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading favorites',
                    style: TextStyle(color: Colors.red[400]),
                  ),
                );
              }

              final machines = snapshot.data ?? [];

              if (machines.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 64, color: Colors.white24),
                      SizedBox(height: 16),
                      Text(
                        'No favorites yet',
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                // FIX 2: Increased bottom padding to 120 to avoid Nav Bar overlap
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: machines.length,
                itemBuilder: (context, index) {
                  final machine = machines[index];
                  return ExerciseCard(
                    title: machine.name,
                    subtitle: machine.primaryMuscles.isNotEmpty
                        ? machine.primaryMuscles.first
                        : "Machine",
                    imageUrl: machine.image,
                    width: double.infinity,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MachineDetailScreen(machineId: machine.id),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}