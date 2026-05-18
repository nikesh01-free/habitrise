import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_assets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToNext();
    });
  }

  Future<void> _navigateToNext() async {
    try {
      await Future.delayed(const Duration(milliseconds: 2500));

      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance();
      final bool isDone = prefs.getBool('onboarding_completed') ?? false;

      if (mounted) {
        final String target = isDone
            ? AppRoutes.dashboard
            : AppRoutes.onboardingWelcome;

        await Future.delayed(const Duration(milliseconds: 100));

        if (!mounted) return;

        Navigator.of(context).pushReplacementNamed(target);
      }
    } catch (e) {
      // SILENT FALLBACK: attempt navigation to welcome anyway on serious unexpected system crash.
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.onboardingWelcome);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppNeutral.n900 : Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                    isDark
                        ? AppAssets.splashDarkLogo
                        : AppAssets.splashLightLogo,
                    width: 120,
                    height: 120,
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    duration: 800.ms,
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.1, 1.1),
                    curve: Curves.easeInOut,
                  ),

              const SizedBox(height: 32),

              SizedBox(
                width: 40,
                height: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: const LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    color: AppColors.primary500,
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
