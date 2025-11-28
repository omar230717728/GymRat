import 'package:flutter/material.dart';

class ExerciseCategory {
  final String name;
  final String imagePath;
  final Widget targetScreen;

  ExerciseCategory({
    required this.name,
    required this.imagePath,
    required this.targetScreen,
  });
}

class ExerciseCategoryCard extends StatelessWidget {
  final ExerciseCategory category;

  const ExerciseCategoryCard({Key? key, required this.category})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => category.targetScreen,
              fullscreenDialog: false, // Important: don't make it full screen
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              // category.imagePath
              image: AssetImage("assets/body_part_images/Screenshot 2025-09-30 232210.jpg"),
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
              Icon(Icons.fitness_center, size: 40, color: Colors.white),
              SizedBox(height: 8),
              Text(
                category.name,
                style: TextStyle(
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
