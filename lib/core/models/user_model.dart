import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? name;
  final String? email;
  final String? photoURL;
  final DateTime? joinDate;
  final Map<String, dynamic> stats;
  final List<Map<String, String>> recentActivity;
  final int favoritesCount;
  final List<String> favoriteIds;
  final int currentStreak;
  final DateTime? lastVisitDate;
  final String? username;
  final int? weight;
  final int? height;
  final int? age;
  final int lastSessionDuration; // in minutes

  UserModel({
    required this.uid,
    this.name,
    this.email,
    this.photoURL,
    this.joinDate,
    this.stats = const {},
    this.recentActivity = const [],
    this.favoritesCount = 0,
    this.favoriteIds = const [],
    this.currentStreak = 0,
    this.lastVisitDate,
    this.username,
    this.weight,
    this.height,
    this.age,
    this.lastSessionDuration = 0,
  });

  // Derived Stats
  int get exploredMachinesCount {
    final list = stats['explored_machine_names'];
    return (list is List) ? list.length : 0;
  }

  int get studiedMusclesCount {
    final list = stats['studied_muscle_names'];
    return (list is List) ? list.length : 0;
  }

  // --- FACTORY WITH SAFE PARSING ---
  factory UserModel.fromFirestore(DocumentSnapshot doc, {Map<String, dynamic>? statsData, List<String>? favorites}) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    // Priority: Passed statsData (from summary doc) -> User doc stats -> Empty
    final mergedStats = statsData ?? (data['stats'] as Map<String, dynamic>? ?? {});

    return UserModel(
      uid: doc.id,
      name: data['name'] as String?,
      email: data['email'] as String?,
      photoURL: data['photoURL'] as String?,
      joinDate: _toDate(data['createdAt']),
      stats: mergedStats,
      recentActivity: _parseRecentActivity(data['recent_activity']),
      favoritesCount: _toInt(data['favoritesCount']),
      favoriteIds: favorites ?? [],
      currentStreak: _toInt(data['current_streak']),
      lastVisitDate: _toDate(data['last_visit_date']),
      username: data['username'] as String?,
      weight: _toInt(data['weight']),
      height: _toInt(data['height']),
      age: _toInt(data['age']),
      lastSessionDuration: _toInt(data['last_session_duration']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoURL': photoURL,
      'createdAt': joinDate != null ? Timestamp.fromDate(joinDate!) : null,
      'stats': stats,
      'recent_activity': recentActivity,
      'favoritesCount': favoritesCount,
      'current_streak': currentStreak,
      'last_visit_date': lastVisitDate != null ? Timestamp.fromDate(lastVisitDate!) : null,
      'username': username,
      'weight': weight,
      'height': height,
      'age': age,
      'last_session_duration': lastSessionDuration,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? photoURL,
    DateTime? joinDate,
    Map<String, dynamic>? stats,
    List<Map<String, String>>? recentActivity,
    int? favoritesCount,
    List<String>? favoriteIds,
    int? currentStreak,
    DateTime? lastVisitDate,
    String? username,
    int? weight,
    int? height,
    int? age,
    int? lastSessionDuration,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      joinDate: joinDate ?? this.joinDate,
      stats: stats ?? this.stats,
      recentActivity: recentActivity ?? this.recentActivity,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      currentStreak: currentStreak ?? this.currentStreak,
      lastVisitDate: lastVisitDate ?? this.lastVisitDate,
      username: username ?? this.username,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      age: age ?? this.age,
      lastSessionDuration: lastSessionDuration ?? this.lastSessionDuration,
    );
  }

  // --- HELPERS FOR SAFE PARSING ---
  
  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static List<Map<String, String>> _parseRecentActivity(dynamic value) {
    if (value is List) {
      return value.map((e) {
        if (e is Map) {
          // Force all values to be Strings to match Map<String, String>
          return e.map((key, val) => MapEntry(key.toString(), val.toString()));
        }
        return <String, String>{};
      }).toList();
    }
    return [];
  }
}