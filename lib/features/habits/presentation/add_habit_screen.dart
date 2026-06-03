import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitrise/core/theme/app_colors.dart';
import 'package:habitrise/core/theme/app_text_styles.dart';
import 'package:habitrise/core/theme/app_icons.dart';
import 'package:habitrise/core/widgets/app_toast.dart';
import 'package:habitrise/features/habits/data/models/habit_template.dart';
import 'package:habitrise/features/habits/presentation/providers/habit_providers.dart';

class AddHabitScreen extends ConsumerStatefulWidget {
  const AddHabitScreen({super.key});

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  final _titleController = TextEditingController();
  String _category = 'wellness';
  String _frequency = 'daily';
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final trimmed = _titleController.text.trim();
    if (trimmed.isEmpty) {
      AppToast.show(context, 'Enter habit title', type: AppToastType.warning);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(habitControllerProvider).addHabit(
        title: trimmed,
        category: _category,
        type: 'checkbox',
        frequency: _frequency,
        colorHex: '#4F6EF7',
        reminderEnabled: _reminderEnabled,
        reminderTime: '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
      );
      if (mounted) {
        AppToast.show(context, 'Habit created!', type: AppToastType.success);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) AppToast.show(context, 'Failed to save', type: AppToastType.error);
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
        title: Text('Add Habit', style: AppTextStyles.h4.copyWith(color: isDark ? Colors.white : AppNeutral.n900)),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildTemplates(isDark),
          ),
          SliverToBoxAdapter(
            child: _buildForm(isDark),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildTemplates(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('QUICK TEMPLATES', style: AppTextStyles.bodyS.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.2, color: AppNeutral.n500)),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: habitTemplates.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (ctx, index) {
                final t = habitTemplates[index];
                final color = Color(int.tryParse(t.colorHex.replaceFirst('#', '0xFF')) ?? 0xFF4F6EF7);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _titleController.text = t.title;
                      _category = t.category;
                      _frequency = t.frequency;
                    });
                  },
                  child: Container(
                    width: 120,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppNeutral.n800 : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? AppNeutral.n700 : AppNeutral.n200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: color.withAlpha(30), shape: BoxShape.circle),
                          child: Icon(Icons.bolt, color: color, size: 16),
                        ),
                        const Spacer(),
                        Text(t.title, style: AppTextStyles.bodyS.copyWith(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ).animate().fadeIn(delay: (50 * index).ms),
                );
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildForm(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('HABIT DETAILS', style: AppTextStyles.bodyS.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.2, color: AppNeutral.n500)),
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
                    hintText: 'e.g. Morning Jog',
                    filled: true,
                    fillColor: isDark ? AppNeutral.n700 : AppNeutral.n50,
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(45)],
                ),
                const SizedBox(height: 20),
                Text('Frequency', style: AppTextStyles.bodyS.copyWith(fontWeight: FontWeight.w600, color: AppNeutral.n500)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _optionChip('Daily', _frequency == 'daily', () => setState(() => _frequency = 'daily'), isDark),
                    const SizedBox(width: 12),
                    _optionChip('Weekly', _frequency == 'weekly', () => setState(() => _frequency = 'weekly'), isDark),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Category', style: AppTextStyles.bodyS.copyWith(fontWeight: FontWeight.w600, color: AppNeutral.n500)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  dropdownColor: isDark ? AppNeutral.n800 : Colors.white,
                  style: AppTextStyles.bodyM.copyWith(color: isDark ? Colors.white : AppNeutral.n900),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? AppNeutral.n700 : AppNeutral.n50,
                  ),
                  items: ['wellness', 'health', 'fitness', 'study', 'work', 'custom'].map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase()))).toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 20),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Reminder', style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600)),
                  subtitle: Text('Get notified daily', style: AppTextStyles.bodyS.copyWith(color: AppNeutral.n500)),
                  value: _reminderEnabled,
                  onChanged: (v) => setState(() => _reminderEnabled = v),
                ),
                if (_reminderEnabled) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
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
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _save,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary500, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text('Create Habit', style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _optionChip(String label, bool selected, VoidCallback onTap, bool isDark) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary500 : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? AppColors.primary500 : (isDark ? AppNeutral.n700 : AppNeutral.n200)),
          ),
          child: Center(
            child: Text(label, style: AppTextStyles.bodyS.copyWith(fontWeight: FontWeight.w700, color: selected ? Colors.white : AppNeutral.n500)),
          ),
        ),
      ),
    );
  }
}