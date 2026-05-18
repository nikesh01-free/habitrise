import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitrise/core/theme/app_colors.dart';
import 'package:habitrise/core/theme/app_text_styles.dart';
import 'package:habitrise/core/theme/app_icons.dart';
import 'package:habitrise/core/widgets/app_loading_state.dart';
import 'package:habitrise/core/widgets/app_empty_state.dart';
import 'package:habitrise/core/constants/app_assets.dart';
import 'providers/analytics_providers.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  final VoidCallback? onReturnHome;
  const AnalyticsScreen({super.key, this.onReturnHome});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with AutomaticKeepAliveClientMixin {
  int _selectedChartIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final analyticsAsync = ref.watch(weeklyAnalyticsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppNeutral.n900 : AppNeutral.n50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            AppIcons.arrowLeft,
            color: isDark ? Colors.white : AppNeutral.n900,
          ),
          onPressed: widget.onReturnHome ?? () => Navigator.pop(context),
        ),
        title: Text(
          'Analytics',
          style: AppTextStyles.h4.copyWith(
            color: isDark ? Colors.white : AppNeutral.n900,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: analyticsAsync.when(
            loading: () => const Center(child: AppLoadingState(count: 3)),
            error: (e, _) => Center(
              child: AppEmptyState(
                icon: AppIcons.error,
                title: 'Analysis Unavailable',
                description: e.toString(),
              ),
            ),
            data: (data) {
              final hasData =
                  data.totalWater > 0 ||
                  data.totalSteps > 0 ||
                  data.totalMeals > 0 ||
                  data.totalSleepMinutes > 0;

              if (!hasData) {
                return AppEmptyState(
                  assetPath: AppAssets.emptyAnalytics,
                  icon: AppIcons.analytics,
                  title: 'Insights Await',
                  description:
                      'Execute daily routines to illuminate trends and unlock performance insights.',
                  buttonLabel: 'Return to Trackers',
                  onPressed:
                      widget.onReturnHome ?? () => Navigator.pop(context),
                );
              }

              return Column(
                children: [
                  _buildHeader(data, isDark),
                  SizedBox(height: 24),
                  _buildChartSelector(isDark),
                  _buildMainChart(data, isDark),
                  _buildMetricsGrid(data, isDark),
                  if (data.moodFrequencies.isNotEmpty)
                    _buildMoodSection(data, isDark),
                  const SizedBox(height: 100),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AnalyticsSummary data, bool isDark) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1E2E), const Color(0xFF16213E)]
              : [AppColors.primary500, AppColors.primary600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary500.withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  AppIcons.analytics,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Insights',
                    style: AppTextStyles.h3.copyWith(color: Colors.white),
                  ),
                  Text(
                    'Your progress at a glance',
                    style: AppTextStyles.bodyS.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _headerStat(
                  '${data.currentStreak}',
                  'Day Streak',
                  Icons.local_fire_department,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white24),
              Expanded(
                child: _headerStat(
                  '${data.longestStreak}',
                  'Best Streak',
                  Icons.emoji_events,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white24),
              Expanded(
                child: _headerStat(
                  '${data.last7Days.where((d) => d.habitCompletionRatio >= 1.0).length}',
                  'Perfect Days',
                  Icons.star,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _headerStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.amber, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.h2.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodyS.copyWith(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildChartSelector(bool isDark) {
    final charts = [
      {
        'label': 'Habits',
        'icon': AppIcons.habits,
        'color': AppColors.primary500,
      },
      {
        'label': 'Water',
        'icon': AppIcons.water,
        'color': AppFeatureColors.waterIcon,
      },
      {
        'label': 'Steps',
        'icon': AppIcons.steps,
        'color': AppFeatureColors.stepIcon,
      },
      {
        'label': 'Focus',
        'icon': AppIcons.focus,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'label': 'Meals',
        'icon': AppIcons.meals,
        'color': AppFeatureColors.mealIcon,
      },
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: charts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final chart = charts[index];
          final isSelected = _selectedChartIndex == index;

          return GestureDetector(
            onTap: () => setState(() => _selectedChartIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (chart['color'] as Color)
                    : (isDark ? AppNeutral.n800 : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? (chart['color'] as Color)
                      : (isDark ? AppNeutral.n700 : AppNeutral.n200),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    chart['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : AppNeutral.n500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    chart['label'] as String,
                    style: AppTextStyles.bodyS.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppNeutral.n500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildMainChart(AnalyticsSummary data, bool isDark) {
    final chartConfigs = [
      _ChartData(
        'Habits',
        data.last7Days.map((e) => e.habitCompletionRatio * 100).toList(),
        AppColors.primary500,
        100.0,
      ),
      _ChartData(
        'Water (ml)',
        data.last7Days.map((e) => e.waterMl.toDouble()).toList(),
        AppFeatureColors.waterIcon,
        2000.0,
      ),
      _ChartData(
        'Steps',
        data.last7Days.map((e) => e.steps.toDouble()).toList(),
        AppFeatureColors.stepIcon,
        8000.0,
      ),
      _ChartData(
        'Focus (min)',
        data.last7Days.map((e) => e.focusMinutes.toDouble()).toList(),
        const Color(0xFF8B5CF6),
        60.0,
      ),
      _ChartData(
        'Meals',
        data.last7Days.map((e) => e.mealsCount.toDouble()).toList(),
        AppFeatureColors.mealIcon,
        5.0,
      ),
    ];

    final config = chartConfigs[_selectedChartIndex];
    final maxVal = config.maxY;
    double computedMax = config.values.reduce((a, b) => a > b ? a : b);
    if (computedMax < maxVal) computedMax = maxVal;
    if (computedMax == 0) computedMax = 10;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppNeutral.n800 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 20 : 5),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                config.title,
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppNeutral.n900,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: config.color.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Last 7 days',
                  style: AppTextStyles.bodyS.copyWith(
                    color: config.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: computedMax * 1.2,
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) =>
                        isDark ? AppNeutral.n700 : AppNeutral.n800,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        rod.toY.toStringAsFixed(0),
                        AppTextStyles.bodyS.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        final idx = value.toInt();
                        if (idx < 0 || idx >= days.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            days[idx],
                            style: AppTextStyles.bodyS.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppNeutral.n400,
                            ),
                          ),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                ),
                barGroups: List.generate(config.values.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: config.values[i],
                        color: config.color,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: computedMax,
                          color: isDark
                              ? AppNeutral.n700.withAlpha(80)
                              : AppNeutral.n100,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05);
  }

  Widget _buildMetricsGrid(AnalyticsSummary data, bool isDark) {
    final metrics = [
      {
        'icon': AppIcons.water,
        'label': 'Total Water',
        'value': '${data.totalWater} ml',
        'color': AppFeatureColors.waterIcon,
      },
      {
        'icon': AppIcons.steps,
        'label': 'Total Steps',
        'value': '${data.totalSteps}',
        'color': AppFeatureColors.stepIcon,
      },
      {
        'icon': AppIcons.focus,
        'label': 'Focus Time',
        'value': '${data.totalFocusMinutes} min',
        'color': const Color(0xFF8B5CF6),
      },
      {
        'icon': AppIcons.meals,
        'label': 'Meals Logged',
        'value': '${data.totalMeals}',
        'color': AppFeatureColors.mealIcon,
      },
      {
        'icon': AppIcons.sleep,
        'label': 'Sleep',
        'value': '${(data.totalSleepMinutes / 60).toStringAsFixed(1)} hrs',
        'color': AppFeatureColors.sleepIcon,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WEEKLY TOTALS',
            style: AppTextStyles.bodyS.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppNeutral.n500,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: metrics.asMap().entries.map((entry) {
              final metric = entry.value;
              return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppNeutral.n800 : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppNeutral.n700 : AppNeutral.n200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: (metric['color'] as Color).withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            metric['icon'] as IconData,
                            color: metric['color'] as Color,
                            size: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          metric['value'] as String,
                          style: AppTextStyles.h4.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppNeutral.n900,
                          ),
                        ),
                        Text(
                          metric['label'] as String,
                          style: AppTextStyles.bodyS.copyWith(
                            color: AppNeutral.n500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(delay: (300 + entry.key * 50).ms)
                  .slideX(begin: 0.05);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSection(AnalyticsSummary data, bool isDark) {
    final sortedMoods = data.moodFrequencies.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppNeutral.n800 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppNeutral.n700 : AppNeutral.n200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_emotions,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Mood Insights',
                style: AppTextStyles.h3.copyWith(
                  color: isDark ? Colors.white : AppNeutral.n900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...sortedMoods.map((entry) {
            final percentage =
                (entry.value /
                    data.moodFrequencies.values.reduce((a, b) => a + b)) *
                100;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: AppTextStyles.bodyM.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppNeutral.n900,
                        ),
                      ),
                      Text(
                        '${entry.value} logs (${percentage.toStringAsFixed(0)}%)',
                        style: AppTextStyles.bodyS.copyWith(
                          color: AppNeutral.n500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: isDark
                          ? AppNeutral.n700
                          : AppNeutral.n100,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary500,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.05);
  }
}

class _ChartData {
  final String title;
  final List<double> values;
  final Color color;
  final double maxY;

  _ChartData(this.title, this.values, this.color, this.maxY);
}
