import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/models/progress_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  test('ProgressModel serialization test', () {
    final now = DateTime.now();
    final model = ProgressModel(
      userId: 'test_user',
      exerciseId: 'ex_123',
      completedAt: now,
      bodyPartId: 'chest',
    );

    final map = model.toMap();

    expect(map['userId'], 'test_user');
    expect(map['exerciseId'], 'ex_123');
    expect(map['bodyPartId'], 'chest');
    expect(map['completedAt'], isA<Timestamp>());
  });
}
