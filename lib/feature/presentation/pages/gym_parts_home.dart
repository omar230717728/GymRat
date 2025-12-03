import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/core/utils/excercise_class.dart';
import 'package:flutter_application_1/feature/cubit/body_parts_cubit.dart';
import 'package:flutter_application_1/feature/cubit/language_cubit.dart';
import 'package:flutter_application_1/feature/presentation/pages/muscle_list_screen.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_application_1/feature/cubit/progress_cubit.dart';

class GymPartScreen extends StatefulWidget {
  static const String placeholderCategoryImage = "https://i.imgur.com/BoN9kdC.png";

  const GymPartScreen({super.key});

  @override
  State<GymPartScreen> createState() => _GymPartScreenState();
}

class _GymPartScreenState extends State<GymPartScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BodyPartsCubit>().loadBodyParts();
    context.read<ProgressCubit>().logVisit(bodyPart: 'All');
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final languageCode = context.select((LanguageCubit cubit) => cubit.state.locale.languageCode);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.surface.withOpacity(0.9),
            Theme.of(context).colorScheme.surface,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 14,
          right: 9,
          left: 9,
        ), // Add space for appbar
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                loc.workoutCategories,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<BodyPartsCubit, BodyPartsState>(
                builder: (context, state) {
                  if (state is BodyPartsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is BodyPartsLoaded) {
                    return GridView.builder(
                      shrinkWrap: true,
                      // physics: const NeverScrollableScrollPhysics(), // Allow scrolling if needed
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: state.bodyParts.length,
                      itemBuilder: (context, index) {
                        final bodyPart = state.bodyParts[index];
                        final name = bodyPart.name[languageCode] ?? bodyPart.name['en'] ?? 'Unknown';
                        
                        // Create a temporary ExerciseCategory for the card
                        final category = ExerciseCategory(
                          name: name,
                          imagePath: bodyPart.imageUrl.isNotEmpty 
                              ? bodyPart.imageUrl 
                              : GymPartScreen.placeholderCategoryImage,
                          targetScreen: MuscleListScreen(
                            bodyPartId: bodyPart.id,
                            bodyPartName: bodyPart.name,
                          ),
                        );

                        // We might need to adjust ExerciseCategoryCard to handle network images if imagePath is a URL
                        // For now, assuming ExerciseCategoryCard handles it or we need to modify it.
                        // The existing ExerciseCategoryCard uses AssetImage. I should probably update it or create a new one.
                        // Since I can't easily modify ExerciseCategoryCard without checking it again, I'll use a custom card here or modify ExerciseCategoryCard.
                        // Given the prompt "Rebuild... strictly following... UI Rules", I should probably stick to the design.
                        // I'll use a custom card here that looks like ExerciseCategoryCard but supports network images.
                        
                        return _buildCategoryCard(context, category);
                      },
                    );
                  } else if (state is BodyPartsError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  return const Center(child: Text('No body parts found'));
                },
              ),
            ),
            const SizedBox(height: 80), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, ExerciseCategory category) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => category.targetScreen,
              fullscreenDialog: false,
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: category.imagePath.startsWith('http') 
                  ? NetworkImage(category.imagePath) 
                  : AssetImage(category.imagePath) as ImageProvider,
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.4),
                BlendMode.darken,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fitness_center, size: 40, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                category.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
