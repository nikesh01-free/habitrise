import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/presentation/providers/settings_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';

class AppCard extends ConsumerStatefulWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final bool selected;
  final bool error;
  final Color? backgroundColor;
  final IconData? leadingIcon;
  final Color? iconColor;
  final BoxBorder? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.selected = false,
    this.error = false,
    this.backgroundColor,
    this.leadingIcon,
    this.iconColor,
    this.border,
  });

  @override
  ConsumerState<AppCard> createState() => _AppCardState();
}

class _AppCardState extends ConsumerState<AppCard> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() => _scale = 0.975);
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      setState(() => _scale = 1.0);
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) {
      setState(() => _scale = 1.0);
    }
  }

  Color _resolveBackground(bool isDark) {
    if (widget.backgroundColor != null) {
      return widget.backgroundColor!;
    }

    return isDark ? AppNeutral.n800 : Colors.white;
  }

  BoxBorder? _resolveBorder(bool isDark) {
    if (widget.border != null) {
      return widget.border;
    }

    if (widget.error) {
      return Border.all(color: AppSemantic.error, width: 1.4);
    }

    if (widget.selected) {
      return Border.all(color: AppColors.primary500, width: 1.4);
    }

    if (isDark) {
      return Border.all(color: AppNeutral.n700, width: 1);
    }

    return Border.all(color: AppNeutral.n100, width: 1);
  }

  List<BoxShadow>? _resolveShadow(bool isDark) {
    if (isDark) {
      return null;
    }

    if (widget.error) {
      return const [
        BoxShadow(
          color: Color(0x18F25C6E),
          blurRadius: 18,
          offset: Offset(0, 8),
        ),
      ];
    }

    if (widget.selected) {
      return const [
        BoxShadow(
          color: Color(0x204F6EF7),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ];
    }

    return const [AppShadows.card];
  }

  Widget _buildLeadingIcon(bool isDark) {
    final iconColor = widget.iconColor ?? AppColors.primary500;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: isDark ? 0.16 : 0.12),
        shape: BoxShape.circle,
        border: Border.all(
          color: iconColor.withValues(alpha: isDark ? 0.22 : 0.16),
        ),
      ),
      child: Icon(widget.leadingIcon, color: iconColor, size: 24),
    );
  }

  Widget _buildContent(bool isDark) {
    if (widget.leadingIcon == null) {
      return widget.child;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildLeadingIcon(isDark),
        const SizedBox(width: 16),
        Expanded(child: widget.child),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSystemReduced = MediaQuery.of(context).accessibleNavigation;
    final isAppReduced = ref.watch(settingsProvider).reducedMotionEnabled;
    final shouldReduceMotion = isSystemReduced || isAppReduced;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final card = AnimatedContainer(
      duration: shouldReduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: _resolveBackground(isDark),
        borderRadius: AppRadius.cardRadius,
        border: _resolveBorder(isDark),
        boxShadow: _resolveShadow(isDark),
      ),
      child: _buildContent(isDark),
    );

    Widget result = card;

    if (widget.onTap != null) {
      result = GestureDetector(
        onTapDown: shouldReduceMotion ? null : _onTapDown,
        onTapUp: shouldReduceMotion ? null : _onTapUp,
        onTapCancel: shouldReduceMotion ? null : _onTapCancel,
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap?.call();
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: shouldReduceMotion ? 1.0 : _scale,
          duration: shouldReduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: result,
        ),
      );
    }

    return Semantics(
      button: widget.onTap != null,
      selected: widget.selected,
      child: result,
    );
  }
}
