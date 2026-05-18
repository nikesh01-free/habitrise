import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:habitrise/core/constants/app_assets.dart';
import 'package:habitrise/core/theme/app_colors.dart';
import 'package:habitrise/core/theme/app_icons.dart';
import 'package:habitrise/core/theme/app_radius.dart';
import 'package:habitrise/core/theme/app_shadows.dart';
import 'package:habitrise/core/theme/app_spacing.dart';
import 'package:habitrise/core/theme/app_text_styles.dart';
import 'package:habitrise/core/utils/app_date_utils.dart';
import 'package:habitrise/core/widgets/app_card.dart';
import 'package:habitrise/core/widgets/app_empty_state.dart';
import 'package:habitrise/core/widgets/app_loading_state.dart';

import 'providers/calendar_providers.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  final VoidCallback? onReturnHome;

  const CalendarScreen({super.key, this.onReturnHome});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppNeutral.n900 : AppNeutral.n50,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary500,
          onRefresh: () async {
            if (_selectedDay != null) {
              ref.invalidate(daySummaryProvider(_selectedDay!));
            }
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(child: _HeaderCard(selectedDay: _selectedDay)),
              SliverToBoxAdapter(
                child: _CalendarCard(
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  calendarFormat: _calendarFormat,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() => _calendarFormat = format);
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: _DayDetails(
                    key: ValueKey(_selectedDay?.toIso8601String()),
                    selectedDay: _selectedDay,
                    onReturnHome: widget.onReturnHome,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final DateTime? selectedDay;

  const _HeaderCard({required this.selectedDay});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.pageH,
        AppSpacing.lg,
        AppSpacing.pageH,
        AppSpacing.md,
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: AppRadius.cardRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF232738), Color(0xFF1A1D2E)]
              : const [AppColors.primary500, AppColors.primary600],
        ),
        boxShadow: isDark ? null : const [AppShadows.primary],
        border: Border.all(
          color: isDark ? AppNeutral.n700 : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: const Icon(AppIcons.calendar, color: Colors.white, size: 25),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _titleForDate(selectedDay),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  selectedDay != null
                      ? AppDateUtils.formatDateLabel(selectedDay!)
                      : 'Select a day to review progress',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyS.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: AppRadius.chipRadius,
            ),
            child: Text(
              'Offline',
              style: AppTextStyles.bodyS.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 260.ms).slideY(begin: -0.04);
  }

  static String _titleForDate(DateTime? selectedDay) {
    if (selectedDay == null) return 'Journey Timeline';

    final now = DateTime.now();
    if (AppDateUtils.isSameDate(selectedDay, now)) {
      return 'Today’s Progress';
    }

    return 'Daily Review';
  }
}

class _CalendarCard extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final CalendarFormat calendarFormat;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final void Function(CalendarFormat format) onFormatChanged;
  final void Function(DateTime focusedDay) onPageChanged;

  const _CalendarCard({
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppNeutral.n900;
    final mutedColor = isDark ? AppNeutral.n400 : AppNeutral.n500;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
      child: AppCard(
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 14),
        backgroundColor: isDark ? AppNeutral.n800 : Colors.white,
        border: Border.all(color: isDark ? AppNeutral.n700 : AppNeutral.n100),
        child: TableCalendar(
          firstDay: DateTime.now().subtract(const Duration(days: 365 * 2)),
          lastDay: DateTime.now().add(const Duration(days: 30)),
          focusedDay: focusedDay,
          calendarFormat: calendarFormat,
          startingDayOfWeek: StartingDayOfWeek.monday,
          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
          onDaySelected: onDaySelected,
          onFormatChanged: onFormatChanged,
          onPageChanged: onPageChanged,
          rowHeight: 48,
          daysOfWeekHeight: 34,
          availableCalendarFormats: const {
            CalendarFormat.month: 'Month',
            CalendarFormat.twoWeeks: '2 weeks',
            CalendarFormat.week: 'Week',
          },
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: AppTextStyles.bodyS.copyWith(
              fontWeight: FontWeight.w800,
              color: mutedColor,
            ),
            weekendStyle: AppTextStyles.bodyS.copyWith(
              fontWeight: FontWeight.w800,
              color: AppSemantic.error,
            ),
          ),
          calendarStyle: CalendarStyle(
            cellMargin: const EdgeInsets.all(5),
            todayDecoration: BoxDecoration(
              color: AppColors.primary500.withValues(
                alpha: isDark ? 0.22 : 0.12,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary500.withValues(alpha: 0.55),
              ),
            ),
            todayTextStyle: AppTextStyles.bodyM.copyWith(
              color: isDark ? Colors.white : AppColors.primary600,
              fontWeight: FontWeight.w800,
            ),
            selectedDecoration: const BoxDecoration(
              color: AppColors.primary500,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: AppTextStyles.bodyM.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
            defaultTextStyle: AppTextStyles.bodyM.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
            weekendTextStyle: AppTextStyles.bodyM.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
            outsideTextStyle: AppTextStyles.bodyM.copyWith(
              color: isDark ? AppNeutral.n700 : AppNeutral.n300,
              fontWeight: FontWeight.w600,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: true,
            formatButtonShowsNext: false,
            titleCentered: true,
            headerPadding: const EdgeInsets.only(bottom: 10),
            titleTextStyle: AppTextStyles.h3.copyWith(
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
            formatButtonPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            formatButtonDecoration: BoxDecoration(
              color: isDark ? AppNeutral.n700 : AppNeutral.n100,
              borderRadius: AppRadius.chipRadius,
              border: Border.all(
                color: isDark ? AppNeutral.n600 : AppNeutral.n200,
              ),
            ),
            formatButtonTextStyle: AppTextStyles.bodyS.copyWith(
              color: textColor,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
            leftChevronMargin: EdgeInsets.zero,
            rightChevronMargin: EdgeInsets.zero,
            leftChevronIcon: _ChevronButton(
              icon: AppIcons.arrowLeft,
              isDark: isDark,
            ),
            rightChevronIcon: _ChevronButton(
              icon: AppIcons.arrowRight,
              isDark: isDark,
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 260.ms, delay: 80.ms).slideY(begin: 0.03);
  }
}

class _ChevronButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;

  const _ChevronButton({required this.icon, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: isDark ? AppNeutral.n700 : AppNeutral.n100,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: isDark ? Colors.white70 : AppNeutral.n700,
        size: 18,
      ),
    );
  }
}

class _DayDetails extends ConsumerWidget {
  final DateTime? selectedDay;
  final VoidCallback? onReturnHome;

  const _DayDetails({
    super.key,
    required this.selectedDay,
    required this.onReturnHome,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (selectedDay == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summaryAsync = ref.watch(daySummaryProvider(selectedDay!));

    return summaryAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.pageH),
        child: AppLoadingState(count: 2),
      ),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.all(AppSpacing.pageH),
        child: AppEmptyState(
          icon: AppIcons.error,
          title: 'Unable to load this day',
          description: 'Something went wrong while reading local records.',
        ),
      ),
      data: (summary) {
        if (!summary.hasData) {
          return AppEmptyState(
            assetPath: AppAssets.emptyCalendar,
            icon: AppIcons.calendar,
            title: 'No records here',
            description:
                'No entries found for ${AppDateUtils.formatDateLabel(selectedDay!)}. Start tracking today to build your timeline.',
            buttonLabel: 'Return to Today',
            onPressed: onReturnHome ?? () => Navigator.maybePop(context),
            size: 150,
          ).animate().fadeIn(duration: 240.ms);
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageH,
            AppSpacing.xxl,
            AppSpacing.pageH,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DayScoreCard(
                summary: summary,
                selectedDay: selectedDay!,
                isDark: isDark,
              ),
              const SizedBox(height: AppSpacing.xl),
              _SectionHeader(
                title: 'Day Breakdown',
                subtitle: 'Your local progress summary',
                isDark: isDark,
              ),
              const SizedBox(height: AppSpacing.md),
              _FeatureSummaryList(summary: summary),
            ],
          ),
        ).animate().fadeIn(duration: 260.ms).slideY(begin: 0.035);
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDark;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: AppTextStyles.bodyS.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: isDark ? AppNeutral.n400 : AppNeutral.n500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: AppTextStyles.bodyS.copyWith(
                  color: isDark ? AppNeutral.n500 : AppNeutral.n500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DayScoreCard extends StatelessWidget {
  final DaySummary summary;
  final DateTime selectedDay;
  final bool isDark;

  const _DayScoreCard({
    required this.summary,
    required this.selectedDay,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final completionPercent = _completionPercent(summary);
    final message = _message(completionPercent);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      backgroundColor: isDark ? AppNeutral.n800 : Colors.white,
      border: Border.all(color: isDark ? AppNeutral.n700 : AppNeutral.n100),
      child: Row(
        children: [
          _ProgressRing(percent: completionPercent, isDark: isDark),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppDateUtils.formatDateLabel(selectedDay),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h4.copyWith(
                    color: isDark ? Colors.white : AppNeutral.n900,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyS.copyWith(
                    color: completionPercent >= 100
                        ? AppSemantic.success
                        : isDark
                        ? AppNeutral.n400
                        : AppNeutral.n500,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _ScoreIcon(percent: completionPercent),
        ],
      ),
    );
  }

  static double _completionPercent(DaySummary summary) {
    final parts = <double>[];

    if (summary.habitsTotal > 0) {
      parts.add(summary.habitsCompleted / summary.habitsTotal);
    }

    if (summary.waterTotalMl > 0) parts.add(1);
    if (summary.stepsTotal > 0) parts.add(1);
    if (summary.focusMinutes > 0) parts.add(1);
    if (summary.mealsCompleted > 0) parts.add(1);
    if (summary.sleepMinutes > 0) parts.add(1);
    if (summary.mood != null) parts.add(1);

    if (parts.isEmpty) return 0;

    final total = parts.fold<double>(0, (sum, item) => sum + item);
    return (total / parts.length * 100).clamp(0, 100);
  }

  static String _message(double percent) {
    if (percent >= 100) return 'Perfect day. Every tracked goal was completed.';
    if (percent >= 70) return 'Strong day. Your consistency is building.';
    if (percent >= 40) return 'Good start. A few more actions can improve it.';
    return 'Small steps still count. Keep moving forward.';
  }
}

class _ProgressRing extends StatelessWidget {
  final double percent;
  final bool isDark;

  const _ProgressRing({required this.percent, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: percent / 100),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return CircularProgressIndicator(
                value: value,
                strokeWidth: 7,
                strokeCap: StrokeCap.round,
                backgroundColor: isDark ? AppNeutral.n700 : AppNeutral.n100,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary500,
                ),
              );
            },
          ),
        ),
        Text(
          '${percent.round()}%',
          style: AppTextStyles.bodyS.copyWith(
            color: isDark ? Colors.white : AppNeutral.n900,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _ScoreIcon extends StatelessWidget {
  final double percent;

  const _ScoreIcon({required this.percent});

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color color;

    if (percent >= 100) {
      icon = AppIcons.trophy;
      color = Colors.amber;
    } else if (percent >= 50) {
      icon = AppIcons.flame;
      color = AppColors.primary500;
    } else {
      icon = AppIcons.arrowRight;
      color = AppNeutral.n400;
    }

    return Icon(icon, color: color, size: 24);
  }
}

class _FeatureSummaryList extends StatelessWidget {
  final DaySummary summary;

  const _FeatureSummaryList({required this.summary});

  @override
  Widget build(BuildContext context) {
    final items = _items(summary);

    return Column(
      children: items.asMap().entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _DetailCard(item: entry.value)
              .animate()
              .fadeIn(delay: (90 + entry.key * 40).ms)
              .slideX(begin: 0.025),
        );
      }).toList(),
    );
  }

  List<_SummaryItem> _items(DaySummary summary) {
    final items = <_SummaryItem>[];

    if (summary.mood != null) {
      items.add(
        _SummaryItem(
          icon: AppIcons.mood,
          color: Colors.amber,
          title: 'Mood',
          value: _capitalize(summary.mood!),
          subtitle: 'How you felt',
        ),
      );
    }

    if (summary.habitsTotal > 0) {
      items.add(
        _SummaryItem(
          icon: AppIcons.listChecks,
          color: AppFeatureColors.habitIcon,
          title: 'Habits',
          value: '${summary.habitsCompleted}/${summary.habitsTotal}',
          subtitle: summary.habitsCompleted == summary.habitsTotal
              ? 'All done'
              : 'In progress',
        ),
      );
    }

    if (summary.waterTotalMl > 0) {
      items.add(
        _SummaryItem(
          icon: AppIcons.water,
          color: AppFeatureColors.waterIcon,
          title: 'Water',
          value: '${summary.waterTotalMl} ml',
          subtitle: 'Hydration',
        ),
      );
    }

    if (summary.stepsTotal > 0) {
      items.add(
        _SummaryItem(
          icon: AppIcons.steps,
          color: AppFeatureColors.stepIcon,
          title: 'Steps',
          value: '${summary.stepsTotal}',
          subtitle: 'Movement',
        ),
      );
    }

    if (summary.focusMinutes > 0) {
      items.add(
        _SummaryItem(
          icon: AppIcons.focus,
          color: AppFeatureColors.focusIcon,
          title: 'Focus',
          value: '${summary.focusMinutes} min',
          subtitle: 'Deep work',
        ),
      );
    }

    if (summary.mealsCompleted > 0) {
      items.add(
        _SummaryItem(
          icon: AppIcons.meals,
          color: AppFeatureColors.mealIcon,
          title: 'Meals',
          value: '${summary.mealsCompleted}',
          subtitle: 'Logged',
        ),
      );
    }

    if (summary.sleepMinutes > 0) {
      final hours = summary.sleepMinutes / 60;
      items.add(
        _SummaryItem(
          icon: AppIcons.sleep,
          color: AppFeatureColors.sleepIcon,
          title: 'Sleep',
          value: '${hours.toStringAsFixed(1)} hrs',
          subtitle: 'Recovery',
        ),
      );
    }

    return items;
  }

  static String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

class _SummaryItem {
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String subtitle;

  const _SummaryItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.subtitle,
  });
}

class _DetailCard extends StatelessWidget {
  final _SummaryItem item;

  const _DetailCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: isDark ? AppNeutral.n800 : Colors.white,
      border: Border.all(color: isDark ? AppNeutral.n700 : AppNeutral.n100),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: isDark ? 0.16 : 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: item.color.withValues(alpha: isDark ? 0.24 : 0.16),
              ),
            ),
            child: Icon(item.icon, color: item.color, size: 21),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyS.copyWith(
                    color: isDark ? AppNeutral.n400 : AppNeutral.n500,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h4.copyWith(
                    color: isDark ? Colors.white : AppNeutral.n900,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppNeutral.n700 : AppNeutral.n100,
              borderRadius: AppRadius.chipRadius,
            ),
            child: Text(
              item.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyS.copyWith(
                color: isDark ? AppNeutral.n300 : AppNeutral.n600,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
