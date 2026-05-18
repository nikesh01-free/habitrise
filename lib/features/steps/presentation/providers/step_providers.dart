import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pedometer/pedometer.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/repositories/step_repository.dart';

final stepRepositoryProvider = Provider<StepRepository>((ref) {
  return StepRepository();
});

class StepSystemState {
  final int currentSteps;
  final int goalSteps;
  final bool isSensorAvailable;
  final bool isPermissionGranted;
  final bool isLoading;

  const StepSystemState({
    this.currentSteps = 0,
    this.goalSteps = 8000,
    this.isSensorAvailable = true,
    this.isPermissionGranted = false,
    this.isLoading = false,
  });

  StepSystemState copyWith({
    int? currentSteps,
    int? goalSteps,
    bool? isSensorAvailable,
    bool? isPermissionGranted,
    bool? isLoading,
  }) {
    return StepSystemState(
      currentSteps: currentSteps ?? this.currentSteps,
      goalSteps: goalSteps ?? this.goalSteps,
      isSensorAvailable: isSensorAvailable ?? this.isSensorAvailable,
      isPermissionGranted: isPermissionGranted ?? this.isPermissionGranted,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class StepNotifier extends AutoDisposeNotifier<StepSystemState> {
  StreamSubscription<StepCount>? _subscription;
  int? _initialSessionStepCount;
  int _startDayStepBase = 0;

  @override
  StepSystemState build() {
    ref.onDispose(() {
      _subscription?.cancel();
    });

    _initializeState();
    return const StepSystemState(isLoading: true);
  }

  Future<void> _initializeState() async {
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final repo = ref.read(stepRepositoryProvider);

    final log = repo.getStepsByDate(dateStr);
    _startDayStepBase = log?.steps ?? 0;

    state = StepSystemState(
      currentSteps: _startDayStepBase,
      goalSteps: log?.goalSteps ?? 8000,
      isLoading: false,
    );

    await _checkAndConnectSensor();
  }

  Future<void> refreshConnection() async {
    await _checkAndConnectSensor();
  }

  Future<void> _checkAndConnectSensor() async {
    try {
      final perm = PermissionService().activityPermission;
      var status = await perm.status;
      if (status.isGranted) {
        state = state.copyWith(isPermissionGranted: true);
        // DISABLE AUTO-START FOR DIAGNOSTIC ISOLATION
        // _startListening();
      } else {
        state = state.copyWith(isPermissionGranted: false);
      }
    } catch (e, stack) {
      AppLogger.error('Error checking sensor connection', e, stack);
      state = state.copyWith(isSensorAvailable: false);
    }
  }

  Future<void> requestPermission() async {
    try {
      final perm = PermissionService().activityPermission;
      final status = await perm.request();
      if (status.isGranted) {
        state = state.copyWith(isPermissionGranted: true);
        _startListening();
      } else {
        state = state.copyWith(isPermissionGranted: false);
      }
    } catch (e, stack) {
      AppLogger.error('Error requesting sensor permission', e, stack);
      state = state.copyWith(isSensorAvailable: false);
    }
  }

  void _startListening() {
    AppLogger.debug('Pedometer: Scheduling initialization via Microtask...');
    Future.microtask(() {
      AppLogger.debug('Pedometer: Starting initialization attempt now...');
      try {
        _subscription?.cancel();
        AppLogger.debug('Pedometer: Listening to stepCountStream...');
        _subscription = Pedometer.stepCountStream.listen(
          _onStepCount,
          onError: (error) {
            AppLogger.error('Pedometer Stream Error detected', error);
            state = state.copyWith(isSensorAvailable: false);
          },
          cancelOnError: false,
        );
        AppLogger.info('Pedometer: Stream listener successfully attached.');
      } catch (e, stack) {
        AppLogger.error('Pedometer Stream initialization exception', e, stack);
        state = state.copyWith(isSensorAvailable: false);
      }
    });
  }

  void _onStepCount(StepCount event) {
    if (_initialSessionStepCount == null) {
      _initialSessionStepCount = event.steps;
      return;
    }

    final delta = event.steps - _initialSessionStepCount!;
    if (delta < 0) {
      // System rebooted during session? Reset base.
      _initialSessionStepCount = event.steps;
      return;
    }

    final totalToday = _startDayStepBase + delta;

    if (totalToday != state.currentSteps) {
      state = state.copyWith(currentSteps: totalToday);
      _persistStepsSilently(totalToday);
    }
  }

  Future<void> _persistStepsSilently(int steps) async {
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    try {
      await ref
          .read(stepRepositoryProvider)
          .saveSteps(
            logDate: dateStr,
            steps: steps,
            source: 'sensor',
            goalSteps: state.goalSteps,
          );
    } catch (e) {
      // Silent fail on auto-persist, user manually handles persistence if hard error
    }
  }

  Future<void> addManualSteps(int amount) async {
    if (amount <= 0) throw Exception('Invalid step count.');

    final newTotal = state.currentSteps + amount;
    if (newTotal > 100000) throw Exception('Invalid step count.');

    // Important: Update both session and day base so logic doesn't reset on next sensor event
    _startDayStepBase = newTotal;
    _initialSessionStepCount = null; // Force re-sync on next sensor tick

    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    try {
      await ref
          .read(stepRepositoryProvider)
          .saveSteps(
            logDate: dateStr,
            steps: newTotal,
            source: 'manual',
            goalSteps: state.goalSteps,
          );
      state = state.copyWith(currentSteps: newTotal);
    } catch (e) {
      throw Exception('Unable to save steps. Please try again.');
    }
  }

  Future<void> updateGoal(int newGoal) async {
    if (newGoal < 500 || newGoal > 100000) {
      throw Exception('Goal steps must be between 500 and 100000.');
    }

    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    try {
      await ref
          .read(stepRepositoryProvider)
          .saveSteps(
            logDate: dateStr,
            steps: state.currentSteps,
            source: 'manual',
            goalSteps: newGoal,
          );
      state = state.copyWith(goalSteps: newGoal);
    } catch (e) {
      throw Exception('Unable to save steps. Please try again.');
    }
  }
}

final stepProvider = AutoDisposeNotifierProvider<StepNotifier, StepSystemState>(
  () {
    return StepNotifier();
  },
);
