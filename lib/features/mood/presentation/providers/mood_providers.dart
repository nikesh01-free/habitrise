import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/mood_repository.dart';
import '../../data/models/mood_log_model.dart';

final moodRepositoryProvider = Provider<MoodRepository>((ref) {
  return MoodRepository();
});

class TodayMoodNotifier extends AutoDisposeAsyncNotifier<MoodLogModel?> {
  @override
  Future<MoodLogModel?> build() async {
    final repo = ref.watch(moodRepositoryProvider);
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return repo.getMoodForDate(dateStr);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(moodRepositoryProvider);
      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      return repo.getMoodForDate(dateStr);
    });
  }
}

final todayMoodProvider =
    AsyncNotifierProvider.autoDispose<TodayMoodNotifier, MoodLogModel?>(() {
      return TodayMoodNotifier();
    });

class MoodController {
  final Ref ref;

  static const allowedMoods = {'great', 'good', 'okay', 'bad', 'tired'};

  MoodController(this.ref);

  Future<void> updateMood(String mood, {String? note}) async {
    if (!allowedMoods.contains(mood.toLowerCase())) {
      throw Exception('Please select a valid mood.');
    }

    try {
      final repo = ref.read(moodRepositoryProvider);
      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      await repo.logMood(
        logDate: dateStr,
        mood: mood.toLowerCase(),
        note: note,
      );

      // Smoothly hydrate visual streams
      await ref.read(todayMoodProvider.notifier).refresh();
    } catch (e) {
      throw Exception('Unable to save mood. Please try again.');
    }
  }
}

final moodControllerProvider = Provider<MoodController>((ref) {
  return MoodController(ref);
});
