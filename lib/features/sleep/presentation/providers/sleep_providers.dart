import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/sleep_log_model.dart';
import '../../data/repositories/sleep_repository.dart';

final sleepRepositoryProvider = Provider<SleepRepository>((ref) {
  return SleepRepository();
});

class TodaySleepNotifier extends AutoDisposeNotifier<SleepLogModel?> {
  @override
  SleepLogModel? build() {
    final repo = ref.read(sleepRepositoryProvider);
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return repo.getSleepByDate(dateStr);
  }

  Future<void> logSleep({
    required DateTime sleepTime,
    required DateTime wakeTime,
    required String quality,
  }) async {
    // Validation: Must differ. Note: user might sleep late after midnight.
    final difference = wakeTime.difference(sleepTime);
    final mins = difference.inMinutes;

    if (mins <= 0) {
      throw Exception('Wake time must be after sleep time.');
    }

    if (mins < 60 || mins > (16 * 60)) {
      throw Exception('Sleep duration must be between 1 and 16 hours.');
    }

    final repo = ref.read(sleepRepositoryProvider);
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final log = SleepLogModel(
      id: state?.id ?? const Uuid().v4(),
      sleepDate: dateStr,
      sleepTime: sleepTime,
      wakeTime: wakeTime,
      totalMinutes: mins,
      quality: quality,
      createdAt: state?.createdAt ?? now,
      updatedAt: now,
    );

    await repo.saveSleep(log);

    // Force refresh
    state = log;
  }

  Future<void> deleteCurrentSleep() async {
    if (state == null) return;
    final repo = ref.read(sleepRepositoryProvider);
    await repo.deleteSleep(state!.id);
    state = null;
  }
}

final todaySleepProvider =
    AutoDisposeNotifierProvider<TodaySleepNotifier, SleepLogModel?>(() {
      return TodaySleepNotifier();
    });
