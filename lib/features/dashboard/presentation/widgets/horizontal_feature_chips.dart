import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

class HorizontalFeatureChips extends ConsumerWidget {
  final Map<String, GlobalKey> anchors;

  const HorizontalFeatureChips({
    super.key,
    required this.anchors,
  });

  void _scrollToSection(String key) {
    final anchorKey = anchors[key];
    if (anchorKey != null && anchorKey.currentContext != null) {
      Scrollable.ensureVisible(
        anchorKey.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<_FeatureChipData> chips = [
      _FeatureChipData(label: 'Habits', key: 'habits', icon: AppIcons.habits, color: AppFeatureColors.habitIcon),
      _FeatureChipData(label: 'Health', key: 'health', icon: Icons.favorite_rounded, color: AppColors.primary500),
      _FeatureChipData(label: 'Focus', key: 'focus', icon: AppIcons.focus, color: AppFeatureColors.focusIcon),
      if (settings.gymFeatureEnabled)
        _FeatureChipData(label: 'Gym', key: 'gym', icon: Icons.fitness_center_rounded, color: AppFeatureColors.gymIcon),
    ];

    return Container(
      height: 38,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: chips.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final chip = chips[index];
          return ActionChip(
            onPressed: () => _scrollToSection(chip.key),
            backgroundColor: isDark ? AppNeutral.n800 : Colors.white,
            side: BorderSide(
              color: isDark ? AppNeutral.n700 : AppNeutral.n200,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            avatar: Icon(
              chip.icon,
              size: 14,
              color: chip.color,
            ),
            label: Text(
              chip.label,
              style: AppTextStyles.bodyS.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppNeutral.n900,
                fontSize: 12,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FeatureChipData {
  final String label;
  final String key;
  final IconData icon;
  final Color color;

  const _FeatureChipData({
    required this.label,
    required this.key,
    required this.icon,
    required this.color,
  });
}
