import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habitrise/core/constants/app_routes.dart';
import 'package:habitrise/core/theme/app_colors.dart';
import 'package:habitrise/core/theme/app_text_styles.dart';
import 'package:habitrise/core/theme/app_icons.dart';
import 'package:habitrise/core/widgets/app_button.dart';

class StarterHabitsScreen extends StatefulWidget {
  const StarterHabitsScreen({super.key});

  @override
  State<StarterHabitsScreen> createState() => _StarterHabitsScreenState();
}

class _StarterHabitsScreenState extends State<StarterHabitsScreen> {
  final List<Map<String, String>> _habits = [
    {'title': 'Hydrate With 8 Glasses', 'icon': 'water_drop'},
    {'title': 'Read For 20 Minutes', 'icon': 'menu_book'},
    {'title': 'Sleep For 7-8 Hours', 'icon': 'bedtime'},
    {'title': 'Reach 8,000 Steps', 'icon': 'directions_walk'},
  ];
  final Set<int> _selected = {0, 1, 2, 3};

  IconData _getIcon(String icon) {
    switch (icon) {
      case 'water_drop': return AppIcons.water;
      case 'menu_book': return AppIcons.bookOpen;
      case 'bedtime': return AppIcons.sleep;
      case 'directions_walk': return AppIcons.steps;
      default: return AppIcons.check;
    }
  }

  void _toggle(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selected.contains(index)) {
        _selected.remove(index);
      } else {
        _selected.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppNeutral.n900 : AppNeutral.n50,
      appBar: AppBar(title: const Text('Foundations')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Launch Setup',
                style: AppTextStyles.h2.copyWith(color: isDark ? Colors.white : AppNeutral.n900),
              ),
              const SizedBox(height: 8),
              Text(
                'Kickstart with proven daily habits.',
                style: AppTextStyles.bodyM.copyWith(color: AppNeutral.n500),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.separated(
                  itemCount: _habits.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (ctx, index) {
                    final habit = _habits[index];
                    final isSel = _selected.contains(index);

                    return GestureDetector(
                      onTap: () => _toggle(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.primary500.withAlpha(15) : (isDark ? AppNeutral.n800 : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSel ? AppColors.primary500 : (isDark ? AppNeutral.n700 : AppNeutral.n200),
                            width: isSel ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSel ? AppColors.primary500.withAlpha(20) : (isDark ? AppNeutral.n700 : AppNeutral.n50),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getIcon(habit['icon']!),
                                color: isSel ? AppColors.primary600 : AppNeutral.n400,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                habit['title']!,
                                style: AppTextStyles.bodyM.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isSel ? AppColors.primary600 : (isDark ? Colors.white : AppNeutral.n900),
                                ),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSel ? AppColors.primary500 : Colors.transparent,
                                border: Border.all(
                                  color: isSel ? AppColors.primary500 : AppNeutral.n300,
                                  width: 2,
                                ),
                              ),
                              child: isSel ? const Icon(AppIcons.check, size: 14, color: Colors.white) : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Pre-generate Habits',
                fullWidth: true,
                size: AppButtonSize.lg,
                onPressed: () => Navigator.pushNamed(context, AppRoutes.onboardingPermissions),
              ),
            ],
          ),
        ),
      ),
    );
  }
}