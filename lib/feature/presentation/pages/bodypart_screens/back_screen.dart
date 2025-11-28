import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/utils/machine.dart';
import 'package:flutter_application_1/core/shared/machine_grid.dart';

class BackScreen extends StatelessWidget {
  const BackScreen({super.key});

  // Fetch machines for "chest" body part
  Stream<List<Machine>> fetchMachines() {
    return FirebaseFirestore.instance
        .collection('machines')
        .where('bodyPart', isEqualTo: 'back')
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
      appBar: AppBar(title: const Text("Chest Workouts")),
      body: StreamBuilder<List<Machine>>(
        stream: fetchMachines(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final machines = snapshot.data!;

          return buildMachinesGrid(context, machines);
        },
      ),
    );
  }
}
