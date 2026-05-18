import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitrise/core/theme/app_colors.dart';
import 'package:habitrise/core/theme/app_text_styles.dart';
import 'package:habitrise/core/theme/app_radius.dart';
import 'package:habitrise/core/theme/app_shadows.dart';
import 'package:habitrise/features/habits/presentation/add_habit_screen.dart';

class TodayProgressCard extends ConsumerWidget {
  final double percentage;
  final int habitsDone;
  final int habitsTotal;

  const TodayProgressCard({
    super.key,
    required this.percentage,
    required this.habitsDone,
    required this.habitsTotal,
  });

  String _getMotivationalText() {
    final pct = percentage * 100;
    if (pct == 0) return "Let's crush it! 💪";
    if (pct < 25) return 'Just getting started! 🔥';
    if (pct < 50) return 'Great progress! Keep going! ⭐';
    if (pct < 75) return 'More than halfway! 🚀';
    if (pct < 100) return 'Almost there! Finish strong! 🏆';
    return 'All done! You\'re amazing! 🎉';
  }

  Color _getProgressColor() {
    final pct = percentage * 100;
    if (pct == 100) return AppColors.accent500;
    if (pct >= 75) return AppColors.primary500;
    if (pct >= 50) return const Color(0xFF818CF8);
    if (pct >= 25) return const Color(0xFFFBBF24);
    return const Color(0xFF94A3B8);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayPercent = percentage.isNaN || percentage.isInfinite
        ? 0.0
        : percentage.clamp(0.0, 1.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressColor = _getProgressColor();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2D2D44), const Color(0xFF1A1A2E)]
              : [Colors.white, const Color(0xFFF8FAFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.cardRadius,
        border: Border.all(
          color: isDark ? AppNeutral.n700 : AppNeutral.n200,
          width: 1,
        ),
        boxShadow: [isDark ? AppShadows.cardDark : AppShadows.cardLight],
      ),
      child: Row(
        children: [
          // Left side - Progress info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: progressColor.withAlpha(25),
                    borderRadius: AppRadius.chipRadius,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        percentage >= 1.0 ? Icons.check_circle : Icons.trending_up,
                        size: 14,
                        color: progressColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        percentage >= 1.0 ? 'Complete!' : 'Today',
                        style: AppTextStyles.bodyS.copyWith(
                          color: progressColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Title
                Text(
                  "Today's Habits",
                  style: AppTextStyles.h3.copyWith(
                    color: isDark ? Colors.white : AppNeutral.n900,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                // Progress text
                Text(
                  '$habitsDone of $habitsTotal completed',
                  style: AppTextStyles.bodyM.copyWith(
                    color: isDark ? AppNeutral.n400 : AppNeutral.n500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                // Motivational text
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppNeutral.n700.withAlpha(128)
                        : AppNeutral.n100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getMotivationalText(),
                    style: AppTextStyles.bodyS.copyWith(
                      color: isDark ? AppNeutral.n300 : AppNeutral.n600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Add habits button when empty
                if (habitsTotal == 0) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddHabitScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary500,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [AppShadows.primaryGlow],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Add your first habit',
                            style: AppTextStyles.bodyS.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Right side - Circular progress
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: displayPercent),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, val, _) {
              return Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppNeutral.n800 : AppNeutral.n100,
                  border: Border.all(
                    color: isDark ? AppNeutral.n700 : AppNeutral.n200,
                    width: 3,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background track
                    SizedBox(
                      width: 78,
                      height: 78,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 6,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? AppNeutral.n700 : AppNeutral.n200,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    // Progress track
                    SizedBox(
                      width: 78,
                      height: 78,
                      child: CircularProgressIndicator(
                        value: val,
                        strokeWidth: 6,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    // Percentage text
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(val * 100).toInt()}%',
                          style: AppTextStyles.h3.copyWith(
                            color: isDark ? Colors.white : AppNeutral.n900,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (percentage >= 1.0)
                          Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: AppColors.accent500,
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}