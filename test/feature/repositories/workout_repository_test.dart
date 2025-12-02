import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/core/models/workout_entry.dart';
import 'package:flutter_application_1/feature/repositories/workout_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}
class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot<Map<String, dynamic>> {}
class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late WorkoutRepository repository;
  late MockCollectionReference mockUsersCollection;
  late MockDocumentReference mockUserDoc;
  late MockCollectionReference mockWorkoutsCollection;
  late MockDocumentReference mockWorkoutDoc;

  setUp(() {
    registerFallbackValue(<String, dynamic>{});
    
    mockFirestore = MockFirebaseFirestore();
    mockUsersCollection = MockCollectionReference();
    mockUserDoc = MockDocumentReference();
    mockWorkoutsCollection = MockCollectionReference();
    mockWorkoutDoc = MockDocumentReference();

    when(() => mockFirestore.collection('users')).thenReturn(mockUsersCollection);
    when(() => mockUsersCollection.doc(any())).thenReturn(mockUserDoc);
    when(() => mockUserDoc.collection('workouts')).thenReturn(mockWorkoutsCollection);
    when(() => mockWorkoutsCollection.doc(any())).thenReturn(mockWorkoutDoc);
    
    // Mock update on user doc
    when(() => mockUserDoc.update(any())).thenAnswer((_) async {});

    repository = WorkoutRepository(firestore: mockFirestore);
  });

  group('WorkoutRepository', () {
    final entry = WorkoutEntry(
      id: '1',
      machineId: 'm1',
      machineName: 'Bench Press',
      sets: 3,
      reps: 10,
      weight: 100.0,
      notes: 'Good set',
      timestamp: DateTime.now(),
    );

    test('logWorkout calls Firestore set', () async {
      when(() => mockWorkoutDoc.set(any())).thenAnswer((_) async {});

      await repository.logWorkout('user1', entry);

      verify(() => mockWorkoutDoc.set(any())).called(1);
      verify(() => mockUserDoc.update(any())).called(1);
    });
  });
}
