import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../sleep/presentation/providers/sleep_providers.dart';
import '../../../../core/services/feature_sheet_service.dart';

class SleepSummaryCard extends ConsumerWidget {
  const SleepSummaryCard({super.key});

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
      onTap: () => FeatureSheetService.showSleepSheet(context, ref),
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
