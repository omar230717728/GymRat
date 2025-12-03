import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/feature/cubit/muscle_list_cubit.dart';
import 'package:flutter_application_1/feature/cubit/language_cubit.dart';
import 'package:flutter_application_1/feature/presentation/pages/machine_list_screen.dart';
import 'package:flutter_application_1/feature/cubit/progress_cubit.dart';

class MuscleListScreen extends StatefulWidget {
  final String bodyPartId;
  final Map<String, String> bodyPartName;

  const MuscleListScreen({
    super.key,
    required this.bodyPartId,
    required this.bodyPartName,
  });

  @override
  State<MuscleListScreen> createState() => _MuscleListScreenState();
}

class _MuscleListScreenState extends State<MuscleListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MuscleListCubit>().loadMuscles(widget.bodyPartId);
    context.read<ProgressCubit>().logVisit(
      muscleName: widget.bodyPartName['en'] ?? widget.bodyPartName.values.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = context.select((LanguageCubit cubit) => cubit.state.locale.languageCode);
    final title = widget.bodyPartName[languageCode] ?? widget.bodyPartName['en'] ?? 'Muscles';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: BlocBuilder<MuscleListCubit, MuscleListState>(
        builder: (context, state) {
          if (state is MuscleListLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MuscleListLoaded) {
            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8, // Adjust for card height
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              itemCount: state.muscles.length,
              itemBuilder: (context, index) {
                final muscle = state.muscles[index];
                final muscleName = muscle.name[languageCode] ?? muscle.name['en'] ?? 'Unknown';
                
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MachineListScreen(
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
                          muscle.imageUrl.isNotEmpty
                              ? Image.network(
                                  muscle.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(color: Colors.grey[300], child: const Icon(Icons.fitness_center, size: 40)),
                                )
                              : Container(color: Colors.grey[300], child: const Icon(Icons.fitness_center, size: 40)),
                          
                          // Gradient Overlay for Text Readability
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
                              muscleName,
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
            );
          } else if (state is MuscleListError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Select a body part'));
        },
      ),
    );
  }
}
