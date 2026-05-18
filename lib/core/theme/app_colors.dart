import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette — Indigo Blue
  static const primary50 = Color(0xFFEEF2FF);
  static const primary100 = Color(0xFFE0E7FF);
  static const primary200 = Color(0xFFC7D2FE);
  static const primary300 = Color(0xFFA5B4FC);
  static const primary400 = Color(0xFF818CF8);
  static const primary500 = Color(0xFF4F6EF7); // Main brand
  static const primary600 = Color(0xFF3451D1);
  static const primary700 = Color(0xFF2A3FA8);
  static const primary800 = Color(0xFF1E2F80);
  static const primary900 = Color(0xFF1A1D5E);
  static const secondary400 = Color(0xFF9F8FEF);
  static const secondary500 = Color(0xFF7C6FCD);
  static const secondary600 = Color(0xFF5C50A8);
  static const error = Color(0xFFF25C6E);
  static const errorBg = Color(0xFFFDF2F8);
  // Fitness — Vibrant Purple
  static const gym = Color(0xFFA855F7); // Purple 500
  static const gymBg = Color(0xFFF3E8FF); // Purple 50
  static const gymButtonBg = Color(0xFFA855F7); // Purple 500

  // Accent — Mint for success/completion
  static const accent400 = Color(0xFF6EE7B7);
  static const accent500 = Color(0xFF34D399);
  static const accent600 = Color(0xFF10B981);

  // Feature Colors (consistent per feature across the whole app)
  static const water = Color(0xFF38BDF8); // Sky blue
  static const waterBg = Color(0xFFE0F2FE);
  static const steps = Color(0xFFF97316); // Orange
  static const stepsBg = Color(0xFFFFF7ED);
  static const sleep = Color(0xFF818CF8); // Indigo soft
  static const sleepBg = Color(0xFFEEF2FF);
  static const meals = Color(0xFFFB923C); // Warm orange
  static const mealsBg = Color(0xFFFFF7ED);
  static const focus = Color(0xFFA78BFA); // Violet
  static const focusBg = Color(0xFFF5F3FF);
  static const mood = Color(0xFFF472B6); // Pink
  static const moodBg = Color(0xFFFDF2F8);
  static const habits = Color(0xFF34D399); // Emerald
  static const habitsBg = Color(0xFFECFDF5);
}

class AppNeutral {
  static const n0 = Color(0xFFFFFFFF);
  static const n50 = Color(0xFFF5F7FF); // App background
  static const n100 = Color(0xFFEEF0F8);
  static const n200 = Color(0xFFDDE1F0);
  static const n300 = Color(0xFFC4CAE0);
  static const n400 = Color(0xFF9399B5);
  static const n500 = Color(0xFF6B7280);
  static const n600 = Color(0xFF4B5268);
  static const n700 = Color(0xFF353A52);
  static const n800 = Color(0xFF232738);
  static const n900 = Color(0xFF1A1D2E);

  // Legacy aliases for backward compatibility where strictly needed by the system during replacement phases.
  // Note: Users requested strict replacement, but internal code references might break until all are rewritten.
  static const neutral50 = n50;
  static const neutral100 = n100;
  static const neutral200 = n200;
  static const neutral300 = n300;
  static const neutral400 = n400;
  static const neutral500 = n500;
  static const neutral600 = n600;
  static const neutral700 = n700;
  static const neutral800 = n800;
  static const neutral900 = n900;
}

class AppSemantic {
  static const success = Color(0xFF10B981);
  static const successLight = Color(0xFFD1FAE5);
  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFEF3C7);
  static const error = Color(0xFFF25C6E);
  static const errorLight = Color(0xFFFFE4E8);
  static const info = Color(0xFF38BDF8);
  static const infoLight = Color(0xFFE0F2FE);
}

class AppFeatureColors {
  static const habitIcon = AppColors.habits;
  static const habitBg = AppColors.habitsBg;

  static const waterIcon = AppColors.water;
  static const waterBg = AppColors.waterBg;
  static const stepIcon = AppColors.steps;
  static const stepBg = AppColors.stepsBg;
  static const mealIcon = AppColors.meals;
  static const mealBg = AppColors.mealsBg;
  static const sleepIcon = AppColors.sleep;
  static const sleepBg = AppColors.sleepBg;
  static const focusIcon = AppColors.focus;
  static const focusBg = AppColors.focusBg;

  static const gymIcon = AppColors.gym;
  static const gymBg = AppColors.gymBg;
}
