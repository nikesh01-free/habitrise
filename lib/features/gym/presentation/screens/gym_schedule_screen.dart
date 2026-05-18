import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_input.dart';
import '../providers/gym_providers.dart';
import '../../data/models/gym_schedule_model.dart';
import 'package:intl/intl.dart';

class GymScheduleScreen extends ConsumerStatefulWidget {
  const GymScheduleScreen({super.key});

  @override
  ConsumerState<GymScheduleScreen> createState() => _GymScheduleScreenState();
}

class _GymScheduleScreenState extends ConsumerState<GymScheduleScreen> {
  final List<String> _weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final schedulesAsync = ref.watch(gymScheduleProvider);

    return Scaffold(
      backgroundColor: isDark ? AppNeutral.n900 : AppNeutral.n50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(AppIcons.arrowLeft, color: isDark ? Colors.white : AppNeutral.n900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Weekly Routine', style: AppTextStyles.h4.copyWith(color: isDark ? Colors.white : AppNeutral.n900)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: schedulesAsync.when(
        data: (schedules) {
          // Efficient O(1) lookup map for rendering
          final scheduleMap = {
            for (var s in schedules) s.dayOfWeek.toLowerCase(): s,
          };

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: _weekDays.length,
            separatorBuilder: (c, i) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final day = _weekDays[index];
              final data = scheduleMap[day.toLowerCase()];
              final isToday =
                  DateFormat('EEEE').format(DateTime.now()).toLowerCase() ==
                  day.toLowerCase();

              return _buildDayCard(day, data, isToday, isDark);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading schedule: $e')),
      ),
      ),
    );
  }

  Widget _buildDayCard(
    String dayName,
    GymScheduleModel? data,
    bool isToday,
    bool isDark,
  ) {
    final hasData = data != null;
    final isRest = data?.isRestDay ?? false;

    return AppCard(
      padding: EdgeInsets.zero,
      border: isToday
          ? Border.all(color: AppColors.primary500, width: 2)
          : null,
      child: InkWell(
        borderRadius: AppRadius.cardRadius,
        onTap: () => _openEditSheet(dayName, data),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Day Bubble
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  gradient: isRest
                      ? LinearGradient(
                          colors: [AppNeutral.n300, AppNeutral.n400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: hasData
                              ? [
                                  const Color(0xFFEC4899),
                                  const Color(0xFF8B5CF6),
                                ]
                              : [AppNeutral.n100, AppNeutral.n200],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    dayName.substring(0, 3).toUpperCase(),
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.bold,
                      color: hasData ? Colors.white : AppNeutral.n500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Content Area
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          dayName,
                          style: AppTextStyles.bodyL.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppNeutral.n900,
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary500,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              'TODAY',
                              style: AppTextStyles.bodyS.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (!hasData)
                      Text(
                        'Tap to set routine',
                        style: AppTextStyles.bodyS.copyWith(
                          color: AppNeutral.n400,
                        ),
                      )
                    else if (isRest)
                      Row(
                        children: [
                          const Icon(
                            Icons.bedtime_outlined,
                            size: 16,
                            color: AppNeutral.n500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Rest Day',
                            style: AppTextStyles.bodyM.copyWith(
                              color: AppNeutral.n500,
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.workoutTitle,
                            style: AppTextStyles.bodyM.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.primary600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: data.muscleGroups.map((m) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary500.withAlpha(30),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  m.toUpperCase(),
                                  style: AppTextStyles.bodyS.copyWith(
                                    color: AppColors.secondary600,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppNeutral.n400),
            ],
          ),
        ),
      ),
    );
  }

  void _openEditSheet(String dayName, GymScheduleModel? data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _GymEditSheet(dayName: dayName, existingData: data),
    );
  }
}

class _GymEditSheet extends ConsumerStatefulWidget {
  final String dayName;
  final GymScheduleModel? existingData;

  const _GymEditSheet({required this.dayName, this.existingData});

  @override
  ConsumerState<_GymEditSheet> createState() => __GymEditSheetState();
}

class __GymEditSheetState extends ConsumerState<_GymEditSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _notesCtrl;
  late bool _isRestDay;
  late List<String> _selectedMuscles;
  bool _isLoading = false;

  final List<String> _availableMuscles = [
    'chest',
    'back',
    'shoulders',
    'biceps',
    'triceps',
    'quads',
    'hamstrings',
    'glutes',
    'calves',
    'abs',
    'cardio',
  ];

  @override
  void initState() {
    super.initState();
    final data = widget.existingData;
    _titleCtrl = TextEditingController(text: data?.workoutTitle ?? '');
    _notesCtrl = TextEditingController(text: data?.notes ?? '');
    _isRestDay = data?.isRestDay ?? false;
    _selectedMuscles = List<String>.from(data?.muscleGroups ?? []);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _toggleMuscle(String m) {
    setState(() {
      if (_selectedMuscles.contains(m)) {
        _selectedMuscles.remove(m);
      } else {
        _selectedMuscles.add(m);
      }
    });
  }

  Future<void> _save() async {
    if (!_isRestDay) {
      if (_titleCtrl.text.trim().isEmpty) {
        AppToast.show(
          context,
          'Enter a workout title.',
          type: AppToastType.warning,
        );
        return;
      }
      if (_selectedMuscles.isEmpty) {
        AppToast.show(
          context,
          'Select at least one muscle group.',
          type: AppToastType.warning,
        );
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(gymControllerProvider)
          .upsertSchedule(
            id: widget.existingData?.id,
            dayOfWeek: widget.dayName,
            workoutTitle: _titleCtrl.text.trim(),
            notes: _notesCtrl.text.trim(),
            isRestDay: _isRestDay,
            muscleGroups: _selectedMuscles,
          );
      if (mounted) {
        Navigator.pop(context);
        AppToast.show(context, '${widget.dayName} routine updated!');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        AppToast.show(context, e.toString(), type: AppToastType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppNeutral.n800 : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, bottomInset + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppNeutral.n300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Setup ${widget.dayName}', style: AppTextStyles.h3),
            const SizedBox(height: 24),

            // Rest Day Toggle
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Rest Day',
                style: AppTextStyles.bodyL.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Take it easy & recover.',
                style: AppTextStyles.bodyS,
              ),
              value: _isRestDay,
              activeThumbColor: AppColors.primary500,
              onChanged: (v) => setState(() => _isRestDay = v),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            if (!_isRestDay) ...[
              Text(
                'Workout Name',
                style: AppTextStyles.bodyM.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              AppInput(
                controller: _titleCtrl,
                label: "Workout Name",
                hint: 'e.g. Push Day / Heavy Legs',
                textInputAction: TextInputAction.next,
                inputFormatters: [LengthLimitingTextInputFormatter(30)],
              ),
              const SizedBox(height: 24),
              Text(
                'Muscles Groups Targeted',
                style: AppTextStyles.bodyM.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableMuscles.map((m) {
                  final isSel = _selectedMuscles.contains(m);
                  return FilterChip(
                    selected: isSel,
                    label: Text(
                      m.substring(0, 1).toUpperCase() + m.substring(1),
                    ),
                    labelStyle: AppTextStyles.bodyS.copyWith(
                      color: isSel
                          ? Colors.white
                          : (isDark ? AppNeutral.n300 : AppNeutral.n600),
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    ),
                    selectedColor: AppColors.primary500,
                    backgroundColor: isDark ? AppNeutral.n700 : AppNeutral.n100,
                    onSelected: (_) => _toggleMuscle(m),
                    checkmarkColor: Colors.white,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text(
                'Optional Notes',
                style: AppTextStyles.bodyM.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              AppInput(
                controller: _notesCtrl,
                label: 'Optional Notes',
                hint: 'Sets, reps or goals...',
                textInputAction: TextInputAction.done,
                inputFormatters: [LengthLimitingTextInputFormatter(80)],
              ),
            ],
            const SizedBox(height: 32),
            AppButton(
              label: 'Save Routine',
              fullWidth: true,
              isLoading: _isLoading,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
