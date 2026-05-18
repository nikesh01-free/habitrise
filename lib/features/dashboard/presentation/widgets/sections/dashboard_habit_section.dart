import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitrise/core/widgets/app_loading_state.dart';
import 'package:habitrise/core/widgets/app_toast.dart';
import 'package:habitrise/features/habits/presentation/add_habit_screen.dart';
import 'package:habitrise/features/habits/presentation/providers/habit_providers.dart';
import 'package:habitrise/features/habits/presentation/widgets/habit_details_modal.dart';
import 'package:habitrise/features/habits/presentation/widgets/habit_summary_card.dart';
import '../daily_motivation_card.dart';

class DashboardHabitSection extends ConsumerWidget {
  const DashboardHabitSection({super.key});

  String _getTodayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayStr = _getTodayStr();
    final habitsAsync = ref.watch(activeHabitsProvider);
    final logsAsync = ref.watch(habitLogsForDateProvider(todayStr));

    return habitsAsync.when(
      loading: () => const SizedBox(height: 200, child: AppLoadingState()),
      error: (err, _) => const Center(child: Text('Error loading habits.')),
      data: (habits) {
        return logsAsync.when(
          loading: () => const SizedBox(height: 200, child: AppLoadingState()),
          error: (err, _) => const Center(child: Text('Error loading logs.')),
          data: (logs) {
            final completedHabitIds = logs
                .where((l) => l.status == 'completed')
                .map((l) => l.habitId)
                .toSet();

            return Column(
              children: [
                const DailyMotivationCard(),
                const SizedBox(height: 24),
                HabitSummaryCard(
                  habits: habits,
                  completedHabitIds: completedHabitIds,
                  onAddPressed: () {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (_) => AddHabitScreen()));
                  },
                  onToggle: (habitId) async {
                    final localContext = context;
                    try {
                      await ref
                          .read(habitControllerProvider)
                          .toggleHabitCompletion(
                            habitId: habitId,
                            date: todayStr,
                            context: localContext,
                          );
                    } catch (e) {
                      if (!localContext.mounted) return;
                      AppToast.show(
                        localContext,
                        'Action failed',
                        type: AppToastType.error,
                      );
                    }
                  },
                  onEdit: (habit) {
                    HabitDetailsModal.show(context, habit);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
