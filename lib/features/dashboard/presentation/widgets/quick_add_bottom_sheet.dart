import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../water/presentation/providers/water_providers.dart';
import '../../../sleep/presentation/providers/sleep_providers.dart';
import '../../../gym/presentation/providers/gym_providers.dart';
import '../../../mood/presentation/providers/mood_providers.dart';
import '../../../habits/presentation/add_habit_screen.dart';
import '../../../meals/presentation/meals_screen.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/app_modal.dart';
import '../../../../core/widgets/app_button.dart';

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
                onTap: () async {
                  Navigator.pop(context); // close sheet
                  _showWaterDialog(context, ref);
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
                  _showSleepDialog(context, ref);
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
                  _showMoodDialog(context, ref);
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

  // --- HELPER MODALS ---

  void _showWaterDialog(BuildContext context, WidgetRef _) {
    AppModal.showSheet(
      context: context,
      child: Consumer(
        builder: (ctx, localRef, _) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Add Water Intake', style: AppTextStyles.h2),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _waterPreset(ctx, localRef, 150, 'Glass'),
                    _waterPreset(ctx, localRef, 250, 'Normal'),
                    _waterPreset(ctx, localRef, 500, 'Bottle'),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _waterPreset(
    BuildContext context,
    WidgetRef ref,
    int amount,
    String label,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () async {
        Navigator.pop(context); // close amount picker
        try {
          await ref.read(waterControllerProvider).logWater(amount);
          if (context.mounted) {
            AppToast.show(
              context,
              'Added ${amount}ml water!',
              type: AppToastType.success,
            );
          }
        } catch (_) {}
      },
      borderRadius: AppRadius.cardRadius,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppNeutral.n800 : AppNeutral.n50,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(color: isDark ? AppNeutral.n700 : AppNeutral.n200),
        ),
        child: Column(
          children: [
            const Icon(
              AppIcons.water,
              color: AppFeatureColors.waterIcon,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              '${amount}ml',
              style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(label, style: AppTextStyles.bodyS),
          ],
        ),
      ),
    );
  }

  void _showSleepDialog(BuildContext context, WidgetRef _) {
    AppModal.showSheet(
      context: context,
      child: Consumer(
        builder: (ctx, localRef, _) {
          final current = localRef.watch(todaySleepProvider);
          final now = DateTime.now();
          DateTime defaultSleep = DateTime(
            now.year,
            now.month,
            now.day - 1,
            22,
            0,
          );
          DateTime defaultWake = DateTime(now.year, now.month, now.day, 7, 0);

          DateTime sleepTime = current?.sleepTime ?? defaultSleep;
          DateTime wakeTime = current?.wakeTime ?? defaultWake;

          return StatefulBuilder(
            builder: (statefulCtx, setState) {
              Future<void> pickTime(bool isSleep) async {
                final tm = await showTimePicker(
                  context: statefulCtx,
                  initialTime: TimeOfDay.fromDateTime(
                    isSleep ? sleepTime : wakeTime,
                  ),
                );
                if (tm == null) return;
                setState(() {
                  final currentNow = DateTime.now();
                  final combined = DateTime(
                    currentNow.year,
                    currentNow.month,
                    currentNow.day,
                    tm.hour,
                    tm.minute,
                  );
                  if (isSleep) {
                    sleepTime = combined;
                  } else {
                    wakeTime = combined;
                  }
                });
              }

              final isDark =
                  Theme.of(statefulCtx).brightness == Brightness.dark;

              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Sleep Log', style: AppTextStyles.h2),
                    const SizedBox(height: 20),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      tileColor: isDark ? AppNeutral.n800 : AppNeutral.n50,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.cardRadius,
                      ),
                      leading: const Icon(
                        AppIcons.sleep,
                        color: AppFeatureColors.sleepIcon,
                      ),
                      title: const Text('Sleep Time'),
                      trailing: Text(
                        '${sleepTime.hour.toString().padLeft(2, '0')}:${sleepTime.minute.toString().padLeft(2, '0')}',
                        style: AppTextStyles.bodyM.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onTap: () => pickTime(true),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      tileColor: isDark ? AppNeutral.n800 : AppNeutral.n50,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.cardRadius,
                      ),
                      leading: const Icon(AppIcons.sun, color: Colors.orange),
                      title: const Text('Wake Time'),
                      trailing: Text(
                        '${wakeTime.hour.toString().padLeft(2, '0')}:${wakeTime.minute.toString().padLeft(2, '0')}',
                        style: AppTextStyles.bodyM.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onTap: () => pickTime(false),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: current == null ? 'Log Sleep' : 'Update',
                      fullWidth: true,
                      onPressed: () async {
                        DateTime finalSleep = sleepTime;
                        DateTime finalWake = wakeTime;
                        if (finalSleep.isAfter(finalWake)) {
                          finalSleep = finalSleep.subtract(
                            const Duration(days: 1),
                          );
                        }
                        try {
                          await localRef
                              .read(todaySleepProvider.notifier)
                              .logSleep(
                                sleepTime: finalSleep,
                                wakeTime: finalWake,
                                quality: 'good',
                              );
                          if (statefulCtx.mounted) Navigator.pop(statefulCtx);
                        } catch (e) {
                          if (statefulCtx.mounted) {
                            AppToast.show(
                              statefulCtx,
                              'Failed to save sleep log',
                              type: AppToastType.error,
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showMoodDialog(BuildContext context, WidgetRef _) {
    final moods = const [
      _MoodPreset(emoji: '😩', label: 'Tired'),
      _MoodPreset(emoji: '😔', label: 'Bad'),
      _MoodPreset(emoji: '😐', label: 'Okay'),
      _MoodPreset(emoji: '😊', label: 'Good'),
      _MoodPreset(emoji: '🤩', label: 'Great'),
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    AppModal.showSheet(
      context: context,
      child: Consumer(
        builder: (ctx, localRef, _) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('How are you feeling?', style: AppTextStyles.h2),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: moods.map((mood) {
                    final label = mood.label;
                    return Expanded(
                      child: InkWell(
                        onTap: () async {
                          Navigator.pop(ctx); // Uses nested context
                          try {
                            await localRef
                                .read(moodControllerProvider)
                                .updateMood(label);
                            if (ctx.mounted) {
                              AppToast.show(
                                ctx,
                                'Mood saved!',
                                type: AppToastType.success,
                              );
                            }
                          } catch (e) {
                            if (ctx.mounted) {
                              AppToast.show(
                                ctx,
                                'Failed to save mood',
                                type: AppToastType.error,
                              );
                            }
                          }
                        },
                        borderRadius: AppRadius.cardRadius,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              mood.emoji,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              mood.label,
                              style: AppTextStyles.bodyS.copyWith(
                                color: isDark
                                    ? AppNeutral.n400
                                    : AppNeutral.n700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MoodPreset {
  final String emoji;
  final String label;
  const _MoodPreset({required this.emoji, required this.label});
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
