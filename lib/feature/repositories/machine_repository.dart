import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/core/utils/machine.dart';

class MachineRepository {
  final FirebaseFirestore _firestore;

  MachineRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Machine>> getMachines() async {
    final snap = await _firestore.collection("machines").get();
    return snap.docs
        .map((d) => Machine.fromMap(d.id, d.data()))
        .toList();
  }
}
