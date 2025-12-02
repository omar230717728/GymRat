import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/utils/machine.dart';
import 'package:flutter_application_1/core/shared/machine_grid.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';

class ArmScreen extends StatelessWidget {
  const ArmScreen({super.key});

  // Fetch machines for "chest" body part
  Stream<List<Machine>> fetchMachines() {
    return FirebaseFirestore.instance
        .collection('machines')
        .where('bodyPart', isEqualTo: 'arm')
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
      appBar: AppBar(title: Text("${AppLocalizations.of(context)!.arms} ${AppLocalizations.of(context)!.workouts}")),
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
