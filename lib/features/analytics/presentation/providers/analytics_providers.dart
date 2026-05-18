import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../habits/presentation/providers/habit_providers.dart';
import '../../../water/presentation/providers/water_providers.dart';
import '../../../steps/presentation/providers/step_providers.dart';
import '../../../focus/presentation/providers/focus_providers.dart';
import '../../../mood/presentation/providers/mood_providers.dart';
import '../../../meals/presentation/providers/meal_providers.dart';
import '../../../sleep/presentation/providers/sleep_providers.dart';

class AnalyticsSummary {
  final List<DailyStat> last7Days;
  final int currentStreak;
  final int longestStreak;
  final int totalWater;
  final int totalSteps;
  final int totalFocusMinutes;
  final Map<String, int> moodFrequencies;
  final int totalMeals;
  final int totalSleepMinutes;

  const AnalyticsSummary({
    required this.last7Days,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalWater = 0,
    this.totalSteps = 0,
    this.totalFocusMinutes = 0,
    this.moodFrequencies = const {},
    this.totalMeals = 0,
    this.totalSleepMinutes = 0,
  });

  bool get hasData => last7Days.any((d) => d.hasData);
}

class DailyStat {
  final String dateStr;
  final double habitCompletionRatio;
  final int waterMl;
  final int steps;
  final int focusMinutes;
  final int mealsCount;
  final int sleepMinutes;

  const DailyStat({
    required this.dateStr,
    this.habitCompletionRatio = 0,
    this.waterMl = 0,
    this.steps = 0,
    this.focusMinutes = 0,
    this.mealsCount = 0,
    this.sleepMinutes = 0,
  });

  bool get hasData =>
      habitCompletionRatio > 0 ||
      waterMl > 0 ||
      steps > 0 ||
      focusMinutes > 0 ||
      mealsCount > 0 ||
      sleepMinutes > 0;
}

final weeklyAnalyticsProvider = FutureProvider.autoDispose<AnalyticsSummary>((
  ref,
) async {
  final habitRepo = ref.read(habitRepositoryProvider);
  final waterRepo = ref.read(waterRepositoryProvider);
  final stepRepo = ref.read(stepRepositoryProvider);
  final focusRepo = ref.read(focusRepositoryProvider);
  final moodRepo = ref.read(moodRepositoryProvider);
  final mealRepo = ref.read(mealRepositoryProvider);
  final sleepRepo = ref.read(sleepRepositoryProvider);

  final now = DateTime.now();
  final todayStr =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

  // Watch real-time updates from underlying providers to auto-invalidate and recompute analytics
  ref.watch(activeHabitsProvider);
  ref.watch(habitLogsForDateProvider(todayStr));
  ref.watch(todayWaterLogsProvider);
  ref.watch(stepProvider);
  ref.watch(todayFocusSessionsProvider);
  ref.watch(todayMoodProvider);
  ref.watch(todayMealsProvider);
  ref.watch(todaySleepProvider);
  List<DailyStat> stats = [];
  int grandWater = 0;
  int grandSteps = 0;
  int grandFocus = 0;
  int grandMeals = 0;
  int grandSleep = 0;
  Map<String, int> moods = {};

  final activeHabits = habitRepo.getAllActiveHabits();
  int activeHabitCount = activeHabits.length;

  // 1. Loop last 7 days backward
  for (int i = 6; i >= 0; i--) {
    final d = now.subtract(Duration(days: i));
    final dateStr =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    // Habits
    final logs = habitRepo.getLogsForDate(dateStr);
    final done = logs.where((l) => l.status == 'completed').length;
    final ratio = activeHabitCount > 0 ? done / activeHabitCount : 0.0;

    // Water
    final wLogs = waterRepo.getLogsForDate(dateStr);
    final wSum = wLogs.fold(0, (a, b) => a + b.amountMl);
    grandWater += wSum;

    // Steps
    final sLog = stepRepo.getStepsByDate(dateStr);
    final sVal = sLog?.steps ?? 0;
    grandSteps += sVal;

    // Focus
    final focusLog = focusRepo
        .getHistory()
        .where(
          (s) =>
              s.startedAt.year == d.year &&
              s.startedAt.month == d.month &&
              s.startedAt.day == d.day,
        )
        .fold(0, (a, b) => a + b.completedMinutes);
    grandFocus += focusLog;

    // Mood
    final mLog = moodRepo.getMoodForDate(dateStr);
    if (mLog != null) {
      moods[mLog.mood] = (moods[mLog.mood] ?? 0) + 1;
    }

    // Meals
    final mCount = mealRepo
        .getMealsByDate(dateStr)
        .where((e) => e.status == 'completed')
        .length;
    grandMeals += mCount;

    // Sleep
    final sleepLog = sleepRepo.getSleepByDate(dateStr);
    final sMins = sleepLog?.totalMinutes ?? 0;
    grandSleep += sMins;

    stats.add(
      DailyStat(
        dateStr: dateStr,
        habitCompletionRatio: ratio,
        waterMl: wSum,
        steps: sVal,
        focusMinutes: focusLog,
        mealsCount: mCount,
        sleepMinutes: sMins,
      ),
    );
  }

  // 2. Calculate simple streak loop
  // To avoid excessive historic loops, we'll limit history scanning to past 30 days for streak.
  int currentStreak = 0;
  int bestStreak = 0;
  int tempStreak = 0;

  // 1. Collect history first to avoid double repo reads
  final List<bool> history = [];
  for (int i = 0; i < 60; i++) {
    final d = now.subtract(Duration(days: i));
    final dStr =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final logs = habitRepo.getLogsForDate(dStr);
    history.add(logs.any((l) => l.status == 'completed'));
  }

  // 2. Calculate current streak (breaking on first incomplete day)
  for (final dayDone in history) {
    if (dayDone) {
      currentStreak++;
    } else {
      break;
    }
  }

  // 3. Calculate best streak
  for (final dayDone in history) {
    if (dayDone) {
      tempStreak++;
    } else {
      if (tempStreak > bestStreak) bestStreak = tempStreak;
      tempStreak = 0;
    }
  }
  if (tempStreak > bestStreak) bestStreak = tempStreak;

  return AnalyticsSummary(
    last7Days: stats,
    currentStreak: currentStreak,
    longestStreak: bestStreak > currentStreak ? bestStreak : currentStreak,
    totalWater: grandWater,
    totalSteps: grandSteps,
    totalFocusMinutes: grandFocus,
    moodFrequencies: moods,
    totalMeals: grandMeals,
    totalSleepMinutes: grandSleep,
  );
});
