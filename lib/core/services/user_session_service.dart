import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_application_1/core/models/user_model.dart';

class UserSessionService with WidgetsBindingObserver {
  // Singleton
  static final UserSessionService _instance = UserSessionService._internal();
  static UserSessionService? _mockInstance;
  static UserSessionService get instance => _mockInstance ?? _instance;
  static set mockInstance(UserSessionService? mock) => _mockInstance = mock;

  UserSessionService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Public Stream/Notifier
  final ValueNotifier<UserModel?> currentUser = ValueNotifier<UserModel?>(null);

  StreamSubscription<User?>? _authSubscription;
  DateTime? _sessionStartTime;

  // Initialization
  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);
    _authSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _safeUpdateCurrentUser(UserModel? value) {
    if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        currentUser.value = value;
      });
    } else {
      currentUser.value = value;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _endSession();
    } else if (state == AppLifecycleState.resumed) {
      _sessionStartTime = DateTime.now();
    }
  }

  Future<void> _endSession() async {
    if (_sessionStartTime == null || currentUser.value == null) return;

    final duration = DateTime.now().difference(_sessionStartTime!);
    final minutes = duration.inMinutes;
    
    // Only log significant sessions (> 1 min)
    if (minutes > 0) {
      try {
        await _firestore.collection('users').doc(currentUser.value!.uid).update({
          'last_session_duration': minutes,
        });
        
        // Optimistic Update
        _safeUpdateCurrentUser(currentUser.value!.copyWith(lastSessionDuration: minutes));
      } catch (e) {
        debugPrint("Session Sync Error: $e");
      }
    }
    
    _sessionStartTime = null;
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _safeUpdateCurrentUser(null);
      return;
    }

    try {
      final userDocRef = _firestore.collection('users').doc(firebaseUser.uid);
      final docSnapshot = await userDocRef.get();

      if (!docSnapshot.exists) {
        // Self-Healing: Create new user doc
        final newUser = UserModel(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'GymRat User',
          email: firebaseUser.email,
          photoURL: firebaseUser.photoURL,
          joinDate: DateTime.now(),
          stats: {
            'explored_machine_names': [],
            'learned_exercise_names': [],
            'muscle_scores': {},
          },
          currentStreak: 1,
          lastVisitDate: DateTime.now(),
        );

        // Create in Firestore
        await userDocRef.set(newUser.toMap());
        
        // Update local state
        _safeUpdateCurrentUser(newUser);
        _sessionStartTime = DateTime.now(); // Start session
      } else {
        // Load existing user
        var userModel = UserModel.fromFirestore(docSnapshot);
        
        // --- Streak Logic ---
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final lastVisit = userModel.lastVisitDate;
        
        int newStreak = userModel.currentStreak;
        bool streakUpdated = false;

        if (lastVisit != null) {
          final lastVisitDate = DateTime(lastVisit.year, lastVisit.month, lastVisit.day);
          final difference = today.difference(lastVisitDate).inDays;

          if (difference == 1) {
            // Consecutive day
            newStreak++;
            streakUpdated = true;
          } else if (difference > 1) {
            // Streak broken
            newStreak = 1;
            streakUpdated = true;
          }
          // If difference == 0 (Same day), do nothing
        } else {
          // First visit ever (or legacy)
          newStreak = 1;
          streakUpdated = true;
        }

        if (streakUpdated) {
          await userDocRef.update({
            'current_streak': newStreak,
            'last_visit_date': FieldValue.serverTimestamp(),
          });
          userModel = userModel.copyWith(
            currentStreak: newStreak,
            lastVisitDate: now,
          );
        }
        // --------------------
        
        // Sync Auth Data if missing (Self-Healing 2.0)
        bool needsUpdate = false;
        final updates = <String, dynamic>{};

        if ((userModel.name == null || userModel.name!.isEmpty) && firebaseUser.displayName != null) {
          updates['name'] = firebaseUser.displayName;
          userModel = userModel.copyWith(name: firebaseUser.displayName);
          needsUpdate = true;
        }
        if ((userModel.photoURL == null || userModel.photoURL!.isEmpty) && firebaseUser.photoURL != null) {
          updates['photoURL'] = firebaseUser.photoURL;
          userModel = userModel.copyWith(photoURL: firebaseUser.photoURL);
          needsUpdate = true;
        }

        if (needsUpdate) {
          await userDocRef.update(updates);
        }
        
        // Sync Favorites Count (Self-Healing)
        if (userModel.favoritesCount == 0) {
          final favoritesSnapshot = await userDocRef.collection('favorites').count().get();
          final count = favoritesSnapshot.count ?? 0;
          if (count > 0) {
            await userDocRef.update({'favoritesCount': count});
            userModel = userModel.copyWith(favoritesCount: count);
          }
        }

        _safeUpdateCurrentUser(userModel);
        _sessionStartTime = DateTime.now(); // Start session
        
        // Check for legacy stats if current stats are empty (Migration)
        if (userModel.stats.isEmpty || (userModel.stats['explored_machine_names'] as List?)?.isEmpty == true) {
           _migrateLegacyStats(firebaseUser.uid, userDocRef);
        }
      }
    } catch (e) {
      debugPrint("UserSessionService Error: $e");
    }
  }

  Future<void> _migrateLegacyStats(String uid, DocumentReference userDocRef) async {
    try {
      // Try to fetch old stats/summary
      final oldStatsDoc = await _firestore.collection('users').doc(uid).collection('stats').doc('summary').get();
      if (oldStatsDoc.exists && oldStatsDoc.data() != null) {
        final data = oldStatsDoc.data()!;
        // Merge into main user doc
        await userDocRef.set({
          'stats': {
             'explored_machine_names': data['explored_machine_names'] ?? [],
             'learned_exercise_names': data['learned_exercise_names'] ?? [],
             'muscle_scores': data['muscle_scores'] ?? {},
          }
        }, SetOptions(merge: true));
        
        // Refresh local user
        final refreshedDoc = await userDocRef.get();
        _safeUpdateCurrentUser(UserModel.fromFirestore(refreshedDoc));
      }
    } catch (e) {
      debugPrint("Migration Error: $e");
    }
  }

  // Centralized Tracking
  Future<void> logProgress({
    String? machineName,
    String? exerciseName,
    String? muscleName,
  }) async {
    final user = currentUser.value;
    if (user == null) return;

    // 1. Optimistic Update
    final currentStats = Map<String, dynamic>.from(user.stats);
    
    // Update Lists
    final machines = List<String>.from(currentStats['explored_machine_names'] ?? []);
    if (machineName != null && !machines.contains(machineName)) {
      machines.add(machineName);
    }
    
    final exercises = List<String>.from(currentStats['learned_exercise_names'] ?? []);
    if (exerciseName != null && !exercises.contains(exerciseName)) {
      exercises.add(exerciseName);
    }

    // Update Map
    final muscleScores = Map<String, dynamic>.from(currentStats['muscle_scores'] ?? {});
    if (muscleName != null) {
      muscleScores[muscleName] = (muscleScores[muscleName] ?? 0) + 1;
    }

    currentStats['explored_machine_names'] = machines;
    currentStats['learned_exercise_names'] = exercises;
    currentStats['muscle_scores'] = muscleScores;

    // --- Recent History Logic (Limit 3) ---
    final recent = List<Map<String, String>>.from(user.recentActivity);
    
    if (machineName != null || exerciseName != null) {
      final name = machineName ?? exerciseName!;
      final type = machineName != null ? 'Machine' : 'Exercise';
      
      // Deduplicate: Remove if exists
      recent.removeWhere((item) => item['name'] == name);
      
      // Insert at Top
      recent.insert(0, {'name': name, 'type': type});
      
      // Trim to 3
      if (recent.length > 3) {
        recent.removeRange(3, recent.length);
      }
    }
    // --------------------------------------

    // Emit new state immediately
    _safeUpdateCurrentUser(user.copyWith(
      stats: currentStats,
      recentActivity: recent,
    ));

    // 2. Background Sync
    try {
      final userDocRef = _firestore.collection('users').doc(user.uid);
      final updates = <String, dynamic>{
        'lastActive': FieldValue.serverTimestamp(),
        'recent_activity': recent, // Overwrite with new list
      };

      if (machineName != null) {
        updates['stats.explored_machine_names'] = FieldValue.arrayUnion([machineName]);
      }
      if (exerciseName != null) {
        updates['stats.learned_exercise_names'] = FieldValue.arrayUnion([exerciseName]);
      }
      if (muscleName != null) {
        updates['stats.muscle_scores.$muscleName'] = FieldValue.increment(1);
      }

      await userDocRef.update(updates);
    } catch (e) {
      debugPrint("LogProgress Sync Error: $e");
      // Revert optimistic update? 
      // For now, we assume eventual consistency or next fetch will fix it.
      // Ideally, we might want to reload from server on error.
    }
  }
  
  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? photoURL,
    String? username,
    int? weight,
    int? height,
    int? age,
  }) async {
    final user = currentUser.value;
    if (user == null) return;

    // Optimistic Update
    _safeUpdateCurrentUser(user.copyWith(
      name: name ?? user.name,
      email: email ?? user.email,
      photoURL: photoURL ?? user.photoURL,
      username: username ?? user.username,
      weight: weight ?? user.weight,
      height: height ?? user.height,
      age: age ?? user.age,
    ));

    // Firestore Update
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (email != null) updates['email'] = email;
      if (photoURL != null) updates['photoURL'] = photoURL;
      if (username != null) updates['username'] = username;
      if (weight != null) updates['weight'] = weight;
      if (height != null) updates['height'] = height;
      if (age != null) updates['age'] = age;

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).update(updates);
      }
      
      // Also update Auth if needed (e.g. displayName/photoURL)
      if (name != null) await _auth.currentUser?.updateDisplayName(name);
      if (photoURL != null) await _auth.currentUser?.updatePhotoURL(photoURL);
      
    } catch (e) {
      debugPrint("Update Profile Error: $e");
      // Revert optimistic update if needed, or just log error
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription?.cancel();
    currentUser.dispose();
  }
}
