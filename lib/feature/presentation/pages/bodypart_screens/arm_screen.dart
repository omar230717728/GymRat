import 'package:flutter/material.dart';
import 'package:flutter_application_1/feature/presentation/pages/muscle_list_screen.dart';

class ArmScreen extends StatelessWidget {
  const ArmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MuscleListScreen(bodyPartId: 'arms', bodyPartName: 'Arms');
  }
}
