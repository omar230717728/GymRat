import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/di/injection_container.dart';
import 'package:flutter_application_1/core/models/exercise_model.dart';
import 'package:flutter_application_1/core/repositories/gym_repository.dart';
import 'package:flutter_application_1/feature/presentation/pages/details_screen/machine_detail.dart';
import 'package:flutter_application_1/feature/presentation/widgets/exercise_card.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  
  List<ExerciseModel> _allExercises = [];
  List<ExerciseModel> _filteredExercises = [];
  
  bool _isLoading = true;
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Chest', 'Back', 'Legs', 'Arms', 'Abs'];

  @override
  void initState() {
    super.initState();
    _loadExercises();
    _controller.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    try {
      final exercises = await sl<GymRepository>().getAllExercises();
      if (mounted) {
        setState(() {
          _allExercises = exercises;
          _filteredExercises = exercises;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    final query = _controller.text.toLowerCase();
    
    setState(() {
      _filteredExercises = _allExercises.where((exercise) {
        // 1. Text Search
        final nameMatch = exercise.name.toLowerCase().contains(query);
        final muscleMatch = exercise.targetMuscles.any((m) => m.toLowerCase().contains(query));
        
        if (!nameMatch && !muscleMatch) return false;

        // 2. Category Filter
        if (_selectedFilter == 'All') return true;

        // Map broad categories to likely substrings
        final List<String> keywords = switch (_selectedFilter) {
          'Chest' => ['Chest', 'Pectoral'],
          'Back' => ['Back', 'Lat', 'Trap'],
          'Legs' => ['Leg', 'Quad', 'Calf', 'Glute', 'Hamstring'],
          'Arms' => ['Arm', 'Bicep', 'Tricep'],
          'Abs' => ['Ab', 'Core'],
          _ => [_selectedFilter],
        };

        return exercise.targetMuscles.any((muscle) {
           return keywords.any((k) => muscle.toLowerCase().contains(k.toLowerCase()));
        });
      }).toList();
    });
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // 1. Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "DISCOVER",
                style: TextStyle(
                  fontFamily: 'Bebas Neue', // Fallback handled by Flutter if missing
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // 2. Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    hintText: AppLocalizations.of(context)?.searchHint ?? "Search exercises...", // Safe fallback
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 3. Quick Filters
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = filter == _selectedFilter;
                  return GestureDetector(
                    onTap: () => _onFilterSelected(filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected ? null : Border.all(color: Colors.white12),
                      ),
                      child: Center(
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // 4. Content Grid
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : _filteredExercises.isEmpty
                    ? Center(
                        child: Text(
                          AppLocalizations.of(context)?.noResults ?? "No results found",
                          style: const TextStyle(color: Colors.white54),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85, // Adjust for card height
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _filteredExercises.length,
                        itemBuilder: (context, index) {
                          final exercise = _filteredExercises[index];
                          return ExerciseCard(
                            title: exercise.name,
                            subtitle: exercise.targetMuscles.isNotEmpty 
                                ? exercise.targetMuscles.first 
                                : "Exercise",
                            imageUrl: exercise.imageUrl,
                            width: double.infinity, // Fill grid cell
                            onTap: () {
                              Navigator.push(
                                context, 
                                MaterialPageRoute(
                                  builder: (_) => MachineDetailScreen(exercise: exercise),
                                ),
                              );
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
