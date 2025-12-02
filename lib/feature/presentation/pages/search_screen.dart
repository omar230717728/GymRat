import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/utils/machine.dart';
import 'package:flutter_application_1/core/shared/machine_grid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/feature/cubit/language_cubit.dart';
import 'package:flutter_application_1/core/di/injection_container.dart';
import 'package:flutter_application_1/feature/repositories/machine_repository.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Machine> allMachines = [];
  List<Machine> filtered = [];
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
  String selectedEquipment = "";
  String activeFilter = "";

  @override
  void initState() {
    super.initState();
    loadMachines();
    _controller.addListener(() => applySearch());
  }

  Future<void> loadMachines() async {
    allMachines = await sl<MachineRepository>().getMachines();
    filtered = allMachines;
    loading = false;
    setState(() {});
  }

  void applySearch() {
    final q = _controller.text.toLowerCase();

    final locale = context.read<LanguageCubit>().state.locale.languageCode;

    setState(() {
      filtered = allMachines.where((m) {
        final name = m.getName(locale);
        final matchesText = name.toLowerCase().contains(q);
        final matchesBodyPart =
            activeFilter.isEmpty ? true : m.bodyPart == activeFilter;
        final matchesDifficulty = selectedDifficulty.isEmpty
            ? true
            : m.difficulty == selectedDifficulty;
        // Assuming machine has equipment field, if not we skip or add it to model
        // For now, let's assume filtering by difficulty is enough or check if model has equipment
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

  String _getLocalizedDifficulty(String key) {
    final loc = AppLocalizations.of(context)!;
    switch (key) {
      case 'beginner': return loc.beginner;
      case 'intermediate': return loc.intermediate;
      case 'advanced': return loc.advanced;
      default: return key.toUpperCase();
    }
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

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.filterByDifficulty,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: ["beginner", "intermediate", "advanced"].map((d) {
                      final isSelected = selectedDifficulty == d;
                      return FilterChip(
                        label: Text(_getLocalizedDifficulty(d)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            selectedDifficulty = selected ? d : "";
                          });
                          setState(() {
                            // Update parent state as well
                            selectedDifficulty = selected ? d : "";
                          });
                          applySearch();
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalizations.of(context)!.done),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.search),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: selectedDifficulty.isNotEmpty
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            onPressed: _showFilterSheet,
          ),
        ],
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

          // Body Part Filters
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
