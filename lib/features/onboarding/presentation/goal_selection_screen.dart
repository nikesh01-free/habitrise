import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habitrise/core/constants/app_routes.dart';
import 'package:habitrise/core/theme/app_colors.dart';
import 'package:habitrise/core/theme/app_text_styles.dart';
import 'package:habitrise/core/theme/app_icons.dart';
import 'package:habitrise/core/widgets/app_button.dart';
import 'package:habitrise/core/widgets/app_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalSelectionScreen extends StatefulWidget {
  const GoalSelectionScreen({super.key});

  @override
  State<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  final List<Map<String, String>> _goals = [
    {'label': 'Student Focus', 'emoji': '🎓'},
    {'label': 'Fitness', 'emoji': '💪'},
    {'label': 'Productivity', 'emoji': '⚡'},
    {'label': 'Sleep', 'emoji': '🌙'},
    {'label': 'Wellness', 'emoji': '🧠'},
  ];
  final Set<String> _selected = {};

  void _toggle(String label) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selected.contains(label)) {
        _selected.remove(label);
      } else {
        _selected.add(label);
      }
    });
  }

  Future<void> _continue() async {
    if (_selected.isEmpty) {
      AppToast.show(context, 'Select at least one goal', type: AppToastType.warning);
      return;
    }
    // Persist selected goals for use in PermissionsScreen
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selected_goals', _selected.toList());
    if (mounted) {
      Navigator.pushNamed(context, AppRoutes.onboardingProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppNeutral.n900 : AppNeutral.n50,
      appBar: AppBar(title: const Text('Your Objective')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "What's your priority?",
                style: AppTextStyles.h2.copyWith(color: isDark ? Colors.white : AppNeutral.n900),
              ),
              const SizedBox(height: 8),
              Text(
                'Select focus tracks to customize your experience.',
                style: AppTextStyles.bodyM.copyWith(color: AppNeutral.n500),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.separated(
                  itemCount: _goals.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (ctx, index) {
                    final goal = _goals[index];
                    final label = goal['label']!;
                    final isSel = _selected.contains(label);

                    return GestureDetector(
                      onTap: () => _toggle(label),
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
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSel ? Colors.white.withAlpha(40) : (isDark ? AppNeutral.n700 : AppNeutral.n50),
                                shape: BoxShape.circle,
                              ),
                              child: Text(goal['emoji']!, style: const TextStyle(fontSize: 24)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                label,
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
                label: 'Continue',
                fullWidth: true,
                size: AppButtonSize.lg,
                onPressed: _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}