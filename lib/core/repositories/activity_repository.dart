import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/core/models/activity_log.dart';
import 'package:intl/intl.dart';

class ActivityRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ActivityRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<void> logActivity({
    String? bodyPart,
    String? muscle,
    String? machine,
    String? exercise,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).collection('activity').add({
        'timestamp': FieldValue.serverTimestamp(),
        'bodyPart': bodyPart,
        'muscle': muscle,
        'machine': machine,
        'exercise': exercise,
      });
    } catch (e) {
      print('Error logging activity: $e');
    }
  }

  Future<void> updateDailyStreak() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final today = DateFormat('yyyyMMdd').format(DateTime.now());
    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('dailyOpen')
        .doc(today);

    try {
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        await docRef.set({
          'opened': true,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error updating daily streak: $e');
    }
  }

  Future<List<ActivityLog>> fetchActivityLogs() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('activity')
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      if (snapshot.docs.isEmpty) return [];

      return snapshot.docs.map((doc) => ActivityLog.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching activity logs: $e');
      return [];
    }
  }

  Future<int> calculateStreak() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('dailyOpen')
          .orderBy(FieldPath.documentId, descending: true)
          .limit(30)
          .get();

      final docs = snapshot.docs;
      if (docs.isEmpty) return 0;

      int streak = 0;
      final today = DateTime.now();
      final todayStr = DateFormat('yyyyMMdd').format(today);
      
      // Check if today is logged
      bool todayLogged = docs.any((doc) => doc.id == todayStr);
      
      DateTime checkDate = today;
      
      // If today is not logged, start checking from yesterday
      if (!todayLogged) {
         checkDate = checkDate.subtract(const Duration(days: 1));
      }

      for (int i = 0; i < 30; i++) {
        final dateStr = DateFormat('yyyyMMdd').format(checkDate);
        final hasEntry = docs.any((doc) => doc.id == dateStr);
        
        if (hasEntry) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
      return streak;
    } catch (e) {
      print('Error calculating streak: $e');
      return 0;
    }
  }
}
