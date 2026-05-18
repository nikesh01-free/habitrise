import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../meals/presentation/providers/meal_providers.dart';
import '../../../meals/presentation/meals_screen.dart';

class MealSummaryCard extends ConsumerWidget {
  const MealSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final meals = ref.watch(todayMealsProvider);
    final completedCount = meals.where((m) => m.status == 'completed').length;

    final Color cardBg = isDark ? AppNeutral.n800 : AppFeatureColors.mealBg;
    final Color contentColor = AppFeatureColors.mealIcon;

    return AppCard(
      backgroundColor: cardBg,
      padding: const EdgeInsets.all(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MealsScreen()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(isDark ? 20 : 255),
                  shape: BoxShape.circle,
                ),
                child: Icon(AppIcons.meals, color: contentColor, size: 20),
              ),
              Icon(
                AppIcons.arrowRight,
                color: contentColor.withAlpha(120),
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '$completedCount Meals',
            style: AppTextStyles.h3.copyWith(
              color: isDark ? Colors.white : AppNeutral.n900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Today\'s Log',
            style: AppTextStyles.bodyS.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppNeutral.n400 : AppNeutral.n600,
            ),
          ),
        ],
      ),
    );
  }
}
