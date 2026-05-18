import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/storage/local_box_names.dart';
import '../models/water_log_model.dart';

class WaterRepository {
  final Box _box = Hive.box(LocalBoxNames.waterLogs);
  final _uuid = const Uuid();

  Future<WaterLogModel> addLog(int amountMl, DateTime time) async {
    final id = _uuid.v4();
    final dateStr =
        '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}';

    final log = WaterLogModel(
      id: id,
      logDate: dateStr,
      amountMl: amountMl,
      entryTime: time,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _box.put(id, log.toMap());
    return log;
  }

  List<WaterLogModel> getLogsForDate(String logDate) {
    final List<WaterLogModel> results = [];
    for (final val in _box.values) {
      try {
        if (val is Map) {
          final log = WaterLogModel.fromMap(Map<String, dynamic>.from(val));
          if (log.logDate == logDate) results.add(log);
        }
      } catch (_) {
        // Log skip
      }
    }
    return results;
  }

  int getTotalMlForDate(String logDate) {
    final logs = getLogsForDate(logDate);
    return logs.fold(0, (sum, log) => sum + log.amountMl);
  }

  Future<void> deleteLog(String id) async {
    await _box.delete(id);
  }
}
