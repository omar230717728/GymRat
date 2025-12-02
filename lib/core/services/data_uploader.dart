import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class DataUploader {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadData() async {
    try {
      final String response = await rootBundle.loadString('assets/data/machines.json');
      final List<dynamic> data = json.decode(response);

      final WriteBatch batch = _firestore.batch();

      for (var item in data) {
        final docRef = _firestore.collection('machines').doc(item['id']);
        batch.set(docRef, item);
      }

      await batch.commit();
      print('Data uploaded successfully!');
    } catch (e) {
      print('Error uploading data: $e');
      rethrow;
    }
  }
}
