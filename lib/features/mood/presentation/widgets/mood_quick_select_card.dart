import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_card.dart';

class MoodQuickSelectCard extends StatelessWidget {
  final String? selectedMood;
  final Function(String) onSelect;

  const MoodQuickSelectCard({
    super.key,
    this.selectedMood,
    required this.onSelect,
  });

  static const List<Map<String, String>> _moods = [
    {'emoji': '😩', 'label': 'Tired'},
    {'emoji': '😔', 'label': 'Bad'},
    {'emoji': '😐', 'label': 'Okay'},
    {'emoji': '😊', 'label': 'Good'},
    {'emoji': '🤩', 'label': 'Great'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling?',
            style: AppTextStyles.h3.copyWith(
              color: isDark ? Colors.white : AppNeutral.n900,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _moods.map((mood) {
              final isSelected =
                  selectedMood?.toLowerCase() == mood['label']!.toLowerCase();
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onSelect(mood['label']!);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary500.withAlpha(20)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary500
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: AppRadius.cardRadius,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          mood['emoji']!,
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          mood['label']!,
                          style: AppTextStyles.bodyS.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary600
                                : (isDark ? AppNeutral.n400 : AppNeutral.n500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
