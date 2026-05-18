import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/presentation/providers/settings_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, danger }

enum AppButtonSize { sm, md, lg }

class AppButton extends ConsumerStatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
  });

  @override
  ConsumerState<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends ConsumerState<AppButton> {
  double _scale = 1.0;
  int _lastTapTime = 0;

  double get height {
    switch (widget.size) {
      case AppButtonSize.sm:
        return 38;
      case AppButtonSize.md:
        return 46;
      case AppButtonSize.lg:
        return 54;
    }
  }

  double get horizontalPadding {
    switch (widget.size) {
      case AppButtonSize.sm:
        return 14;
      case AppButtonSize.md:
        return 18;
      case AppButtonSize.lg:
        return 22;
    }
  }

  double get iconSize {
    switch (widget.size) {
      case AppButtonSize.sm:
        return 16;
      case AppButtonSize.md:
        return 19;
      case AppButtonSize.lg:
        return 21;
    }
  }

  TextStyle get textStyle {
    switch (widget.size) {
      case AppButtonSize.sm:
        return AppTextStyles.btn.copyWith(fontSize: 13);
      case AppButtonSize.md:
        return AppTextStyles.btn.copyWith(fontSize: 15);
      case AppButtonSize.lg:
        return AppTextStyles.btn.copyWith(fontSize: 16);
    }
  }

  Color _backgroundColor(bool isDark, bool disabled) {
    if (disabled) {
      if (widget.variant == AppButtonVariant.outline ||
          widget.variant == AppButtonVariant.ghost) {
        return Colors.transparent;
      }
      return isDark ? AppNeutral.n800 : AppNeutral.n200;
    }

    switch (widget.variant) {
      case AppButtonVariant.primary:
        return AppColors.primary500;
      case AppButtonVariant.secondary:
        return isDark ? AppNeutral.n800 : AppNeutral.n100;
      case AppButtonVariant.outline:
      case AppButtonVariant.ghost:
        return Colors.transparent;
      case AppButtonVariant.danger:
        return AppSemantic.error;
    }
  }

  Color _foregroundColor(bool isDark, bool disabled) {
    if (disabled) {
      return isDark ? AppNeutral.n600 : AppNeutral.n400;
    }

    switch (widget.variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.danger:
        return Colors.white;
      case AppButtonVariant.secondary:
      case AppButtonVariant.outline:
      case AppButtonVariant.ghost:
        return isDark ? Colors.white : AppNeutral.n900;
    }
  }

  Border? _border(bool isDark, bool disabled) {
    if (widget.variant == AppButtonVariant.outline) {
      return Border.all(
        color: disabled
            ? (isDark ? AppNeutral.n800 : AppNeutral.n200)
            : (isDark ? AppNeutral.n700 : AppNeutral.n300),
        width: 1.2,
      );
    }

    if (widget.variant == AppButtonVariant.secondary && isDark) {
      return Border.all(color: AppNeutral.n700, width: 1);
    }

    return null;
  }

  Gradient? _gradient(bool disabled) {
    if (disabled) return null;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary500, AppColors.primary600],
        );
      case AppButtonVariant.danger:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppSemantic.error, Color(0xFFE5485C)],
        );
      case AppButtonVariant.secondary:
      case AppButtonVariant.outline:
      case AppButtonVariant.ghost:
        return null;
    }
  }

  List<BoxShadow>? _shadow(bool disabled) {
    if (disabled) return null;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        return const [AppShadows.primary];
      case AppButtonVariant.danger:
        return const [
          BoxShadow(
            color: Color(0x30F25C6E),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ];
      case AppButtonVariant.secondary:
      case AppButtonVariant.outline:
      case AppButtonVariant.ghost:
        return null;
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _scale = 0.96);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _scale = 1.0);
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _scale = 1.0);
    }
  }

  void _handleTap() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastTapTime < 500) return;

    _lastTapTime = now;
    HapticFeedback.lightImpact();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final disabled = widget.onPressed == null || widget.isLoading;

    final isSystemReduced = MediaQuery.of(context).accessibleNavigation;
    final isAppReduced = ref.watch(settingsProvider).reducedMotionEnabled;
    final shouldReduceMotion = isSystemReduced || isAppReduced;

    final foregroundColor = _foregroundColor(isDark, disabled);
    final backgroundColor = _backgroundColor(isDark, disabled);

    Widget button = AnimatedContainer(
      duration: shouldReduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      height: height,
      width: widget.fullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        color: _gradient(disabled) == null ? backgroundColor : null,
        gradient: _gradient(disabled),
        borderRadius: AppRadius.buttonRadius,
        border: _border(isDark, disabled),
        boxShadow: _shadow(disabled),
      ),
      child: Center(
        child: widget.isLoading
            ? SizedBox(
                width: widget.size == AppButtonSize.sm ? 16 : 18,
                height: widget.size == AppButtonSize.sm ? 16 : 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: iconSize, color: foregroundColor),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textStyle.copyWith(
                          color: foregroundColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );

    if (!disabled) {
      button = GestureDetector(
        onTapDown: shouldReduceMotion ? null : _handleTapDown,
        onTapUp: shouldReduceMotion ? null : _handleTapUp,
        onTapCancel: shouldReduceMotion ? null : _handleTapCancel,
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: shouldReduceMotion ? 1.0 : _scale,
          duration: shouldReduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: button,
        ),
      );
    }

    return Semantics(
      button: true,
      enabled: !disabled,
      label: widget.label,
      child: button,
    );
  }
}
