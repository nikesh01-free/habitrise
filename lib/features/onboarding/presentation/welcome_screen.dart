import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitrise/core/constants/app_routes.dart';
import 'package:habitrise/core/theme/app_colors.dart';
import 'package:habitrise/core/theme/app_text_styles.dart';
import 'package:habitrise/core/widgets/app_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppNeutral.n900 : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary500.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.auto_awesome_rounded, size: 64, color: AppColors.primary500),
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut).fadeIn(),
              const SizedBox(height: 40),
              Text(
                'Step Into a Better Version',
                textAlign: TextAlign.center,
                style: AppTextStyles.h1.copyWith(
                  fontSize: 36,
                  height: 1.1,
                  color: isDark ? Colors.white : AppNeutral.n900,
                ),
              ).animate().slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOut).fadeIn(),
              const SizedBox(height: 16),
              Text(
                'Cultivate focus, health, and habits through meaningful tracking that respects your privacy.',
                style: AppTextStyles.bodyL.copyWith(color: AppNeutral.n500, height: 1.5),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),
              const Spacer(flex: 3),
              AppButton(
                label: "Let's Begin",
                fullWidth: true,
                size: AppButtonSize.lg,
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.onboardingGoals),
              ).animate().slideY(begin: 0.5, duration: 500.ms, curve: Curves.easeOutExpo).fadeIn(delay: 300.ms),
            ],
          ),
        ),
      ),
    );
  }
}