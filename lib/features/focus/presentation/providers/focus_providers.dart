import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/focus_repository.dart';
import '../../data/models/focus_session_model.dart';

final focusRepositoryProvider = Provider<FocusRepository>((ref) {
  return FocusRepository();
});

/// Pure state holder for active timer memory
class FocusTimerState {
  final FocusSessionModel? activeSession;
  final int remainingSeconds;
  final bool isRunning;
  final bool isPaused;

  const FocusTimerState({
    this.activeSession,
    this.remainingSeconds = 0,
    this.isRunning = false,
    this.isPaused = false,
  });

  FocusTimerState copyWith({
    FocusSessionModel? activeSession,
    int? remainingSeconds,
    bool? isRunning,
    bool? isPaused,
    bool clearSession = false,
  }) {
    return FocusTimerState(
      activeSession: clearSession
          ? null
          : (activeSession ?? this.activeSession),
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}

class FocusTimerNotifier extends Notifier<FocusTimerState> {
  Timer? _ticker;
  DateTime? _targetEndTime;
  int? _pausedRemainingSeconds;

  @override
  FocusTimerState build() {
    ref.onDispose(() {
      _ticker?.cancel();
    });
    return const FocusTimerState();
  }

  Future<void> startSession(int minutes, String category) async {
    if (state.isRunning || state.isPaused) {
      throw Exception('A focus timer is already running.');
    }

    if (minutes < 1 || minutes > 300) {
      throw Exception('Focus duration must be between 1 and 300 minutes.');
    }

    final repo = ref.read(focusRepositoryProvider);
    try {
      final session = await repo.startSession(
        category: category,
        plannedMinutes: minutes,
      );

      _targetEndTime = DateTime.now().add(Duration(minutes: minutes));

      state = FocusTimerState(
        activeSession: session,
        remainingSeconds: minutes * 60,
        isRunning: true,
        isPaused: false,
      );

      _startTicker();
    } catch (e) {
      throw Exception('Unable to save focus session. Please try again.');
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_targetEndTime == null) {
        timer.cancel();
        return;
      }
      final now = DateTime.now();
      final remaining = _targetEndTime!.difference(now).inSeconds;

      if (remaining > 0) {
        // Only trigger state update if the integer seconds changed, to save rebuild cycles
        if (remaining != state.remainingSeconds) {
          state = state.copyWith(remainingSeconds: remaining);
        }
      } else {
        timer.cancel();
        state = state.copyWith(remainingSeconds: 0);
        _handleAutoCompletion();
      }
    });
  }

  void pause() {
    _ticker?.cancel();
    // Snapshot the remaining seconds at the moment of pause before any tick can update it
    _pausedRemainingSeconds = state.remainingSeconds;
    state = state.copyWith(isRunning: false, isPaused: true);
    // _targetEndTime is now invalidated; we will rebuild it from _pausedRemainingSeconds on resume.
  }

  void resume() {
    final remaining = _pausedRemainingSeconds ?? state.remainingSeconds;
    if (remaining <= 0) return;
    _targetEndTime = DateTime.now().add(Duration(seconds: remaining));
    _pausedRemainingSeconds = null;
    state = state.copyWith(isRunning: true, isPaused: false);
    _startTicker();
  }

  Future<void> cancel() async {
    _ticker?.cancel();
    final session = state.activeSession;
    if (session != null) {
      final repo = ref.read(focusRepositoryProvider);
      // Set progress made so far in minutes, mark cancelled
      final elapsedSeconds =
          (session.plannedMinutes * 60) - state.remainingSeconds;
      final elapsedMins = (elapsedSeconds / 60).floor();

      await repo.finishSession(
        id: session.id,
        completedMinutes: elapsedMins,
        status: 'cancelled',
      );
    }

    ref.invalidate(todayFocusSessionsProvider);
    state = const FocusTimerState(); // reset
  }

  Future<void> forceComplete() async {
    _ticker?.cancel();
    final session = state.activeSession;
    if (session != null) {
      final repo = ref.read(focusRepositoryProvider);
      final elapsedSec = (session.plannedMinutes * 60) - state.remainingSeconds;
      final elapsedMins = (elapsedSec / 60).floor();

      await repo.finishSession(
        id: session.id,
        completedMinutes: elapsedMins,
        status: 'partial',
      );
      ref.invalidate(todayFocusSessionsProvider);
    }
    state = const FocusTimerState();
  }

  Future<void> deleteHistoricalSession(String id) async {
    final repo = ref.read(focusRepositoryProvider);
    await repo.deleteSession(id);
    if (state.activeSession?.id == id) {
      _ticker?.cancel();
      state = const FocusTimerState();
    }
    ref.invalidate(todayFocusSessionsProvider);
  }

  Future<void> _handleAutoCompletion() async {
    final session = state.activeSession;
    if (session != null) {
      final repo = ref.read(focusRepositoryProvider);
      await repo.finishSession(
        id: session.id,
        completedMinutes: session.plannedMinutes,
        status: 'completed',
      );
      ref.invalidate(todayFocusSessionsProvider);
    }
    state = const FocusTimerState();
  }
}

final focusTimerProvider =
    NotifierProvider<FocusTimerNotifier, FocusTimerState>(() {
      return FocusTimerNotifier();
    });

/// Repository aggregate fetches for history and totals
final todayFocusSessionsProvider =
    FutureProvider.autoDispose<List<FocusSessionModel>>((ref) async {
      final repo = ref.watch(focusRepositoryProvider);
      final history = repo.getHistory();
      final today = DateTime.now();

      // Filter to just today's sessions
      return history.where((session) {
        return session.startedAt.year == today.year &&
            session.startedAt.month == today.month &&
            session.startedAt.day == today.day;
      }).toList();
    });

final todayFocusMinutesProvider = Provider.autoDispose<int>((ref) {
  final sessionsAsync = ref.watch(todayFocusSessionsProvider);
  return sessionsAsync.maybeWhen(
    data: (sessions) => sessions.fold(0, (sum, s) => sum + s.completedMinutes),
    orElse: () => 0,
  );
});
