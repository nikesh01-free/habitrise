import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/app_assets.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../habits/data/models/habit_model.dart';
import '../providers/habit_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HabitSummaryCard extends ConsumerStatefulWidget {
  final List<HabitModel> habits;
  final Set<String> completedHabitIds;
  final VoidCallback onAddPressed;
  final Function(String habitId) onToggle;
  final Function(HabitModel habit) onEdit;

  const HabitSummaryCard({
    super.key,
    required this.habits,
    required this.completedHabitIds,
    required this.onAddPressed,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  ConsumerState<HabitSummaryCard> createState() => _HabitSummaryCardState();
}

class _HabitSummaryCardState extends ConsumerState<HabitSummaryCard> {
  Set<String> _prevCompletedIds = {};
  String? _animatingHabitId;

  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _prevCompletedIds = Set.from(widget.completedHabitIds);
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isExpanded = prefs.getBool('section_collapsed_habits') != true;
      });
    }
  }

  Future<void> _toggleState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isExpanded = !_isExpanded;
      prefs.setBool('section_collapsed_habits', !_isExpanded);
    });
  }

  @override
  void didUpdateWidget(covariant HabitSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Find newly completed habits
    final newlyCompleted = widget.completedHabitIds.difference(_prevCompletedIds);
    if (newlyCompleted.isNotEmpty) {
      final isReducedMotion = ref.read(settingsProvider).reducedMotionEnabled;
      if (!isReducedMotion) {
        setState(() {
          _animatingHabitId = newlyCompleted.first;
        });
        // Clear animation after some duration
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              if (_animatingHabitId == newlyCompleted.first) {
                _animatingHabitId = null;
              }
            });
          }
        });
      }
    }
    _prevCompletedIds = Set.from(widget.completedHabitIds);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.habits.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: AppEmptyState(
          assetPath: AppAssets.emptyHabits,
          icon: AppIcons.listChecks,
          title: 'No habits setup',
          description:
              'Ready to make a change? Add your first habit and start building consistency today.',
          buttonLabel: 'Create Habit',
          onPressed: widget.onAddPressed,
        ),
      );
    }

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
                    'Today\'s Habits',
                    style: AppTextStyles.h3.copyWith(
                      color: isDark ? Colors.white : AppNeutral.n900,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: widget.onAddPressed,
                  icon: const Icon(
                    AppIcons.add,
                    size: 18,
                    color: AppColors.primary600,
                  ),
                  label: Text(
                    'Add New',
                    style: AppTextStyles.bodyS.copyWith(
                      color: AppColors.primary600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  color: isDark ? AppNeutral.n400 : AppNeutral.n600,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded) ...[
          const SizedBox(height: 8),
          ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.habits.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final habit = widget.habits[index];
            final isDone = widget.completedHabitIds.contains(habit.id);
            final streak = ref.watch(habitStreakProvider(habit.id));
            final isAnimating = _animatingHabitId == habit.id;

            return AnimatedOpacity(
              opacity: isDone ? 0.6 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    onTap: () => widget.onEdit(habit),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDone
                                ? AppSemantic.success.withAlpha(30)
                                : (isDark
                                    ? AppColors.primary500.withAlpha(30)
                                    : AppColors.primary50),
                            borderRadius: AppRadius.cardRadius / 2,
                          ),
                          child: Icon(
                            _resolveIcon(habit.category),
                            size: 20,
                            color: isDone
                                ? AppSemantic.success
                                : AppColors.primary500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            habit.title,
                                            style: AppTextStyles.bodyM.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: isDark
                                                  ? Colors.white
                                                  : AppNeutral.n900,
                                              decoration: isDone
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        if (streak >= 2) ...[
                                          const SizedBox(width: 6),
                                          const Icon(
                                            Icons.local_fire_department,
                                            color: Colors.orange,
                                            size: 16,
                                          ),
                                          Text(
                                            '$streak',
                                            style: AppTextStyles.bodyS.copyWith(
                                              color: Colors.orange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (habit.isPinned)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 4),
                                      child: Icon(
                                        Icons.push_pin_rounded,
                                        size: 14,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppNeutral.n800
                                          : AppNeutral.n50,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: isDark
                                            ? AppNeutral.n700
                                            : AppNeutral.n200,
                                      ),
                                    ),
                                    child: Text(
                                      habit.category.toUpperCase(),
                                      style: AppTextStyles.bodyS.copyWith(
                                        color: AppNeutral.n500,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 9,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    habit.frequency.toUpperCase(),
                                    style: AppTextStyles.bodyS.copyWith(
                                      color: AppNeutral.n500,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            widget.onToggle(habit.id);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDone
                                  ? AppSemantic.success
                                  : Colors.transparent,
                              border: Border.all(
                                color: isDone
                                    ? AppSemantic.success
                                    : (isDark ? AppNeutral.n600 : AppNeutral.n300),
                                width: isDone ? 0 : 2,
                              ),
                            ),
                            child: isDone
                                ? const Icon(
                                    AppIcons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isAnimating)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Lottie.asset(
                          AppAssets.lottieConfetti,
                          repeat: false,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    ],
  );
}

  IconData _resolveIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'fitness':
        return AppIcons.dumbbell;
      case 'health':
        return AppIcons.heart;
      case 'mind':
      case 'wellness':
        return AppIcons.brain;
      case 'study':
      case 'work':
        return AppIcons.bookOpen;
      default:
        return AppIcons.zap;
    }
  }
}
