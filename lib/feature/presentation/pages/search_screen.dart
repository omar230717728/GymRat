import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/utils/machine.dart';
import 'package:flutter_application_1/core/shared/machine_grid.dart';

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

  String activeFilter = "";

  @override
  void initState() {
    super.initState();
    loadMachines();
    _controller.addListener(() => applySearch());
  }

  Future<void> loadMachines() async {
    final snap = await FirebaseFirestore.instance.collection("machines").get();
    allMachines = snap.docs
        .map((d) => Machine.fromMap(d.id, d.data()))
        .toList();
    filtered = allMachines;
    loading = false;
    setState(() {});
  }

  void applySearch() {
    final q = _controller.text.toLowerCase();

    setState(() {
      filtered = allMachines.where((m) {
        final matchesText = m.name.toLowerCase().contains(q);
        final matchesFilter =
            activeFilter.isEmpty ? true : m.bodyPart == activeFilter;
        return matchesText && matchesFilter;
      }).toList();
    });
  }

  void setFilter(String part) {
    setState(() {
      activeFilter = part == activeFilter ? "" : part;
    });
    applySearch();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(title: const Text("Search")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search machines…",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Filters
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
                      f.toUpperCase(),
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
                ? const Center(child: Text("No results"))
                : buildMachinesGrid(context, filtered),
          ),
        ],
      ),
    );
  }
}
