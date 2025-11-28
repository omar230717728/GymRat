import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application_1/core/utils/excercise_class.dart';
import 'package:flutter_application_1/feature/presentation/pages/bodypart_screens/abs_screen.dart';
import 'package:flutter_application_1/feature/presentation/pages/bodypart_screens/arm_screen.dart';
import 'package:flutter_application_1/feature/presentation/pages/bodypart_screens/back_screen.dart';
import 'package:flutter_application_1/feature/presentation/pages/bodypart_screens/chest_screen.dart';
import 'package:flutter_application_1/feature/presentation/pages/bodypart_screens/leg_screen.dart';
import 'package:flutter_application_1/feature/presentation/pages/bodypart_screens/shoulder_screen.dart';

class GymPartScreen extends StatelessWidget {
static const String placeholderCategoryImage = "https://i.imgur.com/BoN9kdC.png";
    

final List<ExerciseCategory> categories = [
  ExerciseCategory(
    name: 'Chest',
    imagePath: placeholderCategoryImage,
    targetScreen: ChestScreen(),
  ),
  ExerciseCategory(
    name: 'Back',
    imagePath: placeholderCategoryImage,
    targetScreen: BackScreen(),
  ),
  ExerciseCategory(
    name: 'Legs',
    imagePath: placeholderCategoryImage,
    targetScreen: LegScreen(),
  ),
  ExerciseCategory(
    name: 'Arms',
    imagePath: placeholderCategoryImage,
    targetScreen: ArmScreen(),
  ),
  ExerciseCategory(
    name: 'Shoulders',
    imagePath: placeholderCategoryImage,
    targetScreen: ShoulderScreen(),
  ),
  ExerciseCategory(
    name: 'Abs',
    imagePath: placeholderCategoryImage,
    targetScreen: AbsScreen(),
  ),
];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.surface.withOpacity(0.9),
            Theme.of(context).colorScheme.background,
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
                'Workout Categories',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
            SizedBox(height: 20),
            // Grid of exercise categories
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
            SizedBox(height: 80), // Space for bottom navigation
          ],
        ),
      ),
    );
  }
}
