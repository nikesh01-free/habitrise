import 'package:hive/hive.dart';
import '../../../../core/storage/local_box_names.dart';
import '../models/sleep_log_model.dart';

class SleepRepository {
  final Box _box = Hive.box(LocalBoxNames.sleepLogs);

  SleepLogModel? getSleepByDate(String dateStr) {
    for (final val in _box.values) {
      try {
        if (val is Map && val['sleepDate'] == dateStr) {
          return SleepLogModel.fromMap(Map<String, dynamic>.from(val));
        }
      } catch (_) {}
    }
    return null;
  }

  Future<void> saveSleep(SleepLogModel sleep) async {
    dynamic targetKey;
    for (final key in _box.keys) {
      final val = _box.get(key);
      if (val is Map && val['sleepDate'] == sleep.sleepDate) {
        targetKey = key;
        break;
      }
    }

    if (targetKey != null) {
      await _box.put(targetKey, sleep.toMap());
    } else {
      await _box.put(sleep.id, sleep.toMap());
    }
  }

  List<SleepLogModel> getAllSleepLogs() {
    final List<SleepLogModel> logs = [];
    for (final val in _box.values) {
      try {
        if (val is Map) {
          logs.add(SleepLogModel.fromMap(Map<String, dynamic>.from(val)));
        }
      } catch (_) {}
    }
    return logs;
  }

  Future<void> deleteSleep(String id) async {
    await _box.delete(id);
  }
}
