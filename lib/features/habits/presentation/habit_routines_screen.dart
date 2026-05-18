import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitrise/features/habits/presentation/providers/habit_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';

class RoutineBundle {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final List<RoutineHabitItem> habits;

  const RoutineBundle({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.habits,
  });
}

class RoutineHabitItem {
  final String title;
  final String category;
  final String frequency;

  const RoutineHabitItem({
    required this.title,
    required this.category,
    this.frequency = 'daily',
  });
}

final List<RoutineBundle> routineBundles = [
  const RoutineBundle(
    id: 'student',
    name: 'Student Routine',
    description: 'Optimize study habits and healthy balance.',
    icon: Icons.school_rounded,
    habits: [
      RoutineHabitItem(title: 'Study 2 Hours', category: 'study'),
      RoutineHabitItem(title: 'Drink Water', category: 'health'),
      RoutineHabitItem(title: 'Review Notes', category: 'study'),
      RoutineHabitItem(title: 'Sleep Before 11 PM', category: 'wellness'),
    ],
  ),
  const RoutineBundle(
    id: 'gym',
    name: 'Gym Routine',
    description: 'Essential consistency for muscle growth.',
    icon: Icons.fitness_center,
    habits: [
      RoutineHabitItem(title: 'Workout Session', category: 'fitness'),
      RoutineHabitItem(title: 'Drink 2.5L Water', category: 'health'),
      RoutineHabitItem(title: 'Protein Meal', category: 'fitness'),
      RoutineHabitItem(title: 'Walk 8000 Steps', category: 'fitness'),
    ],
  ),
  const RoutineBundle(
    id: 'productivity',
    name: 'Productivity Routine',
    description: 'Elevate focus and high output performance.',
    icon: Icons.rocket_launch_rounded,
    habits: [
      RoutineHabitItem(title: 'Focus Session', category: 'work'),
      RoutineHabitItem(title: 'Plan Tomorrow', category: 'work'),
      RoutineHabitItem(title: 'No Phone 30 Min', category: 'wellness'),
      RoutineHabitItem(title: 'Read 10 Pages', category: 'study'),
    ],
  ),
  const RoutineBundle(
    id: 'wellness',
    name: 'Wellness Routine',
    description: 'Prioritize internal peace and health tracking.',
    icon: Icons.spa_rounded,
    habits: [
      RoutineHabitItem(title: 'Morning Walk', category: 'fitness'),
      RoutineHabitItem(title: 'Mood Check', category: 'wellness'),
      RoutineHabitItem(title: 'Drink Water', category: 'health'),
      RoutineHabitItem(title: 'Sleep Tracking', category: 'wellness'),
    ],
  ),
  const RoutineBundle(
    id: 'senior',
    name: 'Senior Health Routine',
    description: 'Gentle mobility and critical healthcare maintenance.',
    icon: Icons.elderly,
    habits: [
      RoutineHabitItem(title: 'Morning Walk', category: 'fitness'),
      RoutineHabitItem(title: 'Drink Water', category: 'health'),
      RoutineHabitItem(title: 'Medicine Reminder', category: 'health'),
      RoutineHabitItem(title: 'Light Stretching', category: 'fitness'),
    ],
  ),
];

class HabitRoutinesScreen extends ConsumerWidget {
  const HabitRoutinesScreen({super.key});

  Future<void> _addAll(
    BuildContext context,
    WidgetRef ref,
    RoutineBundle bundle,
  ) async {
    try {
      final existing = ref.read(activeHabitsProvider).value ?? [];
      final existingTitles = existing
          .map((e) => e.title.toLowerCase().trim())
          .toSet();

      int count = 0;
      for (var h in bundle.habits) {
        final cleanTitle = h.title.trim();
        if (existingTitles.contains(cleanTitle.toLowerCase())) {
          continue; // Prevent duplicate titles
        }
        await ref
            .read(habitControllerProvider)
            .addHabit(
              title: cleanTitle,
              category: h.category,
              type: 'checkbox',
              frequency: h.frequency,
              colorHex: '#4F6EF7',
              reminderEnabled: false,
            );
        count++;
      }

      if (!context.mounted) return;

      if (count > 0) {
        AppToast.show(
          context,
          'Successfully added $count new habits!',
          type: AppToastType.success,
        );
      } else {
        AppToast.show(
          context,
          'These habits are already tracked.',
          type: AppToastType.warning,
        );
      }
      Navigator.pop(context); // Exit back to caller screen
    } catch (e) {
      if (context.mounted) {
        AppToast.show(
          context,
          'Batch operation encountered an error',
          type: AppToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppNeutral.n900 : AppNeutral.n50,
      appBar: AppBar(title: const Text('Routine Templates')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: routineBundles.length,
        separatorBuilder: (c, s) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final bundle = routineBundles[index];

          return AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary500.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(bundle.icon, color: AppColors.primary500),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bundle.name,
                            style: AppTextStyles.h3.copyWith(
                              color: isDark ? Colors.white : AppNeutral.n900,
                            ),
                          ),
                          Text(
                            bundle.description,
                            style: AppTextStyles.bodyS.copyWith(
                              color: AppNeutral.n500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: bundle.habits.map((h) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppNeutral.n800 : AppNeutral.n50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? AppNeutral.n700 : AppNeutral.n200,
                        ),
                      ),
                      child: Text(
                        h.title,
                        style: AppTextStyles.bodyS.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppNeutral.n300 : AppNeutral.n700,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: 'Add Full Routine',
                  fullWidth: true,
                  onPressed: () => _addAll(context, ref, bundle),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
