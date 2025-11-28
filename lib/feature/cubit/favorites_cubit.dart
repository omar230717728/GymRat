import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/core/utils/machine.dart';
import 'package:flutter_application_1/feature/cubit/favorite_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit() : super(FavoritesState(favorites: []));

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> loadFavorites() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final snap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .get();

    final machines = snap.docs
        .map((doc) => Machine.fromFirestore(doc.data(), doc.id))
        .toList();

    emit(FavoritesState(favorites: machines));
  }

  Future<void> toggleFavorite(Machine machine) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final userRef = _firestore.collection('users').doc(uid);
    final favRef = userRef.collection('favorites').doc(machine.id);

    // Make sure favoritesCount exists for old users
    await userRef.set({'favoritesCount': 0}, SetOptions(merge: true));

    final exists = (await favRef.get()).exists;

    if (exists) {
      await favRef.delete();
      await userRef.update({
        'favoritesCount': FieldValue.increment(-1),
      });
    } else {
      await favRef.set(machine.toFirestore());
      await userRef.update({
        'favoritesCount': FieldValue.increment(1),
      });
    }

    await loadFavorites();
  }
}
