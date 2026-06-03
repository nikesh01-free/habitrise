import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../habits/presentation/providers/habit_providers.dart';
import '../../../water/presentation/providers/water_providers.dart';
import '../../../steps/presentation/providers/step_providers.dart';
import '../../../focus/presentation/providers/focus_providers.dart';
import '../../../mood/presentation/providers/mood_providers.dart';
import '../../../meals/presentation/providers/meal_providers.dart';
import '../../../sleep/presentation/providers/sleep_providers.dart';

class DaySummary {
  final String dateStr;
  final int habitsCompleted;
  final int habitsTotal;
  final int waterTotalMl;
  final int stepsTotal;
  final int stepsGoal;
  final int focusMinutes;
  final String? mood;
  final int mealsCompleted;
  final int sleepMinutes;
  final String? sleepQuality;

  const DaySummary({
    required this.dateStr,
    this.habitsCompleted = 0,
    this.habitsTotal = 0,
    this.waterTotalMl = 0,
    this.stepsTotal = 0,
    this.stepsGoal = 8000,
    this.focusMinutes = 0,
    this.mood,
    this.mealsCompleted = 0,
    this.sleepMinutes = 0,
    this.sleepQuality,
  });

  bool get hasData =>
      habitsCompleted > 0 ||
      waterTotalMl > 0 ||
      stepsTotal > 0 ||
      focusMinutes > 0 ||
      mood != null ||
      mealsCompleted > 0 ||
      sleepMinutes > 0;
}

final daySummaryProvider = FutureProvider.family.autoDispose<DaySummary, DateTime>((
  ref,
  date,
) async {
  final dateStr =
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  // Access pure repository singletons
  final habitRepo = ref.read(habitRepositoryProvider);
  final waterRepo = ref.read(waterRepositoryProvider);
  final stepRepo = ref.read(stepRepositoryProvider);
  final focusRepo = ref.read(focusRepositoryProvider);
  final moodRepo = ref.read(moodRepositoryProvider);
  final mealRepo = ref.read(mealRepositoryProvider);
  final sleepRepo = ref.read(sleepRepositoryProvider);

  // Habits logic
  final logs = habitRepo.getLogsForDate(dateStr);
  final completedHabits = logs.where((l) => l.status == 'completed').length;

  // Water logic
  final waterLogs = waterRepo.getLogsForDate(dateStr);
  final waterSum = waterLogs.fold(0, (acc, cur) => acc + cur.amountMl);

  // Steps logic
  final stepLog = stepRepo.getStepsByDate(dateStr);
  final stepsVal = stepLog?.steps ?? 0;
  final goalVal = stepLog?.goalSteps ?? 8000;

  // Focus logic
  final history = focusRepo.getHistory();
  final focusVal = history
      .where(
        (s) =>
            s.startedAt.year == date.year &&
            s.startedAt.month == date.month &&
            s.startedAt.day == date.day,
      )
      .fold(0, (acc, cur) => acc + cur.completedMinutes);

  // Mood logic
  final moodLog = moodRepo.getMoodForDate(dateStr);

  // Meals logic
  final meals = mealRepo.getMealsByDate(dateStr);
  final completedMealsCount = meals
      .where((m) => m.status == 'completed')
      .length;

  // Sleep logic
  final sleepLog = sleepRepo.getSleepByDate(dateStr);

  return DaySummary(
    dateStr: dateStr,
    habitsCompleted: completedHabits,
    habitsTotal: logs.isEmpty ? 0 : logs.length,
    waterTotalMl: waterSum,
    stepsTotal: stepsVal,
    stepsGoal: goalVal,
    focusMinutes: focusVal,
    mood: moodLog?.mood,
    mealsCompleted: completedMealsCount,
    sleepMinutes: sleepLog?.totalMinutes ?? 0,
    sleepQuality: sleepLog?.quality,
  );
});
