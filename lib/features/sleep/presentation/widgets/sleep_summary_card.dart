import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_modal.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../sleep/presentation/providers/sleep_providers.dart';

class SleepSummaryCard extends ConsumerWidget {
  const SleepSummaryCard({super.key});

  Future<void> _openLogSleep(BuildContext context, WidgetRef ref) async {
    final current = ref.read(todaySleepProvider);

    final now = DateTime.now();
    DateTime defaultSleep = DateTime(
      now.year,
      now.month,
      now.day - 1,
      22,
      0,
    ); // 10:00 PM previous day
    DateTime defaultWake = DateTime(
      now.year,
      now.month,
      now.day,
      7,
      0,
    ); // 7:00 AM today

    DateTime sleepTime = current?.sleepTime ?? defaultSleep;
    DateTime wakeTime = current?.wakeTime ?? defaultWake;
    String quality = current?.quality ?? 'good';

    AppModal.showSheet(
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
              final now = DateTime.now();
              final combined = DateTime(
                now.year,
                now.month,
                now.day,
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

                    // Auto-handle midnight boundary
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
                        final msg = e.toString().replaceAll('Exception: ', '');
                        AppToast.show(
                          ctx,
                          msg.isNotEmpty ? msg : 'Error saving log',
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sleep = ref.watch(todaySleepProvider);

    final hrs = sleep != null ? (sleep.totalMinutes / 60) : 0.0;
    final String display = sleep != null ? '${hrs.toStringAsFixed(1)}h' : '--';

    final Color cardBg = isDark ? AppNeutral.n800 : AppFeatureColors.sleepBg;
    final Color contentColor = AppFeatureColors.sleepIcon;

    return AppCard(
      backgroundColor: cardBg,
      padding: const EdgeInsets.all(16),
      onTap: () => _openLogSleep(context, ref),
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
                child: Icon(AppIcons.sleep, color: contentColor, size: 20),
              ),
              Icon(
                AppIcons.addCircle,
                color: contentColor.withAlpha(100),
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            display,
            style: AppTextStyles.h3.copyWith(
              color: isDark ? Colors.white : AppNeutral.n900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hours Slept',
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
