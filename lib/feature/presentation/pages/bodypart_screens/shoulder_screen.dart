import 'package:flutter/material.dart';
import 'package:flutter_application_1/feature/presentation/pages/muscle_list_screen.dart';

class ShoulderScreen extends StatelessWidget {
  const ShoulderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MuscleListScreen(bodyPartId: 'shoulders', bodyPartName: 'Shoulders');
  }
}
