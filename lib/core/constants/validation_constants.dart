class ValidationConstants {
  // Water constraints
  static const int minWaterGoalMl = 500;
  static const int maxWaterGoalMl = 15000; // Safe human cap
  static const int maxWaterMl = 15000;

  // Step constraints
  static const int minStepGoal = 500;
  static const int maxStepGoal = 100000;

  // Habit constraints
  static const int minHabitTitleLength = 2;
  static const int maxHabitTitleLength = 40;

  // Profile constraints
  static const int minDisplayNameLength = 2;
  static const int maxDisplayNameLength = 30;
}
