import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/models/exercise_model.dart';
import 'package:flutter_application_1/core/models/machine_model.dart';
import 'package:flutter_application_1/feature/presentation/widgets/machine_grid.dart';
import 'package:flutter_application_1/feature/presentation/pages/details_screen/machine_detail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/feature/cubit/language_cubit.dart';
import 'package:flutter_application_1/core/di/injection_container.dart';
import 'package:flutter_application_1/core/repositories/gym_repository.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<ExerciseModel> allExercises = [];
  List<ExerciseModel> filtered = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadExercises();
    _controller.addListener(() => applySearch());
  }

  Future<void> loadExercises() async {
    try {
      allExercises = await sl<GymRepository>().getAllExercises();
      filtered = allExercises;
      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  void applySearch() {
    final q = _controller.text.toLowerCase();

    setState(() {
      filtered = allExercises.where((e) {
        final name = e.name.toLowerCase();
        final matchesText = name.contains(q);
        return matchesText;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.search),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: AppLocalizations.of(context)!.searchHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text(AppLocalizations.of(context)!.noResults))
                : MachineGridWidget(
                    machines: filtered.map((e) => MachineModel(
                      id: e.id,
                      name: e.name,
                      image: e.imageUrl,
                      equipmentType: '',
                      bodyParts: [],
                      primaryMuscles: e.targetMuscles,
                      secondaryMuscles: [],
                    )).toList(),
                    onMachineTap: (machine) {
                      final exercise = filtered.firstWhere((e) => e.id == machine.id);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MachineDetailScreen(exercise: exercise),
                        ),
                      );
                    },
                    highlightTerm: _controller.text,
                  ),
          ),
        ],
      ),
    );
  }
}
