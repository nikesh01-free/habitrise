import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_icons.dart';
import 'app_button.dart';
import 'app_asset_image.dart';

class AppEmptyState extends StatelessWidget {
  final String? assetPath;
  final IconData? icon;
  final String title;
  final String description;
  final String? buttonLabel;
  final VoidCallback? onPressed;
  final double size;

  // Aliases for legacy parameters to ensure backwards compatibility
  const AppEmptyState({
    super.key,
    this.assetPath,
    this.icon,
    required this.title,
    required this.description,
    this.buttonLabel,
    this.onPressed,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (assetPath != null)
              AppAssetImage(
                assetPath: assetPath!,
                fallbackIcon: icon ?? AppIcons.info,
                width: size,
                height: size,
              )
            else
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppNeutral.n100.withAlpha(isDark ? 30 : 100),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ?? AppIcons.info,
                  size: size * 0.5,
                  color: AppNeutral.n400,
                ),
              ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.h3.copyWith(
                color: isDark ? Colors.white : AppNeutral.n900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyM.copyWith(
                color: AppNeutral.n500,
                height: 1.5,
              ),
            ),
            if (buttonLabel != null && onPressed != null) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: AppButton(label: buttonLabel!, onPressed: onPressed!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
