import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_icons.dart';

enum AppToastType { success, warning, error, info }

class AppToast extends StatelessWidget {
  final String message;
  final AppToastType type;

  const AppToast({super.key, required this.message, required this.type});

  Color get background {
    switch (type) {
      case AppToastType.success:
        return AppSemantic.success;
      case AppToastType.warning:
        return AppSemantic.warning;
      case AppToastType.error:
        return AppSemantic.error;
      case AppToastType.info:
        return AppNeutral.n800;
    }
  }

  IconData get icon {
    switch (type) {
      case AppToastType.success:
        return AppIcons.success;
      case AppToastType.warning:
        return AppIcons.warning;
      case AppToastType.error:
        return AppIcons.error;
      case AppToastType.info:
        return AppIcons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: background,
            borderRadius: const BorderRadius.all(AppRadius.pill),
            boxShadow: const [AppShadows.float],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  message,
                  style: AppTextStyles.bodyM.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext context,
    String message, {
    AppToastType type = AppToastType.info,
  }) {
    final overlay = Overlay.of(context);

    // Dismiss any existing toast before inserting a new one
    if (_currentEntry != null && _currentEntry!.mounted) {
      _currentEntry!.remove();
      _currentEntry = null;
    }

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).padding.bottom + 32,
        left: 24,
        right: 24,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.down,
            onDismissed: (_) {
              entry.remove();
              if (_currentEntry == entry) _currentEntry = null;
            },
            child: AppToast(message: message, type: type)
                .animate()
                .fadeIn(duration: 250.ms)
                .slideY(begin: 0.5, end: 0, curve: Curves.easeOutBack),
          ),
        ),
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (entry.mounted) {
        entry.remove();
        if (_currentEntry == entry) _currentEntry = null;
      }
    });
  }
}
