import 'package:flutter/material.dart';
import 'database_seeder.dart';

class SeedPage extends StatelessWidget {
  const SeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seed Database")),
      body: Center(
        child: ElevatedButton(
          child: const Text("Seed Now"),
          onPressed: () async {
            final seeder = DatabaseSeeder();
            await seeder.seedDatabase();
          },
        ),
      ),
    );
  }
}
