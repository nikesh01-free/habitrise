import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../providers/gym_providers.dart';

class GymDashboardSection extends ConsumerWidget {
  const GymDashboardSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVisible = ref.watch(gymFeatureVisibleProvider);
    if (!isVisible) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final schedulesAsync = ref.watch(gymScheduleProvider);
    final todayName = DateFormat('EEEE').format(DateTime.now());
    final todayDateIso = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final logsAsync = ref.watch(gymLogsForDateProvider(todayDateIso));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Gym Routine',
              style: AppTextStyles.h3.copyWith(
                color: isDark ? Colors.white : AppNeutral.n900,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.gym),
              child: Text(
                'See Weekly',
                style: AppTextStyles.bodyM.copyWith(
                  color: AppColors.primary500,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        schedulesAsync.when(
          data: (schedules) {
            final scheduleMap = {
              for (var s in schedules) s.dayOfWeek.toLowerCase(): s,
            };
            final routine = scheduleMap[todayName.toLowerCase()];

            return _buildStatusCard(
              context,
              ref,
              routine,
              todayDateIso,
              logsAsync.value ?? [],
              isDark,
            );
          },
          loading: () => const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (e, s) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    WidgetRef ref,
    dynamic routine, // GymScheduleModel?
    String todayIso,
    List<dynamic> logs, // List<GymWorkoutLogModel>
    bool isDark,
  ) {
    final hasLogged = logs.isNotEmpty;
    final isRest = routine?.isRestDay ?? false;
    final hasRoutine = routine != null;

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Training',
                  style: AppTextStyles.bodyS.copyWith(color: AppNeutral.n500),
                ),
                const SizedBox(height: 2),
                Text(
                  !hasRoutine
                      ? 'No Routine Set'
                      : (isRest ? 'Rest Day' : routine.workoutTitle),
                  style: AppTextStyles.bodyL.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppNeutral.n900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (!hasRoutine)
            AppButton(
              label: 'Setup',
              size: AppButtonSize.sm,
              variant: AppButtonVariant.secondary,
              onPressed: () => Navigator.pushNamed(context, AppRoutes.gym),
            )
          else if (isRest)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? AppNeutral.n700 : AppNeutral.n100,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                'REST',
                style: AppTextStyles.bodyS.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else if (hasLogged)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppSemantic.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 20),
            )
          else
            AppButton(
              label: 'Log',
              size: AppButtonSize.sm,
              onPressed: () => _triggerFastLog(context, ref, routine, todayIso),
            ),
        ],
      ),
    );
  }

  Future<void> _triggerFastLog(
    BuildContext context,
    WidgetRef ref,
    dynamic routine,
    String dateIso,
  ) async {
    try {
      await ref
          .read(gymControllerProvider)
          .logWorkout(
            scheduleId: routine.id,
            dateIso: dateIso,
            actualMuscleGroups: List<String>.from(routine.muscleGroups),
            intensity: 'medium',
            moodAfter: 'good',
            notes: 'Quick logged from dashboard.',
          );
      if (context.mounted) {
        AppToast.show(
          context,
          'Workout logged! 💪',
          type: AppToastType.success,
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.show(context, 'Failed to log: $e', type: AppToastType.error);
      }
    }
  }
}
