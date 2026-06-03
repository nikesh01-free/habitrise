import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitrise/core/constants/app_routes.dart';
import 'package:habitrise/core/constants/validation_constants.dart';
import 'package:habitrise/core/theme/app_colors.dart';
import 'package:habitrise/core/theme/app_text_styles.dart';
import 'package:habitrise/core/widgets/app_button.dart';
import 'package:habitrise/core/widgets/app_input.dart';
import 'package:habitrise/core/widgets/app_toast.dart';
import '../../profile/presentation/providers/profile_providers.dart';

class OnboardingProfileScreen extends ConsumerStatefulWidget {
  const OnboardingProfileScreen({super.key});

  @override
  ConsumerState<OnboardingProfileScreen> createState() =>
      _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState
    extends ConsumerState<OnboardingProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _stepCtrl = TextEditingController(text: '8000');
  final _waterCtrl = TextEditingController(text: '2500');
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _stepCtrl.dispose();
    _waterCtrl.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    final name = _nameCtrl.text.trim();
    final steps = int.tryParse(_stepCtrl.text.trim()) ?? 8000;
    final water = int.tryParse(_waterCtrl.text.trim()) ?? 2500;

    if (name.length < ValidationConstants.minDisplayNameLength ||
        name.length > ValidationConstants.maxDisplayNameLength) {
      AppToast.show(
        context,
        'Name must be ${ValidationConstants.minDisplayNameLength}–${ValidationConstants.maxDisplayNameLength} characters',
        type: AppToastType.warning,
      );
      return;
    }
    if (steps < ValidationConstants.minStepGoal ||
        steps > ValidationConstants.maxStepGoal) {
      AppToast.show(
        context,
        'Step goal must be ${ValidationConstants.minStepGoal}–${ValidationConstants.maxStepGoal}',
        type: AppToastType.warning,
      );
      return;
    }
    if (water < ValidationConstants.minWaterGoalMl ||
        water > ValidationConstants.maxWaterMl) {
      AppToast.show(
        context,
        'Water goal must be ${ValidationConstants.minWaterGoalMl}–${ValidationConstants.maxWaterMl} ml',
        type: AppToastType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(profileProvider.notifier).updateProfile(
            displayName: name,
            userType: 'general',
            stepGoal: steps,
            waterGoal: water,
          );
      if (mounted) {
        Navigator.pushNamed(context, AppRoutes.onboardingHabits);
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(context, 'Could not save profile', type: AppToastType.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppNeutral.n900 : AppNeutral.n50,
      appBar: AppBar(title: const Text('Your Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tell us about yourself',
                style: AppTextStyles.h2.copyWith(
                  color: isDark ? Colors.white : AppNeutral.n900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We\'ll personalise your dashboard with real targets.',
                style: AppTextStyles.bodyM.copyWith(color: AppNeutral.n500),
              ),
              const SizedBox(height: 36),
              AppInput(
                label: 'Display Name',
                hint: 'e.g. Alex',
                controller: _nameCtrl,
                keyboardType: TextInputType.name,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(
                    ValidationConstants.maxDisplayNameLength,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AppInput(
                label: 'Daily Step Goal',
                hint: 'e.g. 8000',
                controller: _stepCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${ValidationConstants.minStepGoal}–${ValidationConstants.maxStepGoal} steps recommended',
                style: AppTextStyles.bodyS.copyWith(color: AppNeutral.n500),
              ),
              const SizedBox(height: 20),
              AppInput(
                label: 'Daily Water Goal (ml)',
                hint: 'e.g. 2500',
                controller: _waterCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${ValidationConstants.minWaterGoalMl}–${ValidationConstants.maxWaterMl} ml recommended',
                style: AppTextStyles.bodyS.copyWith(color: AppNeutral.n500),
              ),
              const SizedBox(height: 40),
              AppButton(
                label: 'Next',
                fullWidth: true,
                size: AppButtonSize.lg,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _next,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
