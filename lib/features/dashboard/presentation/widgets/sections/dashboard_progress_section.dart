import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitrise/core/widgets/app_loading_state.dart';
import 'package:habitrise/features/habits/presentation/providers/habit_providers.dart';
import 'package:habitrise/features/dashboard/presentation/widgets/today_progress_card.dart';

class DashboardProgressSection extends ConsumerWidget {
  const DashboardProgressSection({super.key});

  String _getTodayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(activeHabitsProvider);
    final todayStr = _getTodayStr();
    final logsAsync = ref.watch(habitLogsForDateProvider(todayStr));

    return habitsAsync.when(
      loading: () => const SizedBox(height: 100, child: AppLoadingState()),
      error: (err, _) => const SizedBox(),
      data: (habits) {
        return logsAsync.when(
          loading: () => const SizedBox(height: 100, child: AppLoadingState()),
          error: (err, _) => const SizedBox(),
          data: (logs) {
            final completedHabitIds = logs
                .where((l) => l.status == 'completed')
                .map((l) => l.habitId)
                .toSet();

            final int totalCount = habits.length;
            final int completedCount = habits
                .where((h) => completedHabitIds.contains(h.id))
                .length;
            final double progressPercent = totalCount > 0
                ? completedCount / totalCount
                : 0.0;

            return TodayProgressCard(
              percentage: progressPercent,
              habitsDone: completedCount,
              habitsTotal: totalCount,
            );
          },
        );
      },
    );
  }
}
