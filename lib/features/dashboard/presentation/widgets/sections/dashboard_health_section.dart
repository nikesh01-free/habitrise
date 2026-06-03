import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitrise/core/theme/app_colors.dart';
import 'package:habitrise/core/theme/app_text_styles.dart';
import 'package:habitrise/core/widgets/app_toast.dart';
import 'package:habitrise/features/profile/presentation/providers/profile_providers.dart';
import 'package:habitrise/features/water/presentation/providers/water_providers.dart';
import 'package:habitrise/features/water/presentation/widgets/water_progress_card.dart';
import 'package:habitrise/features/steps/presentation/providers/step_providers.dart';
import 'package:habitrise/features/steps/presentation/widgets/step_progress_card.dart';
import 'package:habitrise/features/meals/presentation/widgets/meal_summary_card.dart';
import 'package:habitrise/features/sleep/presentation/widgets/sleep_summary_card.dart';

class DashboardHealthSection extends ConsumerStatefulWidget {
  const DashboardHealthSection({super.key});

  @override
  ConsumerState<DashboardHealthSection> createState() => _DashboardHealthSectionState();
}

class _DashboardHealthSectionState extends ConsumerState<DashboardHealthSection> {
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isExpanded = prefs.getBool('section_collapsed_health') != true;
      });
    }
  }

  Future<void> _toggleState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isExpanded = !_isExpanded;
      prefs.setBool('section_collapsed_health', !_isExpanded);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final currentWater = ref.watch(todayWaterTotalProvider);
    final stepsState = ref.watch(stepProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _toggleState,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary500.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: AppColors.primary500,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Health & Wellness',
                    style: AppTextStyles.h3.copyWith(
                      color: isDark ? Colors.white : AppNeutral.n900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  color: isDark ? AppNeutral.n400 : AppNeutral.n600,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded) ...[
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: WaterProgressCard(
                  currentMl: currentWater,
                  goalMl: profile?.dailyWaterGoalMl ?? 2500,
                  onAdd: (amount) async {
                    final ctx = context;
                    try {
                      await ref.read(waterControllerProvider).logWater(amount);
                      if (ctx.mounted) {
                        AppToast.show(
                          ctx,
                          '+$amount ml added!',
                          type: AppToastType.success,
                        );
                      }
                    } catch (e) {
                      if (ctx.mounted) {
                        AppToast.show(ctx, 'Failed to add water', type: AppToastType.error);
                      }
                    }
                  },
                  onReset: () async {
                    final ctx = context;
                    try {
                      await ref.read(waterControllerProvider).resetToday();
                      if (ctx.mounted) {
                        AppToast.show(ctx, 'Water reset', type: AppToastType.success);
                      }
                    } catch (e) {
                      if (ctx.mounted) {
                        AppToast.show(ctx, 'Failed to reset', type: AppToastType.error);
                      }
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StepProgressCard(
                  steps: stepsState.currentSteps,
                  goalSteps: stepsState.goalSteps,
                  isPermissionGranted: stepsState.isPermissionGranted,
                  isSensorAvailable: stepsState.isSensorAvailable,
                  onRequestPermission: () {
                    ref.read(stepProvider.notifier).requestPermission();
                  },
                  onAddManual: (amt) async {
                    final ctx = context;
                    try {
                      await ref.read(stepProvider.notifier).addManualSteps(amt);
                      if (ctx.mounted) {
                        AppToast.show(ctx, '+$amt steps added', type: AppToastType.success);
                      }
                    } catch (e) {
                      if (ctx.mounted) {
                        AppToast.show(ctx, 'Failed to add steps', type: AppToastType.error);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(child: MealSummaryCard()),
              const SizedBox(width: 12),
              const Expanded(child: SleepSummaryCard()),
            ],
          ),
        ],
      ],
    );
  }
}