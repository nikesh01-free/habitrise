import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_modal.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../water/presentation/water_history_screen.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/app_button.dart';

class WaterProgressCard extends StatelessWidget {
  final int currentMl;
  final int goalMl;
  final Function(int amount) onAdd;
  final VoidCallback onReset;

  const WaterProgressCard({
    super.key,
    required this.currentMl,
    this.goalMl = 2500,
    required this.onAdd,
    required this.onReset,
  });

  void _showQuickActions(BuildContext context) {
    AppModal.showSheet(
      context: context,
      child: _WaterActionSheet(
        onAdd: onAdd,
        onResetTap: () {
          Navigator.pop(context);
          _confirmReset(context);
        },
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AppModal(
        title: 'Reset Hydration?',
        description: 'This will clear all water data recorded today.',
        primaryLabel: 'Reset',
        secondaryLabel: 'Cancel',
        onPrimary: () {
          Navigator.pop(ctx);
          onReset();
        },
        onSecondary: () => Navigator.pop(ctx),
        icon: AppIcons.reset,
        isDangerPrimary: true,
        child: const SizedBox.shrink(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double pct = (currentMl / goalMl).clamp(0.0, 1.0);

    // Design spec asks for explicit feature color bg in Light Mode
    final Color cardBg = isDark ? AppNeutral.n800 : AppFeatureColors.waterBg;
    final Color contentColor = AppFeatureColors.waterIcon;

    return AppCard(
      backgroundColor: cardBg,
      padding: const EdgeInsets.all(16),
      onTap: () => _showQuickActions(context),
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
                child: Icon(AppIcons.water, color: contentColor, size: 20),
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
                  text: '$currentMl',
                  style: AppTextStyles.h3.copyWith(
                    color: isDark ? Colors.white : AppNeutral.n900,
                  ),
                ),
                TextSpan(
                  text: '/$goalMl',
                  style: AppTextStyles.bodyS.copyWith(
                    color: isDark ? AppNeutral.n400 : AppNeutral.n500,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: ' ml',
                  style: AppTextStyles.bodyS.copyWith(
                    color: isDark ? AppNeutral.n500 : AppNeutral.n700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Water Intake',
                style: AppTextStyles.bodyS.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppNeutral.n400 : AppNeutral.n600,
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WaterHistoryScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View History',
                      style: AppTextStyles.bodyS.copyWith(
                        color: contentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 12,
                      color: contentColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WaterActionSheet extends StatefulWidget {
  final Function(int) onAdd;
  final VoidCallback onResetTap;
  const _WaterActionSheet({required this.onAdd, required this.onResetTap});

  @override
  State<_WaterActionSheet> createState() => _WaterActionSheetState();
}

class _WaterActionSheetState extends State<_WaterActionSheet> {
  bool _reminders = false;
  late final TextEditingController _customCtrl;

  @override
  void initState() {
    super.initState();
    _customCtrl = TextEditingController();
    _fetchPref();
  }

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchPref() async {
    final res = await NotificationService().getReminderPreference('water');
    if (mounted) setState(() => _reminders = res);
  }

  Future<void> _toggle(bool val) async {
    setState(() => _reminders = val);
    await NotificationService().saveReminderPreference('water', val);
    if (val) {
      await NotificationService().requestPermissions();
      await NotificationService().scheduleWaterReminder(2);
    } else {
      await NotificationService().cancelWaterReminder();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Log Water', style: AppTextStyles.h2),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickBtn(250),
              _buildQuickBtn(500),
              _buildQuickBtn(750),
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
                onPressed: () {
                  final text = _customCtrl.text.trim();
                  if (text.isNotEmpty) {
                    final amount = int.tryParse(text);
                    if (amount != null && amount > 0) {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                      widget.onAdd(amount);
                    }
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppNeutral.n800 : AppNeutral.n50,
              borderRadius: AppRadius.cardRadius,
            ),
            child: SwitchListTile(
              activeThumbColor: AppFeatureColors.waterIcon,
              title: Text(
                'Reminders',
                style: AppTextStyles.bodyM.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Prompt hourly drinking',
                style: AppTextStyles.bodyS,
              ),
              value: _reminders,
              onChanged: _toggle,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onResetTap,
                  icon: const Icon(AppIcons.reset, size: 18),
                  label: const Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppSemantic.error,
                    side: const BorderSide(color: AppSemantic.error),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.buttonRadius,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WaterHistoryScreen(),
                      ),
                    );
                  },
                  icon: const Icon(AppIcons.history, size: 18),
                  label: const Text('History'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary500,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.buttonRadius,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickBtn(int val) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.pop(context);
        widget.onAdd(val);
      },
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppNeutral.n800 : AppFeatureColors.waterBg,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(color: AppFeatureColors.waterIcon.withAlpha(40)),
        ),
        child: Column(
          children: [
            Icon(AppIcons.water, color: AppFeatureColors.waterIcon),
            const SizedBox(height: 8),
            Text(
              '+$val',
              style: AppTextStyles.bodyM.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppNeutral.n900,
              ),
            ),
            Text(
              'ml',
              style: AppTextStyles.bodyS.copyWith(color: AppNeutral.n500),
            ),
          ],
        ),
      ),
    );
  }
}
