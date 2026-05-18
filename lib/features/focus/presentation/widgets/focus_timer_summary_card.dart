import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/theme/app_icons.dart';

class FocusTimerSummaryCard extends StatelessWidget {
  final int focusMinutes;
  final VoidCallback onStart;

  const FocusTimerSummaryCard({
    super.key,
    required this.focusMinutes,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      onTap: onStart,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED), // Rich Deep Purple
              shape: BoxShape.circle,
            ),
            child: const Icon(AppIcons.focus, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Focus Timer',
                  style: AppTextStyles.h3.copyWith(
                    color: isDark ? Colors.white : AppNeutral.n900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  focusMinutes > 0
                      ? 'Focused for $focusMinutes mins today'
                      : 'Ready for a deep work session?',
                  style: AppTextStyles.bodyS.copyWith(
                    color: AppNeutral.n500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(AppIcons.arrowRight, color: AppNeutral.n400, size: 24),
        ],
      ),
    );
  }
}
