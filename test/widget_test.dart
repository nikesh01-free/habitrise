import 'package:flutter_test/flutter_test.dart';
import 'package:habitrise/features/focus/data/models/focus_session_model.dart';

void main() {
  group('Model Verification', () {
    test('FocusSessionModel serializes and deserializes correctly', () {
      final now = DateTime.now();
      final original = FocusSessionModel(
        id: 'test-id',
        category: 'work',
        plannedMinutes: 25,
        completedMinutes: 20,
        status: 'completed',
        startedAt: now,
        createdAt: now,
        updatedAt: now,
      );

      final map = original.toMap();
      final reconstructed = FocusSessionModel.fromMap(map);

      expect(reconstructed.id, equals(original.id));
      expect(reconstructed.category, equals(original.category));
      expect(reconstructed.completedMinutes, equals(original.completedMinutes));
      expect(reconstructed.status, equals(original.status));
    });
  });
}
