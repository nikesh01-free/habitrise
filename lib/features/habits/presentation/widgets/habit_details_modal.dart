import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_modal.dart';
import '../../../../core/theme/app_icons.dart';
import '../../data/models/habit_model.dart';
import '../providers/habit_providers.dart';
import '../edit_habit_screen.dart';

class HabitDetailsModal extends ConsumerWidget {
  final HabitModel habit;
  const HabitDetailsModal({super.key, required this.habit});

  static void show(BuildContext context, HabitModel habit) {
    AppModal.showSheet(
      context: context,
      child: HabitDetailsModal(habit: habit),
    );
  }

  Future<void> _confirmAction(
    BuildContext context,
    String title,
    String msg,
    IconData icon,
    VoidCallback onConfirm,
  ) async {
    showDialog(
      context: context,
      builder: (ctx) => AppModal(
        title: title,
        description: msg,
        isDangerPrimary: true,
        icon: icon,
        primaryLabel: 'Confirm',
        secondaryLabel: 'Cancel',
        onPrimary: () {
          Navigator.pop(ctx);
          onConfirm();
        },
        onSecondary: () => Navigator.pop(ctx),
        child: const SizedBox.shrink(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final habitColor = Color(
      int.tryParse(habit.colorHex.replaceFirst('#', '0xFF')) ?? 0xFF4F6EF7,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: habitColor.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(AppIcons.sparkles, color: habitColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: AppTextStyles.h3.copyWith(
                        color: isDark ? Colors.white : AppNeutral.n900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${habit.frequency.toUpperCase()} • ${habit.category.toUpperCase()}',
                      style: AppTextStyles.bodyS.copyWith(
                        color: AppNeutral.n500,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildActionTile(
            context,
            icon: habit.isPinned
                ? Icons.push_pin_rounded
                : Icons.push_pin_outlined,
            label: habit.isPinned ? 'Unpin Habit' : 'Pin Habit',
            color: habit.isPinned ? Colors.blueAccent : AppNeutral.n500,
            onTap: () async {
              await ref.read(habitControllerProvider).togglePinHabit(habit);
              if (context.mounted) {
                Navigator.pop(context);
                AppToast.show(
                  context,
                  habit.isPinned ? 'Habit unpinned' : 'Habit pinned',
                  type: AppToastType.success,
                );
              }
            },
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context,
            icon: AppIcons.edit,
            label: 'Edit Habit',
            color: isDark ? Colors.white : AppNeutral.n800,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditHabitScreen(habit: habit),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context,
            icon: AppIcons.archive,
            label: 'Archive Habit',
            color: Colors.orange,
            onTap: () {
              _confirmAction(
                context,
                'Archive Habit',
                'Archived habits will no longer appear in the daily list.',
                AppIcons.archive,
                () async {
                  await ref
                      .read(habitControllerProvider)
                      .archiveHabit(habit.id);
                  if (context.mounted) {
                    Navigator.pop(context); // dismiss modal
                    AppToast.show(
                      context,
                      'Habit archived',
                      type: AppToastType.success,
                    );
                  }
                },
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context,
            icon: AppIcons.delete,
            label: 'Delete Permanently',
            color: AppSemantic.error,
            onTap: () {
              _confirmAction(
                context,
                'Delete Habit?',
                'All history will be permanently lost. This cannot be undone.',
                AppIcons.delete,
                () async {
                  await ref.read(habitControllerProvider).deleteHabit(habit.id);
                  if (context.mounted) {
                    Navigator.pop(context); // dismiss modal
                    AppToast.show(
                      context,
                      'Habit deleted',
                      type: AppToastType.success,
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? AppNeutral.n800 : AppNeutral.n50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: AppTextStyles.bodyM.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(
              AppIcons.arrowRight,
              color: isDark ? AppNeutral.n500 : AppNeutral.n400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
