import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/models/exercise_model.dart';
import 'package:flutter_application_1/core/shared/machine_grid.dart';
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

  final List<String> filters = [
    "abs",
    "chest",
    "back",
    "arms",
    "legs",
    "shoulders",
  ];
  String selectedDifficulty = "";
  String activeFilter = "";

  @override
  void initState() {
    super.initState();
    loadExercises();
    _controller.addListener(() => applySearch());
  }

  Future<void> loadExercises() async {
    allExercises = await sl<GymRepository>().getAllExercises();
    filtered = allExercises;
    loading = false;
    setState(() {});
  }

  void applySearch() {
    final q = _controller.text.toLowerCase();

    final locale = context.read<LanguageCubit>().state.locale.languageCode;

    setState(() {
      filtered = allExercises.where((e) {
        final name = e.name[locale] ?? e.name['en'] ?? 'Unknown';
        final matchesText = name.toLowerCase().contains(q);
        final matchesBodyPart = activeFilter.isEmpty 
            ? true 
            : e.targetMuscles.any((m) => m.toLowerCase().contains(activeFilter));
        final matchesDifficulty = true; 

        return matchesText && matchesBodyPart && matchesDifficulty;
      }).toList();
    });
  }

  void setFilter(String part) {
    setState(() {
      activeFilter = part == activeFilter ? "" : part;
    });
    applySearch();
  }

  String _getLocalizedBodyPart(String key) {
    final loc = AppLocalizations.of(context)!;
    switch (key) {
      case 'abs': return loc.abs;
      case 'chest': return loc.chest;
      case 'back': return loc.back;
      case 'arms': return loc.arms;
      case 'legs': return loc.legs;
      case 'shoulders': return loc.shoulders;
      default: return key.toUpperCase();
    }
  }
  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.search),
        // actions: [
        //   IconButton(
        //     icon: Icon(
        //       Icons.filter_list,
        //       color: selectedDifficulty.isNotEmpty
        //           ? Theme.of(context).colorScheme.primary
        //           : null,
        //     ),
        //     onPressed: _showFilterSheet,
        //   ),
        // ],
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

          // Body Part Filters - keeping them but they might be less effective without direct mapping
          SizedBox(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: filters.map((f) {
                final active = activeFilter == f;
                return GestureDetector(
                  onTap: () => setFilter(f),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: active
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getLocalizedBodyPart(f),
                      style: TextStyle(
                        color: active
                            ? Colors.white
                            : Colors.grey.shade300,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text(AppLocalizations.of(context)!.noResults))
                : buildMachinesGrid(context, filtered, highlightTerm: _controller.text),
          ),
        ],
      ),
    );
  }
}
