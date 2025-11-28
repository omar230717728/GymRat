import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/core/utils/machine.dart';

class FavoritesService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> add(String uid, Machine m) async {
    final userRef = _firestore.collection('users').doc(uid);

    await userRef.set({'favoritesCount': 0}, SetOptions(merge: true));

    await userRef.collection('favorites').doc(m.id).set(m.toFirestore());
    await userRef.update({'favoritesCount': FieldValue.increment(1)});
  }

  static Future<void> remove(String uid, Machine m) async {
    final userRef = _firestore.collection('users').doc(uid);

    await userRef.collection('favorites').doc(m.id).delete();
    await userRef.update({'favoritesCount': FieldValue.increment(-1)});
  }

  static Future<List<Machine>> getFavorites(String uid) async {
    final snap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .get();

    return snap.docs
        .map((d) => Machine.fromFirestore(d.data(), d.id))
        .toList();
  }
}
