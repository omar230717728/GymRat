import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/core/models/exercise_model.dart';
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

    final exercises = snap.docs
        .map((doc) => ExerciseModel.fromSnapshot(doc))
        .toList();

    emit(FavoritesState(favorites: exercises));
  }

  Future<void> toggleFavorite(ExerciseModel exercise) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final userRef = _firestore.collection('users').doc(uid);
    final favRef = userRef.collection('favorites').doc(exercise.id);

    // Make sure favoritesCount exists for old users
    await userRef.set({'favoritesCount': 0}, SetOptions(merge: true));

    final exists = (await favRef.get()).exists;

    if (exists) {
      await favRef.delete();
      await userRef.update({
        'favoritesCount': FieldValue.increment(-1),
      });
    } else {
      // We need to save the exercise data to Firestore so we can reconstruct it
      // ExerciseModel doesn't have toMap/toJson yet, so I'll create one or manually map it here.
      // I'll manually map it for now.
      final data = {
        'name': exercise.name,
        'imageUrl': exercise.imageUrl,
        'videoUrl': exercise.videoUrl,
        'steps': exercise.steps,
        'commonMistakes': exercise.commonMistakes,
        'targetMuscles': exercise.targetMuscles,
        'order': exercise.order,
      };
      await favRef.set(data);
      await userRef.update({
        'favoritesCount': FieldValue.increment(1),
      });
    }

    await loadFavorites();
  }
}
