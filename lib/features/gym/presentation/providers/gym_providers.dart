import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/gym_schedule_model.dart';
import '../../data/models/gym_workout_log_model.dart';
import '../../data/repositories/gym_repository.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

final gymRepositoryProvider = Provider<GymRepository>((ref) {
  return GymRepository();
});

/// --- State Notifiers ---

class GymScheduleNotifier
    extends AutoDisposeAsyncNotifier<List<GymScheduleModel>> {
  @override
  Future<List<GymScheduleModel>> build() async {
    final repo = ref.watch(gymRepositoryProvider);
    return repo.getAllSchedules();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return ref.read(gymRepositoryProvider).getAllSchedules();
    });
  }
}

final gymScheduleProvider =
    AsyncNotifierProvider.autoDispose<
      GymScheduleNotifier,
      List<GymScheduleModel>
    >(() {
      return GymScheduleNotifier();
    });

class GymLogsNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<GymWorkoutLogModel>, String> {
  @override
  Future<List<GymWorkoutLogModel>> build(String arg) async {
    final repo = ref.watch(gymRepositoryProvider);
    return repo.getLogsForDate(arg);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return ref.read(gymRepositoryProvider).getLogsForDate(arg);
    });
  }
}

final gymLogsForDateProvider = AsyncNotifierProvider.family
    .autoDispose<GymLogsNotifier, List<GymWorkoutLogModel>, String>(() {
      return GymLogsNotifier();
    });

/// --- Controller ---

class GymController {
  final Ref ref;
  final _uuid = const Uuid();

  GymController(this.ref);

  Future<void> upsertSchedule({
    String? id,
    required String dayOfWeek,
    required List<String> muscleGroups,
    required String workoutTitle,
    String notes = '',
    bool isRestDay = false,
  }) async {
    if (!isRestDay && workoutTitle.trim().isEmpty) {
      throw Exception('Please enter a workout title.');
    }
    if (!isRestDay && muscleGroups.isEmpty) {
      throw Exception('Please select at least one muscle group.');
    }

    final repo = ref.read(gymRepositoryProvider);

    // Pre-check: Ensure we aren't overwriting an existing day without knowing
    if (id == null) {
      final existing = repo.getScheduleForDay(dayOfWeek);
      if (existing != null) {
        id = existing
            .id; // Automatically convert ADD to UPDATE to prevent duplicate days
      }
    }

    final now = DateTime.now();
    final schedule = GymScheduleModel(
      id: id ?? _uuid.v4(),
      dayOfWeek: dayOfWeek,
      muscleGroups: isRestDay ? [] : muscleGroups,
      workoutTitle: isRestDay ? 'Rest Day' : workoutTitle.trim(),
      notes: notes.trim(),
      isRestDay: isRestDay,
      createdAt: now, // Handled correctly by map fallback if previously existed
      updatedAt: now,
    );

    await repo.saveSchedule(schedule);
    await ref.read(gymScheduleProvider.notifier).refresh();
  }

  Future<void> deleteSchedule(String id) async {
    await ref.read(gymRepositoryProvider).deleteSchedule(id);
    await ref.read(gymScheduleProvider.notifier).refresh();
  }

  Future<void> logWorkout({
    String? scheduleId,
    required String dateIso,
    required List<String> actualMuscleGroups,
    int durationMinutes = 0,
    String intensity = 'medium',
    String moodAfter = 'neutral',
    String notes = '',
  }) async {
    if (actualMuscleGroups.isEmpty) {
      throw Exception('Select muscle groups you trained.');
    }

    final repo = ref.read(gymRepositoryProvider);
    final log = GymWorkoutLogModel(
      id: _uuid.v4(),
      scheduleId: scheduleId,
      completedDate: dateIso,
      actualMuscleGroups: actualMuscleGroups,
      durationMinutes: durationMinutes,
      intensity: intensity,
      moodAfter: moodAfter,
      notes: notes,
      createdAt: DateTime.now(),
    );

    await repo.saveWorkoutLog(log);
    await ref.read(gymLogsForDateProvider(dateIso).notifier).refresh();
  }

  Future<void> deleteLog(String id, String dateIso) async {
    await ref.read(gymRepositoryProvider).deleteWorkoutLog(id);
    await ref.read(gymLogsForDateProvider(dateIso).notifier).refresh();
  }
}

final gymControllerProvider = Provider<GymController>((ref) {
  return GymController(ref);
});

final gymFeatureVisibleProvider = Provider<bool>((ref) {
  final profile = ref.watch(profileProvider);
  final settings = ref.watch(settingsProvider);

  // 1. If user forced enabled it in settings, always show it!
  if (settings.gymFeatureEnabled) {
    return true;
  }

  // 2. Otherwise, check profile userType for auto-enable
  if (profile != null) {
    final type = profile.userType.toLowerCase();
    if (type == 'fitness' || type == 'gym' || type == 'wellness') {
      return true;
    }
  }

  return false;
});
