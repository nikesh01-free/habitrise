import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/splash_screen.dart';
import 'features/onboarding/presentation/welcome_screen.dart';
import 'features/onboarding/presentation/goal_selection_screen.dart';
import 'features/onboarding/presentation/starter_habits_screen.dart';
import 'features/onboarding/presentation/permissions_screen.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/gym/presentation/screens/gym_schedule_screen.dart';
import 'dart:ui';
import 'core/utils/app_logger.dart';
import 'core/storage/hive_storage_service.dart';
import 'core/services/notification_service.dart';
import 'features/settings/presentation/providers/settings_providers.dart';
import 'core/providers/permissions_providers.dart';
import 'features/steps/presentation/providers/step_providers.dart';
import 'core/widgets/storage_error_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    final exception = details.exceptionAsString();

    if (exception.contains('_pressedKeys.containsKey(event.physicalKey)')) {
      return;
    }

    FlutterError.presentError(details);
    AppLogger.error('Flutter Error Catch', details.exception, details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error('Async Platform Error', error, stack);
    return true;
  };

  bool storageSuccess = true;
  try {
    await HiveStorageService.init();
    await NotificationService().initialize();
  } catch (error, stack) {
    storageSuccess = false;
    AppLogger.error('CRITICAL FATAL start-up crash', error, stack);
  }

  runApp(ProviderScope(child: HabitRiseApp(storageSuccess: storageSuccess)));
}

class HabitRiseApp extends ConsumerStatefulWidget {
  final bool storageSuccess;
  const HabitRiseApp({super.key, required this.storageSuccess});

  @override
  ConsumerState<HabitRiseApp> createState() => _HabitRiseAppState();
}

class _HabitRiseAppState extends ConsumerState<HabitRiseApp>
    with WidgetsBindingObserver {
  DateTime? _lastResumedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final now = DateTime.now();
      if (_lastResumedAt != null &&
          now.difference(_lastResumedAt!).inSeconds < 3) {
        return;
      }
      _lastResumedAt = now;

      if (widget.storageSuccess) {
        ref.read(permissionsProvider.notifier).refresh();
        ref.read(stepProvider.notifier).refreshConnection();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If storage failed, immediately show the error screen and nothing else.
    if (!widget.storageSuccess) {
      return MaterialApp(
        title: 'HabitRise Error',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const StorageErrorScreen(),
      );
    }

    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'HabitRise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(),
      ),
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            final currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          behavior: HitTestBehavior.translucent,
          child: child!,
        );
      },
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.onboardingWelcome: (context) => const WelcomeScreen(),
        AppRoutes.onboardingGoals: (context) => const GoalSelectionScreen(),
        AppRoutes.onboardingHabits: (context) => const StarterHabitsScreen(),
        AppRoutes.onboardingPermissions: (context) => const PermissionsScreen(),
        AppRoutes.dashboard: (context) => const DashboardScreen(),
        AppRoutes.gym: (context) => const GymScheduleScreen(),
      },
    );
  }
}