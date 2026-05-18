import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_radius.dart';
import 'app_button.dart';

class AppModal extends StatelessWidget {
  final String title;
  final String? description;
  final Widget child;
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;
  final bool isLoading;
  final bool isDangerPrimary;
  final IconData? icon;

  const AppModal({
    super.key,
    required this.title,
    this.description,
    required this.child,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimary,
    required this.onSecondary,
    this.isLoading = false,
    this.isDangerPrimary = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
      backgroundColor: isDark ? AppNeutral.n800 : Colors.white,
      surfaceTintColor: Colors.transparent,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      (isDangerPrimary
                              ? AppSemantic.error
                              : AppColors.primary500)
                          .withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isDangerPrimary
                      ? AppSemantic.error
                      : AppColors.primary500,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
            ],
            Text(title, style: AppTextStyles.h3, textAlign: TextAlign.center),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: AppTextStyles.bodyM.copyWith(
                  color: isDark ? AppNeutral.n400 : AppNeutral.n600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            child,
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: secondaryLabel,
                    variant: AppButtonVariant.outline,
                    onPressed: onSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: primaryLabel,
                    isLoading: isLoading,
                    variant: isDangerPrimary
                        ? AppButtonVariant.danger
                        : AppButtonVariant.primary,
                    onPressed: onPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Standardized stylized bottom sheet that features correct rounded corners and drag handles.
  static Future<T?> showSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: isDark ? AppNeutral.n900 : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
      builder: (context) => SafeArea(
        bottom: true,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppNeutral.n700 : AppNeutral.n200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
