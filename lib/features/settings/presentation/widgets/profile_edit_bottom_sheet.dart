import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_input.dart';

import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../steps/presentation/providers/step_providers.dart';
import '../../../../core/constants/validation_constants.dart';

class ProfileEditBottomSheet extends ConsumerStatefulWidget {
  const ProfileEditBottomSheet({super.key});

  @override
  ConsumerState<ProfileEditBottomSheet> createState() =>
      _ProfileEditBottomSheetState();
}

class _ProfileEditBottomSheetState
    extends ConsumerState<ProfileEditBottomSheet> {
  late TextEditingController nameCtrl;
  late TextEditingController stepCtrl;
  late TextEditingController waterCtrl;
  String selectedType = 'wellness';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    nameCtrl = TextEditingController(text: profile?.displayName ?? '');
    stepCtrl = TextEditingController(
      text: (profile?.dailyStepGoal ?? 8000).toString(),
    );
    waterCtrl = TextEditingController(
      text: (profile?.dailyWaterGoalMl ?? 2500).toString(),
    );
    selectedType = profile?.userType ?? 'wellness';
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    stepCtrl.dispose();
    waterCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      AppToast.show(context, 'Name required', type: AppToastType.warning);
      return;
    }

    final steps = int.tryParse(stepCtrl.text.trim()) ?? 8000;
    final water = int.tryParse(waterCtrl.text.trim()) ?? 2500;

    if (steps < ValidationConstants.minStepGoal ||
        steps > ValidationConstants.maxStepGoal) {
      AppToast.show(
        context,
        'Steps must be ${ValidationConstants.minStepGoal}–${ValidationConstants.maxStepGoal}',
        type: AppToastType.warning,
      );
      return;
    }
    if (water < ValidationConstants.minWaterGoalMl ||
        water > ValidationConstants.maxWaterMl) {
      AppToast.show(
        context,
        'Water must be ${ValidationConstants.minWaterGoalMl}–${ValidationConstants.maxWaterMl} ml',
        type: AppToastType.warning,
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      await ref
          .read(profileProvider.notifier)
          .updateProfile(
            displayName: name,
            userType: selectedType,
            stepGoal: steps,
            waterGoal: water,
          );
      
      // Sync the steps goal in the step controller/provider immediately
      try {
        await ref.read(stepProvider.notifier).updateGoal(steps);
      } catch (_) {
        // Silent fallback in case steps module fails to sync
      }

      if (mounted) {
        Navigator.pop(context);
        AppToast.show(context, 'Profile updated', type: AppToastType.success);
      }
    } catch (_) {
      if (mounted) {
        AppToast.show(context, 'Action failed', type: AppToastType.error);
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        16, // minor visual spacer top
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit Profile',
            style: AppTextStyles.h3.copyWith(
              color: isDark ? Colors.white : AppNeutral.n900,
            ),
          ),
          const SizedBox(height: 24),
          AppInput(
            label: 'Your Name',
            hint: 'User',
            controller: nameCtrl,
            textInputAction: TextInputAction.next,
            inputFormatters: [LengthLimitingTextInputFormatter(25)],
          ),
          const SizedBox(height: 20),
          Text(
            'Persona Focus',
            style: AppTextStyles.bodyS.copyWith(
              fontWeight: FontWeight.bold,
              color: AppNeutral.n500,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedType,
            dropdownColor: isDark ? AppNeutral.n800 : Colors.white,
            style: AppTextStyles.bodyM.copyWith(
              color: isDark ? Colors.white : AppNeutral.n900,
            ),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppNeutral.n500,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? AppNeutral.n800 : Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.buttonRadius,
                borderSide: BorderSide(
                  color: isDark ? AppNeutral.n700 : AppNeutral.n200,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.buttonRadius,
                borderSide: const BorderSide(
                  color: AppColors.primary500,
                  width: 1.5,
                ),
              ),
            ),
            items: ['student', 'fitness', 'working', 'wellness']
                .map(
                  (t) =>
                      DropdownMenuItem(value: t, child: Text(t.toUpperCase())),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => selectedType = val);
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: AppInput(
                  label: 'Daily Steps',
                  hint: '8000',
                  controller: stepCtrl,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppInput(
                  label: 'Water (ml)',
                  hint: '2500',
                  controller: waterCtrl,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          AppButton(
            label: 'Confirm Updates',
            fullWidth: true,
            isLoading: isLoading,
            size: AppButtonSize.lg,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
