import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/water_repository.dart';
import '../../data/models/water_log_model.dart';

final waterRepositoryProvider = Provider<WaterRepository>((ref) {
  return WaterRepository();
});

class TodayWaterLogsNotifier
    extends AutoDisposeAsyncNotifier<List<WaterLogModel>> {
  @override
  Future<List<WaterLogModel>> build() async {
    final repo = ref.watch(waterRepositoryProvider);
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return repo.getLogsForDate(dateStr);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(waterRepositoryProvider);
      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      return repo.getLogsForDate(dateStr);
    });
  }
}

final todayWaterLogsProvider =
    AsyncNotifierProvider.autoDispose<
      TodayWaterLogsNotifier,
      List<WaterLogModel>
    >(() {
      return TodayWaterLogsNotifier();
    });

final todayWaterTotalProvider = Provider.autoDispose<int>((ref) {
  final logsAsync = ref.watch(todayWaterLogsProvider);
  return logsAsync.maybeWhen(
    data: (logs) => logs.fold(0, (sum, log) => sum + log.amountMl),
    orElse: () => 0,
  );
});

class WaterController {
  final Ref ref;
  static const int maxDailyMl = 15000;

  WaterController(this.ref);

  Future<void> logWater(int amountMl) async {
    if (amountMl <= 0) {
      throw Exception('Invalid water amount.');
    }

    final repo = ref.read(waterRepositoryProvider);
    final currentTotal = ref.read(todayWaterTotalProvider);

    if (currentTotal + amountMl > maxDailyMl) {
      throw Exception('Daily water limit reached.');
    }

    try {
      await repo.addLog(amountMl, DateTime.now());
      await ref.read(todayWaterLogsProvider.notifier).refresh();
    } catch (e) {
      throw Exception('Unable to save water log. Please try again.');
    }
  }

  Future<void> resetToday() async {
    final repo = ref.read(waterRepositoryProvider);
    final logs = await ref.read(todayWaterLogsProvider.future);

    for (final log in logs) {
      await repo.deleteLog(log.id);
    }

    await ref.read(todayWaterLogsProvider.notifier).refresh();
  }

  Future<void> deleteLogEntry(String id) async {
    final repo = ref.read(waterRepositoryProvider);
    await repo.deleteLog(id);
    await ref.read(todayWaterLogsProvider.notifier).refresh();
  }
}

final waterControllerProvider = Provider<WaterController>((ref) {
  return WaterController(ref);
});
