import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitrise/core/theme/app_colors.dart';
import 'package:habitrise/core/theme/app_text_styles.dart';
import 'package:habitrise/core/theme/app_radius.dart';
import 'package:habitrise/core/widgets/app_toast.dart';
import 'package:habitrise/features/focus/presentation/providers/focus_providers.dart';
import 'package:habitrise/features/focus/presentation/widgets/focus_timer_summary_card.dart';
import 'package:habitrise/features/mood/presentation/providers/mood_providers.dart';

class DashboardFocusMoodSection extends ConsumerStatefulWidget {
  final VoidCallback onStartFocus;

  const DashboardFocusMoodSection({
    super.key,
    required this.onStartFocus,
  });

  @override
  ConsumerState<DashboardFocusMoodSection> createState() => _DashboardFocusMoodSectionState();
}

class _DashboardFocusMoodSectionState extends ConsumerState<DashboardFocusMoodSection> {
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isExpanded = prefs.getBool('section_collapsed_focus') != true;
      });
    }
  }

  Future<void> _toggleState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isExpanded = !_isExpanded;
      prefs.setBool('section_collapsed_focus', !_isExpanded);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentFocus = ref.watch(todayFocusMinutesProvider);
    final moodAsync = ref.watch(todayMoodProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _toggleState,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Focus & Mood',
                    style: AppTextStyles.h3.copyWith(
                      color: isDark ? Colors.white : AppNeutral.n900,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  color: isDark ? AppNeutral.n400 : AppNeutral.n600,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded) ...[
          const SizedBox(height: 16),
          FocusTimerSummaryCard(
            focusMinutes: currentFocus,
            onStart: widget.onStartFocus,
          ),
          const SizedBox(height: 12),
          _buildMoodCard(context, ref, moodAsync, isDark),
        ],
      ],
    );
  }

  Widget _buildMoodCard(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<dynamic> moodAsync,
    bool isDark,
  ) {
    final moods = [
      _MoodOption(emoji: '😴', label: 'Tired', value: 'tired'),
      _MoodOption(emoji: '😔', label: 'Low', value: 'bad'),
      _MoodOption(emoji: '😐', label: 'Okay', value: 'okay'),
      _MoodOption(emoji: '😊', label: 'Good', value: 'good'),
      _MoodOption(emoji: '🤩', label: 'Great', value: 'great'),
    ];

    final selectedMood = moodAsync.valueOrNull?.mood?.toLowerCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppNeutral.n800 : Colors.white,
        borderRadius: AppRadius.cardRadius,
        border: isDark ? Border.all(color: AppNeutral.n700) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events, color: Colors.orange, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                'Mood',
                style: AppTextStyles.bodyM.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppNeutral.n900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: moods.map((mood) {
              final isSelected = selectedMood == mood.value;
              return GestureDetector(
                onTap: () async {
                  try {
                    await ref.read(moodControllerProvider).updateMood(mood.value);
                    if (context.mounted) {
                      AppToast.show(
                        context,
                        'Mood updated to ${mood.label}',
                        type: AppToastType.success,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      AppToast.show(context, 'Failed to update mood', type: AppToastType.error);
                    }
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.orange.withAlpha(40)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.orange
                          : (isDark ? AppNeutral.n700 : AppNeutral.n200),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    mood.emoji,
                    style: const TextStyle(fontSize: 20),
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

class _MoodOption {
  final String emoji;
  final String label;
  final String value;
  const _MoodOption({required this.emoji, required this.label, required this.value});
}