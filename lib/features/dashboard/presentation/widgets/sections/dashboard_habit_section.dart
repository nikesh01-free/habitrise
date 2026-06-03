import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitrise/core/widgets/app_loading_state.dart';
import 'package:habitrise/core/widgets/app_toast.dart';
import 'package:habitrise/core/widgets/app_modal.dart';
import 'package:habitrise/core/theme/app_colors.dart';
import 'package:habitrise/core/theme/app_text_styles.dart';
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

  void _showCelebrationSheet(BuildContext context, int streak) {
    AppModal.showSheet(
      context: context,
      child: _AllDoneCelebrationSheet(streak: streak),
    );
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
                      final isCurrentlyCompleted = completedHabitIds.contains(habitId);

                      await ref
                          .read(habitControllerProvider)
                          .toggleHabitCompletion(
                            habitId: habitId,
                            date: todayStr,
                            context: localContext,
                          );

                      if (!isCurrentlyCompleted) {
                        // Check if all habits are now completed
                        final freshLogs = await ref.read(habitLogsForDateProvider(todayStr).future);
                        final freshCompletedIds = freshLogs
                            .where((l) => l.status == 'completed')
                            .map((l) => l.habitId)
                            .toSet();

                        if (freshCompletedIds.length >= habits.length && habits.isNotEmpty) {
                          final allDone = habits.every((h) => freshCompletedIds.contains(h.id));
                          if (allDone) {
                            final prefs = await SharedPreferences.getInstance();
                            final gateKey = 'celebration_shown_$todayStr';
                            final alreadyShown = prefs.getBool(gateKey) ?? false;
                            if (!alreadyShown) {
                              await prefs.setBool(gateKey, true);
                              int maxStreak = 0;
                              for (final h in habits) {
                                final s = ref.read(habitStreakProvider(h.id));
                                if (s > maxStreak) maxStreak = s;
                              }
                              if (localContext.mounted) {
                                _showCelebrationSheet(localContext, maxStreak);
                              }
                            }
                          }
                        }
                      }
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

class _AllDoneCelebrationSheet extends StatelessWidget {
  final int streak;
  const _AllDoneCelebrationSheet({required this.streak});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            color: Colors.amber,
            size: 80,
          ),
          const SizedBox(height: 16),
          Text(
            'All done for today!',
            style: AppTextStyles.h2.copyWith(
              color: isDark ? Colors.white : AppNeutral.n900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Amazing job! You\'ve completed all your habits for today.',
            style: AppTextStyles.bodyM.copyWith(
              color: AppNeutral.n500,
            ),
            textAlign: TextAlign.center,
          ),
          if (streak > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withAlpha(50)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    '$streak Day Streak!',
                    style: AppTextStyles.bodyM.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sharing coming soon!')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: isDark ? AppNeutral.n700 : AppNeutral.n300,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Share',
                    style: AppTextStyles.bodyM.copyWith(
                      color: isDark ? Colors.white : AppNeutral.n900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary600,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Awesome',
                    style: AppTextStyles.bodyM.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
