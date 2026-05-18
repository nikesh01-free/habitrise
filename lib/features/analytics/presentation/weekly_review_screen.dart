import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitrise/core/theme/app_shadows.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../../../../core/widgets/app_card.dart';
import '../../habits/presentation/providers/habit_providers.dart';
import 'providers/analytics_providers.dart';

class WeeklyReviewScreen extends ConsumerWidget {
  const WeeklyReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summaryAsync = ref.watch(weeklyAnalyticsProvider);
    final habitsAsync = ref.watch(activeHabitsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppNeutral.n900 : AppNeutral.n50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            AppIcons.arrowLeft,
            color: isDark ? Colors.white : AppNeutral.n900,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Weekly Review',
          style: AppTextStyles.h4.copyWith(
            color: isDark ? Colors.white : AppNeutral.n900,
          ),
        ),
        centerTitle: true,
      ),
      body: summaryAsync.when(
        loading: () => const AppLoadingState(),
        error: (e, s) =>
            const Center(child: Text('Failed to generate review.')),
        data: (summary) {
          final activeCount = habitsAsync.value?.length ?? 0;
          final avgSleep = summary.totalSleepMinutes / (7 * 60);
          final avgWater = summary.totalWater / 7;

          // Calculate total completions in the loop
          int completions = 0;
          for (var day in summary.last7Days) {
            if (day.habitCompletionRatio > 0) {
              // We don't have explicit habit counts in the summary loop easily accessible,
              // so we'll just show general consistency derived from our analytics provider!
              completions += (day.habitCompletionRatio * activeCount).round();
            }
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildHeroSection(
                context,
                summary.currentStreak,
                summary.longestStreak,
              ),
              const SizedBox(height: 32),
              Text(
                'YOUR WEEKLY STATS',
                style: AppTextStyles.bodyS.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: AppNeutral.n500,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatRow(
                icon: AppIcons.habits,
                label: 'Active Habits',
                value: '$activeCount',
                color: AppFeatureColors.habitIcon,
              ),
              _buildStatRow(
                icon: Icons.done_all_rounded,
                label: 'Habits Logged',
                value: '$completions',
                color: AppSemantic.success,
              ),
              _buildStatRow(
                icon: AppIcons.water,
                label: 'Avg. Daily Water',
                value: '${avgWater.toStringAsFixed(0)} ml',
                color: AppFeatureColors.waterIcon,
              ),
              _buildStatRow(
                icon: AppIcons.steps,
                label: 'Total Steps',
                value: '${summary.totalSteps}',
                color: AppFeatureColors.stepIcon,
              ),
              _buildStatRow(
                icon: AppIcons.sleep,
                label: 'Avg. Sleep',
                value: '${avgSleep.toStringAsFixed(1)} hrs',
                color: AppFeatureColors.sleepIcon,
              ),
              _buildStatRow(
                icon: AppIcons.focus,
                label: 'Focus Time',
                value: '${summary.totalFocusMinutes} mins',
                color: const Color(0xFF8B5CF6),
              ),
              _buildStatRow(
                icon: AppIcons.meals,
                label: 'Meals Logged',
                value: '${summary.totalMeals}',
                color: AppFeatureColors.mealIcon,
              ),
              const SizedBox(height: 40),
              AppCard(
                backgroundColor: isDark
                    ? AppColors.primary500.withAlpha(20)
                    : AppColors.primary50,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.celebration_rounded,
                      color: AppColors.primary600,
                      size: 36,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Keep going!',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.primary600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Consistency is key to permanent lifestyle changes.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyM.copyWith(
                        color: isDark ? AppNeutral.n300 : AppNeutral.n700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, int current, int best) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D3748), Color(0xFF1A202C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.cardRadius,
        boxShadow: [AppShadows.float],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.auto_awesome_outlined,
            color: Colors.amber,
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            'Past 7 Days Report',
            style: AppTextStyles.h2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Here is a snapshot of your lifestyle metrics.',
            style: AppTextStyles.bodyS.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white12),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _heroStat(
                'Current Streak',
                '$current',
                Icons.local_fire_department,
                Colors.orange,
              ),
              _heroStat(
                'Best Streak',
                '$best',
                Icons.military_tech,
                Colors.amber,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String label, String val, IconData ic, Color col) {
    return Column(
      children: [
        Row(
          children: [
            Icon(ic, color: col, size: 20),
            const SizedBox(width: 4),
            Text(
              val,
              style: AppTextStyles.h1.copyWith(
                color: Colors.white,
                fontSize: 32,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: AppTextStyles.bodyS.copyWith(
            color: Colors.white60,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppNeutral.n800 : Colors.white,
            borderRadius: AppRadius.cardRadius,
            border: Border.all(
              color: isDark ? AppNeutral.n700 : AppNeutral.n200,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: AppTextStyles.bodyM.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppNeutral.n300 : AppNeutral.n700,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: AppTextStyles.h4.copyWith(
                  color: isDark ? Colors.white : AppNeutral.n900,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
