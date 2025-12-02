import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/utils/machine.dart';
import 'package:flutter_application_1/core/shared/machine_grid.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';

class AbsScreen extends StatelessWidget {
  const AbsScreen({super.key});

  // Fetch machines for "abs" body part
  Stream<List<Machine>> fetchMachines() {
    return FirebaseFirestore.instance
        .collection('machines')
        .where('bodyPart', isEqualTo: 'abs')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Machine.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${AppLocalizations.of(context)!.abs} ${AppLocalizations.of(context)!.workouts}")),
      body: StreamBuilder<List<Machine>>(
        stream: fetchMachines(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No machines found.",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final machines = snapshot.data!;

          return buildMachinesGrid(context, machines);
        },
      ),
    );
  }
}
