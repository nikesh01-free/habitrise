import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitrise/core/theme/app_colors.dart';
import 'package:habitrise/core/theme/app_text_styles.dart';
import 'package:habitrise/core/theme/app_icons.dart';
import 'package:habitrise/core/widgets/app_button.dart';
import 'package:habitrise/core/widgets/app_toast.dart';
import 'package:habitrise/features/focus/presentation/providers/focus_providers.dart';
import 'package:habitrise/features/focus/presentation/focus_history_screen.dart';

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _customController = TextEditingController();
  int _selectedMinutes = 25;
  bool _isSelecting = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  String _formatTime(int totalSecs) {
    final mins = (totalSecs / 60).floor();
    final secs = totalSecs % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _getPhaseMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Rise and shine!';
    if (hour < 17) return 'Afternoon focus mode';
    return 'Wind down with focus';
  }

  Future<void> _handleStart() async {
    HapticFeedback.mediumImpact();
    int finalMins = _selectedMinutes;
    if (_customController.text.isNotEmpty) {
      final parsed = int.tryParse(_customController.text.trim());
      if (parsed == null || parsed < 1) {
        AppToast.show(context, 'Enter valid minutes', type: AppToastType.warning);
        return;
      }
      if (parsed > 300) {
        AppToast.show(context, 'Max 300 mins', type: AppToastType.warning);
        return;
      }
      finalMins = parsed;
    }

    if (finalMins <= 0) {
      AppToast.show(context, 'Select duration', type: AppToastType.warning);
      return;
    }

    try {
      await ref.read(focusTimerProvider.notifier).startSession(finalMins, 'focus');
    } catch (e) {
      if (mounted) {
        AppToast.show(context, 'Timer failed to start', type: AppToastType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final timerState = ref.watch(focusTimerProvider);
    final isTimerActive = timerState.isRunning || timerState.isPaused;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppNeutral.n900 : AppNeutral.n50,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {},
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: isTimerActive
                ? _buildActiveTimer(timerState, isDark)
                : _buildSetupMode(isDark),
          ),
        ),
      ),
      bottomNavigationBar: isTimerActive
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 24, right: 24),
                child: TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FocusHistoryScreen()),
                  ),
                  icon: Icon(AppIcons.history, size: 18),
                  label: const Text('View History'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppNeutral.n500,
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildActiveTimer(FocusTimerState state, bool isDark) {
    final totalDuration = (state.activeSession?.plannedMinutes ?? 1) * 60;
    final double rawProgress = totalDuration > 0
        ? state.remainingSeconds / totalDuration
        : 0.0;
    final double progress = (rawProgress.isNaN || rawProgress.isInfinite)
        ? 0.0
        : rawProgress.clamp(0.0, 1.0);
    final elapsedMins = ((state.activeSession?.plannedMinutes ?? 1) * 60 - state.remainingSeconds) ~/ 60;

    return Container(
      key: const ValueKey('focus_active'),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Top bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                state.isPaused ? 'PAUSED' : 'FOCUSING',
                style: AppTextStyles.bodyS.copyWith(
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF7C3AED),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FocusHistoryScreen()),
                ),
                icon: const Icon(AppIcons.history, color: AppNeutral.n500),
              ),
            ],
          ).animate().fadeIn(),

          const Spacer(),

          // Timer ring
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, val, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: CircularProgressIndicator(
                      value: 1,
                      strokeWidth: 8,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? AppNeutral.n800 : AppNeutral.n100,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: CircularProgressIndicator(
                      value: val,
                      strokeWidth: 8,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF7C3AED),
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(state.remainingSeconds),
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppNeutral.n900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.isPaused ? 'Tap play to resume' : 'Stay focused',
                        style: AppTextStyles.bodyS.copyWith(
                          color: AppNeutral.n500,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ).animate().scale(delay: 200.ms, curve: Curves.elasticOut),

          const SizedBox(height: 32),

          // Stats row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? AppNeutral.n800 : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statItem('Planned', '${state.activeSession?.plannedMinutes ?? 0}m'),
                Container(width: 1, height: 30, color: AppNeutral.n700),
                _statItem('Elapsed', '${elapsedMins}m'),
                Container(width: 1, height: 30, color: AppNeutral.n700),
                _statItem('Remaining', '${state.remainingSeconds ~/ 60}m'),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

          const Spacer(),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _controlBtn(
                icon: state.isPaused ? AppIcons.play : AppIcons.pause,
                color: const Color(0xFF7C3AED),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  if (state.isPaused) {
                    ref.read(focusTimerProvider.notifier).resume();
                  } else {
                    ref.read(focusTimerProvider.notifier).pause();
                  }
                },
                size: 72,
              ),
              const SizedBox(width: 24),
              _controlBtn(
                icon: AppIcons.stop,
                color: AppSemantic.error,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ref.read(focusTimerProvider.notifier).cancel();
                },
                size: 60,
              ),
            ],
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 24),

          TextButton(
            onPressed: () => ref.read(focusTimerProvider.notifier).forceComplete(),
            child: Text(
              'Complete Early',
              style: AppTextStyles.bodyS.copyWith(
                color: AppNeutral.n500,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.bodyL.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppNeutral.n900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.bodyS.copyWith(color: AppNeutral.n500),
        ),
      ],
    );
  }

  Widget _controlBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    double size = 64,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(60),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.45),
      ),
    );
  }

  Widget _buildSetupMode(bool isDark) {
    final focusPurple = const Color(0xFF7C3AED);

    return SingleChildScrollView(
      key: const ValueKey('focus_setup'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 32),

          // Hero section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                    : [focusPurple.withAlpha(15), focusPurple.withAlpha(5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: focusPurple.withAlpha(30),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: focusPurple.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    AppIcons.focus,
                    color: focusPurple,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Deep Focus',
                  style: AppTextStyles.h2.copyWith(
                    color: isDark ? Colors.white : AppNeutral.n900,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getPhaseMessage(),
                  style: AppTextStyles.bodyM.copyWith(color: AppNeutral.n500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.1),

          const SizedBox(height: 32),

          // Presets
          Text(
            'Quick Start',
            style: AppTextStyles.bodyS.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: AppNeutral.n500,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              _presetBtn(15, 'Quick', Icons.flash_on, isDark),
              const SizedBox(width: 12),
              _presetBtn(25, 'Standard', Icons.timer, isDark),
              const SizedBox(width: 12),
              _presetBtn(45, 'Long', Icons.hourglass_bottom, isDark),
            ],
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 24),

          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: AppNeutral.n700)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: AppTextStyles.bodyS.copyWith(color: AppNeutral.n500),
                ),
              ),
              Expanded(child: Divider(color: AppNeutral.n700)),
            ],
          ),

          const SizedBox(height: 24),

          // Custom input
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppNeutral.n800 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isSelecting
                    ? focusPurple.withAlpha(60)
                    : (isDark ? AppNeutral.n700 : AppNeutral.n200),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Custom Duration',
                  style: AppTextStyles.bodyM.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppNeutral.n900,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppNeutral.n900,
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: AppTextStyles.h3.copyWith(
                            color: AppNeutral.n400,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: isDark ? AppNeutral.n700 : AppNeutral.n50,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        onTap: () {
                          setState(() => _isSelecting = true);
                        },
                        onChanged: (v) {
                          if (v.isNotEmpty && _selectedMinutes != 0) {
                            setState(() => _selectedMinutes = 0);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'minutes',
                      style: AppTextStyles.bodyM.copyWith(
                        color: AppNeutral.n500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 32),

          // Start button
          AppButton(
            label: 'Begin Session',
            fullWidth: true,
            size: AppButtonSize.lg,
            onPressed: _handleStart,
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

          const SizedBox(height: 16),

          // View History button
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FocusHistoryScreen()),
            ),
            icon: Icon(AppIcons.history, size: 18),
            label: const Text('View History'),
            style: TextButton.styleFrom(
              foregroundColor: AppNeutral.n500,
            ),
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _presetBtn(int mins, String label, IconData icon, bool isDark) {
    final isSelected = _selectedMinutes == mins && _customController.text.isEmpty;
    final focusPurple = const Color(0xFF7C3AED);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() {
            _selectedMinutes = mins;
            _customController.clear();
            _isSelecting = false;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected
                ? focusPurple
                : (isDark ? AppNeutral.n800 : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? focusPurple
                  : (isDark ? AppNeutral.n700 : AppNeutral.n200),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: focusPurple.withAlpha(50),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppNeutral.n400 : AppNeutral.n500),
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                '$mins',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white : AppNeutral.n900),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTextStyles.bodyS.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white.withAlpha(180)
                      : AppNeutral.n500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}