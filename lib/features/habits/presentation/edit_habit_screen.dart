import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitrise/core/theme/app_colors.dart';
import 'package:habitrise/core/theme/app_text_styles.dart';
import 'package:habitrise/core/theme/app_icons.dart';
import 'package:habitrise/core/widgets/app_toast.dart';
import 'package:habitrise/features/habits/data/models/habit_model.dart';
import 'package:habitrise/features/habits/presentation/providers/habit_providers.dart';

class EditHabitScreen extends ConsumerStatefulWidget {
  final HabitModel habit;
  const EditHabitScreen({super.key, required this.habit});

  @override
  ConsumerState<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends ConsumerState<EditHabitScreen> {
  late final TextEditingController _titleController;
  late bool _reminderEnabled;
  late TimeOfDay _reminderTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.habit.title);
    _reminderEnabled = widget.habit.reminderEnabled;
    _reminderTime = const TimeOfDay(hour: 8, minute: 0);
    if (widget.habit.reminderTime != null) {
      try {
        final parts = widget.habit.reminderTime!.split(':');
        _reminderTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    final trimmed = _titleController.text.trim();
    if (trimmed.isEmpty) {
      AppToast.show(context, 'Title required', type: AppToastType.warning);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final updated = widget.habit.copyWith(
        title: trimmed,
        reminderEnabled: _reminderEnabled,
        reminderTime: '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
      );
      await ref.read(habitControllerProvider).updateHabit(updated);
      if (mounted) {
        AppToast.show(context, 'Updated', type: AppToastType.success);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) AppToast.show(context, 'Update failed', type: AppToastType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppNeutral.n900 : AppNeutral.n50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(AppIcons.arrowLeft, color: isDark ? Colors.white : AppNeutral.n900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Edit Habit', style: AppTextStyles.h4.copyWith(color: isDark ? Colors.white : AppNeutral.n900)),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(isDark),
          ),
          SliverToBoxAdapter(
            child: _buildForm(isDark),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? [const Color(0xFF1E1E2E), const Color(0xFF16213E)] : [AppColors.primary500, AppColors.primary600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primary500.withAlpha(50), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withAlpha(40), shape: BoxShape.circle),
            child: const Icon(AppIcons.edit, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit Habit', style: AppTextStyles.h3.copyWith(color: Colors.white)),
                Text('Modify your habit details', style: AppTextStyles.bodyS.copyWith(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildForm(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('HABIT INFO', style: AppTextStyles.bodyS.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.2, color: AppNeutral.n500)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppNeutral.n800 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppNeutral.n700 : AppNeutral.n200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  style: AppTextStyles.bodyM.copyWith(color: isDark ? Colors.white : AppNeutral.n900),
                  decoration: InputDecoration(
                    labelText: 'Habit Title',
                    filled: true,
                    fillColor: isDark ? AppNeutral.n700 : AppNeutral.n50,
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(45)],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppNeutral.n700 : AppNeutral.n50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(AppIcons.listChecks, color: AppColors.primary500, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Schedule', style: AppTextStyles.bodyS.copyWith(color: AppNeutral.n500)),
                            Text('${widget.habit.frequency.toUpperCase()} • ${widget.habit.category.toUpperCase()}', style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('NOTIFICATIONS', style: AppTextStyles.bodyS.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.2, color: AppNeutral.n500)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppNeutral.n800 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppNeutral.n700 : AppNeutral.n200),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  title: Text('Daily Reminder', style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600)),
                  subtitle: Text('Get notified to complete habit', style: AppTextStyles.bodyS.copyWith(color: AppNeutral.n500)),
                  value: _reminderEnabled,
                  onChanged: (v) => setState(() => _reminderEnabled = v),
                ),
                if (_reminderEnabled) ...[
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text('Time', style: AppTextStyles.bodyM),
                    trailing: Text(_reminderTime.format(context), style: AppTextStyles.bodyM.copyWith(color: AppColors.primary600, fontWeight: FontWeight.bold)),
                    onTap: () async {
                      final p = await showTimePicker(context: context, initialTime: _reminderTime);
                      if (p != null) setState(() => _reminderTime = p);
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _update,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('Save Changes', style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }
}