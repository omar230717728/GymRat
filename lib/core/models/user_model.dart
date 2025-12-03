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
    this.currentStreak = 0,
    this.lastVisitDate,
    this.username,
    this.weight,
    this.height,
    this.age,

    this.lastSessionDuration = 0,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    return UserModel(
      uid: doc.id,
      name: data['name'],
      email: data['email'],
      photoURL: data['photoURL'],
      joinDate: (data['createdAt'] as Timestamp?)?.toDate(),
      stats: data['stats'] as Map<String, dynamic>? ?? {},
      recentActivity: (data['recent_activity'] as List?)
          ?.map((e) => Map<String, String>.from(e as Map))
          .toList() ?? [],
      favoritesCount: data['favoritesCount'] as int? ?? 0,
      currentStreak: data['current_streak'] as int? ?? 0,
      lastVisitDate: (data['last_visit_date'] as Timestamp?)?.toDate(),
      username: data['username'],
      weight: (data['weight'] as num?)?.toInt(),
      height: (data['height'] as num?)?.toInt(),
      age: (data['age'] as num?)?.toInt(),

      lastSessionDuration: data['last_session_duration'] as int? ?? 0,
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
      currentStreak: currentStreak ?? this.currentStreak,
      lastVisitDate: lastVisitDate ?? this.lastVisitDate,
      username: username ?? this.username,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      age: age ?? this.age,

      lastSessionDuration: lastSessionDuration ?? this.lastSessionDuration,
    );
  }
}
