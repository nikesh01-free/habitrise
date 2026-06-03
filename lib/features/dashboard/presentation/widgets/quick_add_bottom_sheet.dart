import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../gym/presentation/providers/gym_providers.dart';
import '../../../habits/presentation/add_habit_screen.dart';
import '../../../meals/presentation/meals_screen.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/app_modal.dart';
import '../../../../core/services/feature_sheet_service.dart';

class QuickAddBottomSheet extends ConsumerWidget {
  final VoidCallback? onNavigateToFocus;

  const QuickAddBottomSheet({super.key, this.onNavigateToFocus});

  static void show(BuildContext context, {VoidCallback? onNavigateToFocus}) {
    AppModal.showSheet(
      context: context,
      child: QuickAddBottomSheet(onNavigateToFocus: onNavigateToFocus),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gymVisible = ref.watch(gymFeatureVisibleProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Action',
            style: AppTextStyles.h2.copyWith(
              color: isDark ? Colors.white : AppNeutral.n900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'What would you like to log now?',
            style: AppTextStyles.bodyM.copyWith(
              color: isDark ? AppNeutral.n400 : AppNeutral.n500,
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 12,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.85,
            children: [
              _QuickActionItem(
                icon: AppIcons.habits,
                label: 'Habit',
                color: AppFeatureColors.habitIcon,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddHabitScreen()),
                  );
                },
              ),
              _QuickActionItem(
                icon: AppIcons.water,
                label: 'Water',
                color: AppFeatureColors.waterIcon,
                onTap: () {
                  Navigator.pop(context);
                  FeatureSheetService.showWaterSheet(context, ref);
                },
              ),
              _QuickActionItem(
                icon: AppIcons.meals,
                label: 'Meal',
                color: AppFeatureColors.mealIcon,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MealsScreen()),
                  );
                },
              ),
              _QuickActionItem(
                icon: AppIcons.sleep,
                label: 'Sleep',
                color: AppFeatureColors.sleepIcon,
                onTap: () {
                  Navigator.pop(context);
                  FeatureSheetService.showSleepSheet(context, ref);
                },
              ),
              _QuickActionItem(
                icon: AppIcons.focus,
                label: 'Focus',
                color: AppFeatureColors.focusIcon,
                onTap: () {
                  Navigator.pop(context);
                  onNavigateToFocus?.call();
                },
              ),
              _QuickActionItem(
                icon: Icons.emoji_emotions_outlined,
                label: 'Mood',
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  FeatureSheetService.showMoodSheet(context, ref);
                },
              ),
              if (gymVisible)
                _QuickActionItem(
                  icon: Icons.fitness_center_rounded,
                  label: 'Gym',
                  color: AppFeatureColors.gymIcon,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.gym);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(isDark ? 25 : 35),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodyS.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppNeutral.n300 : AppNeutral.n700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
