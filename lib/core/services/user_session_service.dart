import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/core/models/user_model.dart';
import 'package:flutter_application_1/core/models/progress_model.dart';

class UserSessionService with WidgetsBindingObserver {
  static final UserSessionService _instance = UserSessionService._internal();
  static UserSessionService get instance => _instance;

  UserSessionService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final StreamController<UserModel?> _userSubject = StreamController<UserModel?>.broadcast();
  Stream<UserModel?> get userStream => _userSubject.stream;
  
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  
  List<String> get favoriteIds => _currentUser?.favoriteIds ?? [];

  StreamSubscription<User?>? _authSubscription;
  DateTime? _sessionStartTime;
  bool _isLoading = false;

  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);
    _authSubscription = _auth.authStateChanges().listen(_initializeUser);
    if (_auth.currentUser != null) {
      await _initializeUser(_auth.currentUser);
    }
  }

  Future<void> refreshUser() async {
    if (_auth.currentUser != null) {
      await _initializeUser(_auth.currentUser);
    }
  }

  void _safeUpdateCurrentUser(UserModel? value) {
    _currentUser = value;
    _userSubject.add(value);
  }

  String _sanitize(String input) {
    if (input.isEmpty) return "Unknown";
    final trimmed = input.trim();
    if (trimmed.isEmpty) return "Unknown";
    return "${trimmed[0].toUpperCase()}${trimmed.substring(1).toLowerCase()}";
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
    if (_sessionStartTime == null || _currentUser == null) return;
    final duration = DateTime.now().difference(_sessionStartTime!);
    final minutes = duration.inMinutes;
    
    if (minutes > 0) {
      try {
        await _firestore.collection('users').doc(_currentUser!.uid).update({
          'last_session_duration': minutes,
        });
        _safeUpdateCurrentUser(_currentUser!.copyWith(lastSessionDuration: minutes));
      } catch (e) {
        debugPrint("Session Sync Error: $e");
      }
    }
    _sessionStartTime = null;
  }

  Future<void> _initializeUser(User? firebaseUser) async {
    if (_isLoading) return;
    _isLoading = true;

    if (firebaseUser == null) {
      _safeUpdateCurrentUser(null);
      _isLoading = false;
      return;
    }

    try {
      final userDocRef = _firestore.collection('users').doc(firebaseUser.uid);
      
      // 1. Fetch ALL Data
      final userDocSnapshot = await userDocRef.get();
      final statsDocSnapshot = await userDocRef.collection('stats').doc('summary').get();
      final statsData = statsDocSnapshot.exists ? statsDocSnapshot.data() : <String, dynamic>{};

      // 2. Fetch Favorites (THE TRUTH SOURCE)
      final favoritesSnapshot = await userDocRef.collection('favorites').get();
      final favoriteIds = favoritesSnapshot.docs.map((doc) => doc.id).toList();
      
      // *** CRITICAL FIX: Trust the list length, NOT the old counter ***
      final realFavoritesCount = favoriteIds.length;

      UserModel userModel;
      if (!userDocSnapshot.exists) {
        // Create New User
        userModel = UserModel(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'GymRat User',
          email: firebaseUser.email,
          joinDate: DateTime.now(),
          stats: statsData ?? {},
          favoritesCount: realFavoritesCount, // Use Real Count
          favoriteIds: favoriteIds,
          currentStreak: 1,
          lastVisitDate: DateTime.now(),
        );
        await userDocRef.set(userModel.toMap());

        if (!statsDocSnapshot.exists) {
           await userDocRef.collection('stats').doc('summary').set({
             'explored_machine_names': [],
             'studied_muscle_names': [],
             'exercises_learned': [],
             'muscle_scores': {},
             'total_workouts': 0,
           });
        }
      } else {
        // Load Existing User
        userModel = UserModel.fromFirestore(
          userDocSnapshot, 
          statsData: statsData,
          favorites: favoriteIds,
        );
        
        // *** FORCE SYNC: Override the DB counter with the actual list length ***
        userModel = userModel.copyWith(favoritesCount: realFavoritesCount);

        // Streak Logic
        final now = DateTime.now();
        final lastVisit = userModel.lastVisitDate ?? now;
        final difference = DateTime(now.year, now.month, now.day)
            .difference(DateTime(lastVisit.year, lastVisit.month, lastVisit.day))
            .inDays;

        if (difference == 1) {
          userModel = userModel.copyWith(currentStreak: userModel.currentStreak + 1, lastVisitDate: now);
        } else if (difference > 1) {
          userModel = userModel.copyWith(currentStreak: 1, lastVisitDate: now);
        } else {
          userModel = userModel.copyWith(lastVisitDate: now);
        }
        
        await userDocRef.update({
          'current_streak': userModel.currentStreak,
          'last_visit_date': userModel.lastVisitDate!.toIso8601String(),
          'favoritesCount': realFavoritesCount, // Self-heal the DB
        });
      }

      _safeUpdateCurrentUser(userModel);
      _sessionStartTime = DateTime.now();

    } catch (e) {
      debugPrint("UserSessionService Init Error: $e");
      if (_currentUser == null) {
         _safeUpdateCurrentUser(UserModel(
            uid: firebaseUser.uid,
            name: firebaseUser.displayName ?? 'User',
            stats: {},
            favoritesCount: 0,
            favoriteIds: [],
            currentStreak: 1,
         ));
      }
    } finally {
      _isLoading = false;
    }
  }

  // --- LOGIC METHODS ---

  Future<void> toggleFavorite(String machineId) async {
    final user = _currentUser;
    if (user == null) return;

    final isFavorite = user.favoriteIds.contains(machineId);
    final userDocRef = _firestore.collection('users').doc(user.uid);
    final favoritesRef = userDocRef.collection('favorites');

    List<String> newFavoriteIds = List.from(user.favoriteIds);

    // 1. Update the List
    if (isFavorite) {
      newFavoriteIds.remove(machineId);
    } else {
      if (!newFavoriteIds.contains(machineId)) {
        newFavoriteIds.add(machineId);
      }
    }

    // 2. Calculate Count from List (MATH FIX)
    final newCount = newFavoriteIds.length; // NEVER use -- or ++

    // 3. Optimistic Update
    _safeUpdateCurrentUser(user.copyWith(
      favoriteIds: newFavoriteIds,
      favoritesCount: newCount,
    ));

    try {
      if (isFavorite) {
        await favoritesRef.doc(machineId).delete();
      } else {
        await favoritesRef.doc(machineId).set({'addedAt': FieldValue.serverTimestamp()});
      }
      
      // Sync Count to DB
      await userDocRef.update({'favoritesCount': newCount});
      
    } catch (e) {
      debugPrint("Toggle Favorite Error: $e");
      _safeUpdateCurrentUser(user); // Revert on error
    }
  }

  Future<void> logProgress({
    required String exerciseId, 
    required String bodyPartId, 
    required String machineName,
    String? muscleName,
    String? machineId,
    String? imageUrl, // Added parameter
  }) async {
    final current = _currentUser;
    if (current == null) return;

    final cleanMachine = _sanitize(machineName);
    final cleanMuscle = muscleName != null ? _sanitize(muscleName) : null;

    // A. UNIQUE TRACKING
    final exploredMachines = Set<String>.from(current.stats['explored_machine_names'] ?? []);
    final studiedMuscles = Set<String>.from(current.stats['studied_muscle_names'] ?? []);
    final learnedExercises = Set<String>.from(current.stats['exercises_learned'] ?? []);

    exploredMachines.add(cleanMachine);
    learnedExercises.add(exerciseId);
    if (cleanMuscle != null) studiedMuscles.add(cleanMuscle);

    // B. SCORES
    final muscleScores = Map<String, dynamic>.from(current.stats['muscle_scores'] ?? {});
    if (cleanMuscle != null) {
      muscleScores[cleanMuscle] = (muscleScores[cleanMuscle] ?? 0) + 1;
    }

    // C. HISTORY
    final recent = List<Map<String, String>>.from(current.recentActivity);
    recent.removeWhere((item) => item['name'] == cleanMachine);
    recent.insert(0, {
      'id': machineId ?? exerciseId, // Save ID for navigation
      'name': cleanMachine,
      'type': 'Machine',
      'date': DateTime.now().toIso8601String(),
      'image': imageUrl ?? "",
    });
    if (recent.length > 3) recent.removeLast();

    final updatedStats = {
      'explored_machine_names': exploredMachines.toList(),
      'studied_muscle_names': studiedMuscles.toList(),
      'exercises_learned': learnedExercises.toList(),
      'muscle_scores': muscleScores,
      'total_workouts': (current.stats['total_workouts'] ?? 0) + 1,
    };

    _safeUpdateCurrentUser(current.copyWith(stats: updatedStats, recentActivity: recent));

    // D. FIRESTORE SAVE
    final progressRef = _firestore.collection('progress').doc();
    final progressEntry = ProgressModel(
      userId: current.uid,
      exerciseId: exerciseId,
      completedAt: DateTime.now(),
      bodyPartId: bodyPartId,
    );

    try {
      await progressRef.set(progressEntry.toMap());
      final statsRef = _firestore.collection('users').doc(current.uid).collection('stats').doc('summary');
      
      final updates = <String, dynamic>{
        'explored_machine_names': FieldValue.arrayUnion([cleanMachine]),
        'exercises_learned': FieldValue.arrayUnion([exerciseId]),
        'total_workouts': FieldValue.increment(1),
        'last_visit_date': FieldValue.serverTimestamp(),
      };

      String? targetMuscleName = cleanMuscle;
      if (targetMuscleName == null) {
         final exerciseDoc = await _firestore.collection('exercises').doc(exerciseId).get();
         if (exerciseDoc.exists) {
           final mId = exerciseDoc.data()?['muscleId'];
           if (mId != null) {
             final mDoc = await _firestore.collection('muscles').doc(mId).get();
             final mName = mDoc.data()?['name'];
             if (mName is String) targetMuscleName = _sanitize(mName);
             else if (mName is Map) targetMuscleName = _sanitize(mName['en']);
           }
         }
      }

      if (targetMuscleName != null) {
        updates['muscle_scores.$targetMuscleName'] = FieldValue.increment(1);
        updates['studied_muscle_names'] = FieldValue.arrayUnion([targetMuscleName]);
      }

      await statsRef.set(updates, SetOptions(merge: true));
      await _firestore.collection('users').doc(current.uid).update({'recent_activity': recent});

    } catch (e) {
      debugPrint("Log Error: $e");
    }
  }

  Future<void> updateUserProfile({String? name, String? email, String? photoURL, String? username, int? weight, int? height, int? age}) async {
    final user = _currentUser;
    if (user == null) return;

    _safeUpdateCurrentUser(user.copyWith(name: name, email: email, photoURL: photoURL, username: username, weight: weight, height: height, age: age));

    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (email != null) updates['email'] = email;
      if (photoURL != null) updates['photoURL'] = photoURL;
      if (username != null) updates['username'] = username;
      if (weight != null) updates['weight'] = weight;
      if (height != null) updates['height'] = height;
      if (age != null) updates['age'] = age;

      if (updates.isNotEmpty) await _firestore.collection('users').doc(user.uid).update(updates);
    } catch (e) { debugPrint("Update Error: $e"); }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription?.cancel();
    _userSubject.close();
  }
}