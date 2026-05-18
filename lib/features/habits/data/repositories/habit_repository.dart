import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/storage/local_box_names.dart';
import '../models/habit_model.dart';
import '../models/habit_log_model.dart';

class HabitRepository {
  final Box _habitBox = Hive.box(LocalBoxNames.habits);
  final Box _logBox = Hive.box(LocalBoxNames.habitLogs);
  final _uuid = const Uuid();

  Future<HabitModel> createHabit({
    required String title,
    required String category,
    required String type,
    required String frequency,
    required String colorHex,
    double? targetValue,
    String? unit,
    String? icon,
    bool reminderEnabled = false,
    String? reminderTime,
  }) async {
    final now = DateTime.now();
    final habit = HabitModel(
      id: _uuid.v4(),
      title: title,
      category: category,
      type: type,
      frequency: frequency,
      colorHex: colorHex,
      targetValue: targetValue,
      unit: unit,
      icon: icon,
      reminderEnabled: reminderEnabled,
      reminderTime: reminderTime,
      createdAt: now,
      updatedAt: now,
    );

    await _habitBox.put(habit.id, habit.toMap());
    return habit;
  }

  List<HabitModel> getAllActiveHabits() {
    final List<HabitModel> active = [];
    for (final val in _habitBox.values) {
      try {
        if (val is Map) {
          final h = HabitModel.fromMap(Map<String, dynamic>.from(val));
          if (!h.isArchived) active.add(h);
        }
      } catch (_) {
        // Skip corrupted data gracefully
      }
    }
    return active;
  }

  Future<void> updateHabit(HabitModel updatedHabit) async {
    final h = updatedHabit.copyWith(updatedAt: DateTime.now());
    await _habitBox.put(h.id, h.toMap());
  }

  Future<void> archiveHabit(String id) async {
    final raw = _habitBox.get(id);
    if (raw != null && raw is Map) {
      try {
        final habit = HabitModel.fromMap(Map<String, dynamic>.from(raw));
        final archived = habit.copyWith(
          isArchived: true,
          updatedAt: DateTime.now(),
        );
        await _habitBox.put(id, archived.toMap());
      } catch (_) {
        // Handle recovery gracefully
      }
    }
  }

  Future<void> deleteHabit(String id) async {
    await _habitBox.delete(id);
    final logsKeysToDelete = _logBox.keys
        .where((k) => k.toString().startsWith('${id}_'))
        .toList();
    for (final key in logsKeysToDelete) {
      await _logBox.delete(key);
    }
  }

  Future<HabitLogModel> logHabit({
    required String habitId,
    required String logDate,
    required String status,
    double? completedValue,
  }) async {
    final key = '${habitId}_$logDate';
    final now = DateTime.now();

    final log = HabitLogModel(
      id: _uuid.v4(),
      habitId: habitId,
      logDate: logDate,
      status: status,
      completedValue: completedValue,
      createdAt: now,
      updatedAt: now,
    );

    await _logBox.put(key, log.toMap());
    return log;
  }

  List<HabitLogModel> getLogsForDate(String date) {
    final List<HabitLogModel> results = [];
    for (final val in _logBox.values) {
      try {
        if (val is Map) {
          final log = HabitLogModel.fromMap(Map<String, dynamic>.from(val));
          if (log.logDate == date) results.add(log);
        }
      } catch (_) {
        // Skip corrupted log peacefully
      }
    }
    return results;
  }
}
