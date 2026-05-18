import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/storage/local_box_names.dart';
import '../models/mood_log_model.dart';

class MoodRepository {
  final Box _box = Hive.box(LocalBoxNames.moodLogs);
  final _uuid = const Uuid();

  Future<void> logMood({
    required String logDate,
    required String mood,
    String? note,
  }) async {
    // Mood is typically 1 entry per day, stored by logDate as key
    final raw = _box.get(logDate);
    final now = DateTime.now();

    if (raw != null && raw is Map) {
      try {
        final current = MoodLogModel.fromMap(Map<String, dynamic>.from(raw));
        final updated = current.copyWith(
          mood: mood,
          note: note,
          updatedAt: now,
        );
        await _box.put(logDate, updated.toMap());
        return;
      } catch (_) {}
    }

    final fresh = MoodLogModel(
      id: _uuid.v4(),
      logDate: logDate,
      mood: mood,
      note: note,
      createdAt: now,
      updatedAt: now,
    );
    await _box.put(logDate, fresh.toMap());
  }

  MoodLogModel? getMoodForDate(String date) {
    final raw = _box.get(date);
    if (raw == null || raw is! Map) return null;
    try {
      return MoodLogModel.fromMap(Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }
}
