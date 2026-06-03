import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/services/feature_sheet_service.dart';
import '../../../habits/presentation/add_habit_screen.dart';

class GettingStartedCard extends ConsumerWidget {
  const GettingStartedCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppNeutral.n800 : Colors.white,
        borderRadius: AppRadius.cardRadius,
        border: isDark ? Border.all(color: AppNeutral.n700) : null,
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Start your journey',
            style: AppTextStyles.h3.copyWith(
              color: isDark ? Colors.white : AppNeutral.n900,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Complete your first action to build consistency and unlock personalized insights.',
            style: AppTextStyles.bodyM.copyWith(
              color: isDark ? AppNeutral.n400 : AppNeutral.n500,
            ),
          ),
          const SizedBox(height: 20),
          _buildActionItem(
            context,
            icon: AppIcons.habits,
            title: 'Create Your First Habit',
            subtitle: 'Choose a routine or customize your own',
            color: AppFeatureColors.habitIcon,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddHabitScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActionItem(
            context,
            icon: AppIcons.water,
            title: 'Log Water Intake',
            subtitle: 'Track your daily hydration level',
            color: AppFeatureColors.waterIcon,
            onTap: () {
              FeatureSheetService.showWaterSheet(context, ref);
            },
          ),
          const SizedBox(height: 12),
          _buildActionItem(
            context,
            icon: AppIcons.sleep,
            title: 'Log Tonight\'s Sleep',
            subtitle: 'Record your sleep time and quality',
            color: AppFeatureColors.sleepIcon,
            onTap: () {
              FeatureSheetService.showSleepSheet(context, ref);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppNeutral.n900 : AppNeutral.n50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppNeutral.n800 : AppNeutral.n200,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(isDark ? 20 : 35),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppNeutral.n900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyS.copyWith(
                      color: isDark ? AppNeutral.n400 : AppNeutral.n500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? AppNeutral.n500 : AppNeutral.n400,
            ),
          ],
        ),
      ),
    );
  }
}
