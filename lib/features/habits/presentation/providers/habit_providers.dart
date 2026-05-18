import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitrise/core/utils/app_logger.dart';
import '../../data/repositories/habit_repository.dart';
import '../../data/models/habit_model.dart';
import '../../data/models/habit_log_model.dart';
import '../../../../core/services/notification_service.dart';
import 'package:habitrise/features/rewards/presentation/controllers/reward_controller.dart';

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepository();
});

class ActiveHabitsNotifier extends AutoDisposeAsyncNotifier<List<HabitModel>> {
  @override
  Future<List<HabitModel>> build() async {
    final repo = ref.watch(habitRepositoryProvider);
    final list = repo.getAllActiveHabits();
    _sortHabits(list);
    return list;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(habitRepositoryProvider);
      final list = repo.getAllActiveHabits();
      _sortHabits(list);
      return list;
    });
  }

  void _sortHabits(List<HabitModel> list) {
    list.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      // Sub-sort by creation date (newest first)
      return b.createdAt.compareTo(a.createdAt);
    });
  }
}

final activeHabitsProvider =
    AsyncNotifierProvider.autoDispose<ActiveHabitsNotifier, List<HabitModel>>(
      () {
        return ActiveHabitsNotifier();
      },
    );

class HabitLogsNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<HabitLogModel>, String> {
  @override
  Future<List<HabitLogModel>> build(String arg) async {
    final repo = ref.watch(habitRepositoryProvider);
    return repo.getLogsForDate(arg);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return ref.read(habitRepositoryProvider).getLogsForDate(arg);
    });
  }
}

final habitLogsForDateProvider = AsyncNotifierProvider.family
    .autoDispose<HabitLogsNotifier, List<HabitLogModel>, String>(() {
      return HabitLogsNotifier();
    });

class HabitController {
  final Ref ref;
  HabitController(this.ref);

  Future<void> addHabit({
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
    if (title.trim().length < 2 || title.trim().length > 40) {
      throw Exception('Habit name must be 2–40 characters.');
    }

    final repo = ref.read(habitRepositoryProvider);
    final habit = await repo.createHabit(
      title: title.trim(),
      category: category,
      type: type,
      frequency: frequency,
      colorHex: colorHex,
      targetValue: targetValue,
      unit: unit,
      icon: icon,
      reminderEnabled: reminderEnabled,
      reminderTime: reminderTime,
    );

    if (reminderEnabled && reminderTime != null) {
      await _scheduleReminder(habit.id, habit.title, reminderTime);
    }

    await ref.read(activeHabitsProvider.notifier).refresh();
  }

  Future<void> toggleHabitCompletion({
    required String habitId,
    required String date,
    BuildContext? context,
  }) async {
    final repo = ref.read(habitRepositoryProvider);
    final logs = repo.getLogsForDate(date);
    final isCompleted = logs.any(
      (l) => l.habitId == habitId && l.status == 'completed',
    );

    if (isCompleted) {
      await repo.logHabit(habitId: habitId, logDate: date, status: 'missed');
    } else {
      await repo.logHabit(habitId: habitId, logDate: date, status: 'completed');

      // Trigger reward engine check
      if (context != null && context.mounted) {
        ref.read(rewardControllerProvider).checkFirstHabitCompletion(context);
      }
    }

    await ref.read(habitLogsForDateProvider(date).notifier).refresh();
  }

  Future<void> updateHabit(HabitModel habit) async {
    if (habit.title.trim().length < 2 || habit.title.trim().length > 40) {
      throw Exception('Habit name must be 2–40 characters.');
    }

    final repo = ref.read(habitRepositoryProvider);
    await repo.updateHabit(habit);

    // Re-sync lifecycle notifications
    await NotificationService().cancelNotification(habit.id);
    if (habit.reminderEnabled && habit.reminderTime != null) {
      await _scheduleReminder(habit.id, habit.title, habit.reminderTime!);
    }

    await ref.read(activeHabitsProvider.notifier).refresh();
  }

  Future<void> togglePinHabit(HabitModel habit) async {
    final repo = ref.read(habitRepositoryProvider);
    final updated = habit.copyWith(isPinned: !habit.isPinned);
    await repo.updateHabit(updated);
    await ref.read(activeHabitsProvider.notifier).refresh();
  }

  Future<void> archiveHabit(String id) async {
    final repo = ref.read(habitRepositoryProvider);
    await repo.archiveHabit(id);
    await NotificationService().cancelNotification(id);
    await ref.read(activeHabitsProvider.notifier).refresh();
  }

  Future<void> deleteHabit(String id) async {
    final repo = ref.read(habitRepositoryProvider);
    await repo.deleteHabit(id);
    await NotificationService().cancelNotification(id);
    await ref.read(activeHabitsProvider.notifier).refresh();
  }

  Future<void> _scheduleReminder(
    String habitId,
    String title,
    String timeStr,
  ) async {
    try {
      final parts = timeStr.split(':');
      if (parts.length != 2) return;

      final time = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );

      await NotificationService().scheduleHabitReminder(
        habitId: habitId,
        title: title,
        time: time,
      );
    } catch (e) {
      AppLogger.warning(
        'Warning: Failed to parse or schedule reminder time: $timeStr',
      );
    }
  }
}

final habitControllerProvider = Provider<HabitController>((ref) {
  return HabitController(ref);
});
