import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/storage/local_box_names.dart';
import '../models/step_log_model.dart';

class StepRepository {
  final Box _box = Hive.box(LocalBoxNames.stepLogs);
  final _uuid = const Uuid();

  /// Saves or updates step records for a unique YYYY-MM-DD date slot
  Future<void> saveSteps({
    required String logDate,
    required int steps,
    required String source,
    int? goalSteps,
    double? distanceKm,
    double? calories,
  }) async {
    final raw = _box.get(logDate);
    final now = DateTime.now();

    if (raw != null && raw is Map) {
      try {
        final current = StepLogModel.fromMap(Map<String, dynamic>.from(raw));
        final updated = current.copyWith(
          steps: steps,
          source: source,
          goalSteps: goalSteps ?? current.goalSteps,
          distanceKm: distanceKm ?? current.distanceKm,
          calories: calories ?? current.calories,
          updatedAt: now,
        );
        await _box.put(logDate, updated.toMap());
        return;
      } catch (_) {}
    }

    final fresh = StepLogModel(
      id: _uuid.v4(),
      logDate: logDate,
      steps: steps,
      goalSteps: goalSteps ?? 8000,
      source: source,
      distanceKm: distanceKm,
      calories: calories,
      createdAt: now,
      updatedAt: now,
    );
    await _box.put(logDate, fresh.toMap());
  }

  StepLogModel? getStepsByDate(String logDate) {
    final raw = _box.get(logDate);
    if (raw == null || raw is! Map) return null;
    try {
      return StepLogModel.fromMap(Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }
}
