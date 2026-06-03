import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_radius.dart';
import '../theme/app_icons.dart';
import '../widgets/app_modal.dart';
import '../widgets/app_button.dart';
import '../widgets/app_toast.dart';
import '../widgets/app_input.dart';
import '../../features/sleep/presentation/providers/sleep_providers.dart';
import '../../features/mood/presentation/providers/mood_providers.dart';
import '../../features/water/presentation/providers/water_providers.dart';

class FeatureSheetService {
  static Future<void> showSleepSheet(BuildContext context, WidgetRef ref) async {
    final current = ref.read(todaySleepProvider);
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
    String quality = current?.quality ?? 'good';

    return AppModal.showSheet(
      context: context,
      child: StatefulBuilder(
        builder: (ctx, setState) {
          Future<void> pickTime(bool isSleep) async {
            final tm = await showTimePicker(
              context: ctx,
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

          final isDark = Theme.of(ctx).brightness == Brightness.dark;

          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Sleep Log', style: AppTextStyles.h2),
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
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
                      finalSleep = finalSleep.subtract(const Duration(days: 1));
                    }
                    try {
                      await ref
                          .read(todaySleepProvider.notifier)
                          .logSleep(
                            sleepTime: finalSleep,
                            wakeTime: finalWake,
                            quality: quality,
                          );
                      if (ctx.mounted) Navigator.pop(ctx);
                    } catch (e) {
                      if (ctx.mounted) {
                        AppToast.show(
                          ctx,
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
      ),
    );
  }

  static Future<void> showWaterSheet(BuildContext context, WidgetRef ref) async {
    return AppModal.showSheet(
      context: context,
      child: _FeatureWaterSheet(ref: ref),
    );
  }

  static Future<void> showMoodSheet(BuildContext context, WidgetRef ref) async {
    final moods = const [
      _MoodPreset(emoji: '😩', label: 'Tired'),
      _MoodPreset(emoji: '😔', label: 'Bad'),
      _MoodPreset(emoji: '😐', label: 'Okay'),
      _MoodPreset(emoji: '😊', label: 'Good'),
      _MoodPreset(emoji: '🤩', label: 'Great'),
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppModal.showSheet(
      context: context,
      child: Padding(
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
                      Navigator.pop(context);
                      try {
                        await ref
                            .read(moodControllerProvider)
                            .updateMood(label);
                        if (context.mounted) {
                          AppToast.show(
                            context,
                            'Mood saved!',
                            type: AppToastType.success,
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          AppToast.show(
                            context,
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
      ),
    );
  }
}

class _MoodPreset {
  final String emoji;
  final String label;
  const _MoodPreset({required this.emoji, required this.label});
}

class _FeatureWaterSheet extends StatefulWidget {
  final WidgetRef ref;
  const _FeatureWaterSheet({required this.ref});

  @override
  State<_FeatureWaterSheet> createState() => _FeatureWaterSheetState();
}

class _FeatureWaterSheetState extends State<_FeatureWaterSheet> {
  late final TextEditingController _customCtrl;

  @override
  void initState() {
    super.initState();
    _customCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Add Water Intake', style: AppTextStyles.h2),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _waterPreset(150, 'Glass'),
              _waterPreset(250, 'Normal'),
              _waterPreset(500, 'Bottle'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: AppInput(
                  label: 'Custom Amount',
                  hint: 'Amount in ml',
                  controller: _customCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AppButton(
                label: 'Add',
                size: AppButtonSize.md,
                onPressed: () async {
                  final text = _customCtrl.text.trim();
                  if (text.isNotEmpty) {
                    final amount = int.tryParse(text);
                    if (amount != null && amount > 0) {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                      try {
                        await widget.ref.read(waterControllerProvider).logWater(amount);
                        if (context.mounted) {
                          AppToast.show(
                            context,
                            'Added ${amount}ml water!',
                            type: AppToastType.success,
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          AppToast.show(
                            context,
                            e.toString().replaceAll('Exception: ', ''),
                            type: AppToastType.error,
                          );
                        }
                      }
                    }
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _waterPreset(int amount, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () async {
        Navigator.pop(context);
        try {
          await widget.ref.read(waterControllerProvider).logWater(amount);
          if (context.mounted) {
            AppToast.show(
              context,
              'Added ${amount}ml water!',
              type: AppToastType.success,
            );
          }
        } catch (e) {
          if (context.mounted) {
            AppToast.show(
              context,
              e.toString().replaceAll('Exception: ', ''),
              type: AppToastType.error,
            );
          }
        }
      },
      borderRadius: AppRadius.cardRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
}
