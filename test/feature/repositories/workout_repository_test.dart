import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/core/models/workout_entry.dart';
import 'package:flutter_application_1/core/services/firestore_service.dart';
import 'package:flutter_application_1/feature/repositories/workout_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirestoreService extends Mock implements FirestoreService {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late MockFirestoreService mockFirestoreService;
  late WorkoutRepository repository;
  late MockDocumentReference mockDocumentReference;

  setUp(() {
    registerFallbackValue(<String, dynamic>{});
    
    mockFirestoreService = MockFirestoreService();
    mockDocumentReference = MockDocumentReference();

    repository = WorkoutRepository(firestoreService: mockFirestoreService);
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

    test('logWorkout calls FirestoreService setDocument and updateDocument', () async {
      when(() => mockFirestoreService.setDocument(
            path: any(named: 'path'),
            docId: any(named: 'docId'),
            data: any(named: 'data'),
          )).thenAnswer((_) async {});

      when(() => mockFirestoreService.updateDocument(
            path: any(named: 'path'),
            docId: any(named: 'docId'),
            data: any(named: 'data'),
          )).thenAnswer((_) async {});

      await repository.logWorkout('user1', entry);

      verify(() => mockFirestoreService.setDocument(
            path: 'users/user1/workouts',
            docId: entry.id,
            data: entry.toMap(),
          )).called(1);

      verify(() => mockFirestoreService.updateDocument(
            path: 'users',
            docId: 'user1',
            data: any(named: 'data'),
          )).called(1);
    });
  });
}
