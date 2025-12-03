import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgressRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ProgressRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<Map<String, dynamic>> fetchProgressStats() async {
    final user = _auth.currentUser;
    if (user == null) return {'exercises': 0, 'machines': 0, 'muscles': 0};

    final docRef = _firestore.collection('users').doc(user.uid).collection('stats').doc('summary');

    try {
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        // Auto-create if missing
        final initialData = {
          'exercises': 0,
          'machines': 0,
          'muscles': 0,
          'last_updated': FieldValue.serverTimestamp(),
        };
        await docRef.set(initialData);
        return initialData;
      }

      final data = docSnapshot.data();
      if (data == null) return {'exercises': 0, 'machines': 0, 'muscles': 0};

      return {
        'explored_machine_names': data['explored_machine_names'] ?? [],
        'learned_exercise_names': data['learned_exercise_names'] ?? [],
        'muscle_scores': data['muscle_scores'] ?? {},
      };
    } catch (e) {
      print('Error fetching progress stats: $e');
      return {'exercises': 0, 'machines': 0, 'muscles': 0};
    }
  }

  Future<void> updateProgressStats({
    String? machineName,
    String? exerciseName,
    String? muscleName,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('users').doc(user.uid).collection('stats').doc('summary');

    try {
      final updates = <String, dynamic>{
        'last_updated': FieldValue.serverTimestamp(),
      };

      if (machineName != null) {
        updates['explored_machine_names'] = FieldValue.arrayUnion([machineName]);
      }
      
      if (exerciseName != null) {
        updates['learned_exercise_names'] = FieldValue.arrayUnion([exerciseName]);
      }

      if (muscleName != null && muscleName.isNotEmpty) {
        updates['muscle_scores.$muscleName'] = FieldValue.increment(1);
      }

      // Ensure document exists before updating (though set with merge handles it, explicit set helps with debugging)
      // We use set with merge: true which creates if not exists.
      await docRef.set(updates, SetOptions(merge: true));
      
      // Double check if we need to initialize counters if this was the first write
      // (Optional, but good for robustness)
    } catch (e) {
      print('Error updating progress stats: $e');
      // Rethrow so Cubit knows it failed? No, keep it safe.
    }
  }
}
