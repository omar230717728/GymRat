import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application_1/core/utils/excercise_class.dart';
import 'package:flutter_application_1/feature/presentation/pages/bodypart_screens/abs_screen.dart';
import 'package:flutter_application_1/feature/presentation/pages/bodypart_screens/arm_screen.dart';
import 'package:flutter_application_1/feature/presentation/pages/bodypart_screens/back_screen.dart';
import 'package:flutter_application_1/feature/presentation/pages/bodypart_screens/chest_screen.dart';
import 'package:flutter_application_1/feature/presentation/pages/bodypart_screens/leg_screen.dart';
import 'package:flutter_application_1/feature/presentation/pages/bodypart_screens/shoulder_screen.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';

class GymPartScreen extends StatelessWidget {
  static const String placeholderCategoryImage = "https://i.imgur.com/BoN9kdC.png";

  const GymPartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final List<ExerciseCategory> categories = [
      ExerciseCategory(
        name: loc.chest,
        imagePath: placeholderCategoryImage,
        targetScreen: ChestScreen(),
      ),
      ExerciseCategory(
        name: loc.back,
        imagePath: placeholderCategoryImage,
        targetScreen: BackScreen(),
      ),
      ExerciseCategory(
        name: loc.legs,
        imagePath: placeholderCategoryImage,
        targetScreen: LegScreen(),
      ),
      ExerciseCategory(
        name: loc.arms,
        imagePath: placeholderCategoryImage,
        targetScreen: ArmScreen(),
      ),
      ExerciseCategory(
        name: loc.shoulders,
        imagePath: placeholderCategoryImage,
        targetScreen: ShoulderScreen(),
      ),
      ExerciseCategory(
        name: loc.abs,
        imagePath: placeholderCategoryImage,
        targetScreen: AbsScreen(),
      ),
    ];

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
        child: ListView(
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
            // Grid of exercise categories
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.9,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return ExerciseCategoryCard(category: categories[index]);
              },
            ),
            const SizedBox(height: 80), // Space for bottom navigation
          ],
        ),
      ),
    );
  }
}
