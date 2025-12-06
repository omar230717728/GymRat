import 'package:flutter/material.dart';
import 'package:flutter_application_1/feature/presentation/pages/exercise_list_screen.dart';
import 'package:flutter_application_1/core/repositories/gym_repository.dart';
import 'package:flutter_application_1/core/models/muscle_model.dart';
import 'package:flutter_application_1/core/di/injection_container.dart' as di;
import 'package:flutter_application_1/feature/presentation/widgets/smart_image.dart'; // <--- IMPORT

class MuscleListScreen extends StatefulWidget {
  final String bodyPartId;
  final String bodyPartName;

  const MuscleListScreen({
    super.key,
    required this.bodyPartId,
    required this.bodyPartName,
  });

  @override
  State<MuscleListScreen> createState() => _MuscleListScreenState();
}

class _MuscleListScreenState extends State<MuscleListScreen> {
  List<MuscleModel> _muscles = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMuscles();
  }

  Future<void> _loadMuscles() async {
    try {
      final muscles = await di.sl<GymRepository>().fetchMuscles(
        widget.bodyPartId,
      );
      if (mounted) {
        setState(() {
          _muscles = muscles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.bodyPartName)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text('Error: $_errorMessage'))
          : _muscles.isEmpty
          ? const Center(child: Text('No muscles found'))
          : GridView.builder(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom:
                    130, // <--- Pushes the last muscle item above the Nav Bar
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              itemCount: _muscles.length,
              itemBuilder: (context, index) {
                final muscle = _muscles[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExerciseListScreen(
                          bodyPartId: widget.bodyPartId,
                          muscleId: muscle.id,
                          muscleName: muscle.name,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background Image
                          SmartImage(
                            imageUrl: muscle.image,
                            fit: BoxFit.cover,
                          ),

                          // Gradient Overlay
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Muscle Name
                          Positioned(
                            bottom: 12,
                            left: 12,
                            right: 12,
                            child: Text(
                              muscle.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
