import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/storage/local_box_names.dart';
import '../models/gym_schedule_model.dart';
import '../models/gym_workout_log_model.dart';

class GymRepository {
  Box get _scheduleBox => Hive.box(LocalBoxNames.gymSchedule);
  Box get _logsBox => Hive.box(LocalBoxNames.gymWorkoutLogs);

  // --- Schedule Management ---

  List<GymScheduleModel> getAllSchedules() {
    final raw = _scheduleBox.values;
    return raw.map((e) {
      final Map<dynamic, dynamic> map = Map<dynamic, dynamic>.from(e as Map);
      return GymScheduleModel.fromMap(map);
    }).toList();
  }

  GymScheduleModel? getScheduleForDay(String dayName) {
    final all = getAllSchedules();
    for (final s in all) {
      if (s.dayOfWeek.toLowerCase() == dayName.toLowerCase()) {
        return s;
      }
    }
    return null;
  }

  Future<void> saveSchedule(GymScheduleModel schedule) async {
    await _scheduleBox.put(schedule.id, schedule.toMap());
  }

  Future<void> deleteSchedule(String id) async {
    await _scheduleBox.delete(id);
  }

  // --- Workout Logs Management ---

  List<GymWorkoutLogModel> getAllLogs() {
    final raw = _logsBox.values;
    return raw.map((e) {
      final Map<dynamic, dynamic> map = Map<dynamic, dynamic>.from(e as Map);
      return GymWorkoutLogModel.fromMap(map);
    }).toList();
  }

  List<GymWorkoutLogModel> getLogsForDate(String dateIso) {
    final all = getAllLogs();
    return all.where((l) => l.completedDate == dateIso).toList();
  }

  Future<void> saveWorkoutLog(GymWorkoutLogModel log) async {
    await _logsBox.put(log.id, log.toMap());
  }

  Future<void> deleteWorkoutLog(String id) async {
    await _logsBox.delete(id);
  }
}
