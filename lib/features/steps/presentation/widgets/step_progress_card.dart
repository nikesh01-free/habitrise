import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_modal.dart';
import '../../../../core/theme/app_icons.dart';

class StepProgressCard extends StatelessWidget {
  final int steps;
  final int goalSteps;
  final bool isPermissionGranted;
  final bool isSensorAvailable;
  final VoidCallback? onRequestPermission;
  final Function(int amount)? onAddManual;

  const StepProgressCard({
    super.key,
    required this.steps,
    required this.goalSteps,
    this.isPermissionGranted = true,
    this.isSensorAvailable = true,
    this.onRequestPermission,
    this.onAddManual,
  });

  void _showMenu(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    AppModal.showSheet(
      context: context,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Step Tracker', style: AppTextStyles.h2),
            const SizedBox(height: 24),
            if (!isPermissionGranted) ...[
              ListTile(
                tileColor: isDark ? AppNeutral.n800 : AppNeutral.n50,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.cardRadius,
                ),
                leading: const Icon(AppIcons.unlock, color: Colors.orange),
                title: Text(
                  'Enable Auto Counting',
                  style: AppTextStyles.bodyM.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text('Requires sensor permission'),
                onTap: () {
                  Navigator.pop(context);
                  onRequestPermission?.call();
                },
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(child: _buildManualBtn(context, 500)),
                const SizedBox(width: 16),
                Expanded(child: _buildManualBtn(context, 1000)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualBtn(BuildContext context, int amt) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onAddManual?.call(amt);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppNeutral.n800 : AppFeatureColors.stepBg,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(color: AppFeatureColors.stepIcon.withAlpha(40)),
        ),
        child: Column(
          children: [
            Icon(AppIcons.add, color: AppFeatureColors.stepIcon),
            const SizedBox(height: 4),
            Text(
              '+$amt',
              style: AppTextStyles.bodyM.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppNeutral.n900,
              ),
            ),
            Text(
              'steps',
              style: AppTextStyles.bodyS.copyWith(color: AppNeutral.n500),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double pct = goalSteps > 0
        ? (steps / goalSteps).clamp(0.0, 1.0)
        : 0.0;

    final Color cardBg = isDark ? AppNeutral.n800 : AppFeatureColors.stepBg;
    final Color contentColor = AppFeatureColors.stepIcon;

    return AppCard(
      backgroundColor: cardBg,
      padding: const EdgeInsets.all(16),
      onTap: () => _showMenu(context),
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
                child: Icon(AppIcons.steps, color: contentColor, size: 20),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      value: 1,
                      strokeWidth: 3.5,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        contentColor.withAlpha(40),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: pct),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutExpo,
                      builder: (_, val, _) => CircularProgressIndicator(
                        value: val,
                        strokeWidth: 3.5,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(contentColor),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$steps',
                  style: AppTextStyles.h3.copyWith(
                    color: isDark ? Colors.white : AppNeutral.n900,
                  ),
                ),
                TextSpan(
                  text: '/$goalSteps',
                  style: AppTextStyles.bodyS.copyWith(
                    color: isDark ? AppNeutral.n400 : AppNeutral.n500,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Steps Taken',
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
