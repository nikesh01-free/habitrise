import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitrise/core/theme/app_text_styles.dart';
import 'package:habitrise/core/theme/app_colors.dart';
import 'package:habitrise/core/theme/app_radius.dart';
import 'package:habitrise/core/theme/app_icons.dart';
import 'package:habitrise/features/analytics/presentation/analytics_screen.dart';
import 'package:habitrise/features/focus/presentation/focus_screen.dart';
import 'package:habitrise/features/settings/presentation/settings_screen.dart';
import 'package:habitrise/features/calendar/presentation/calendar_screen.dart';
import 'widgets/sections/dashboard_header_section.dart';
import 'widgets/sections/dashboard_progress_section.dart';
import 'widgets/sections/dashboard_health_section.dart';
import 'widgets/sections/dashboard_focus_mood_section.dart';
import 'widgets/sections/dashboard_habit_section.dart';
import 'widgets/quick_add_bottom_sheet.dart';
import '../../habits/presentation/providers/habit_providers.dart';
import 'widgets/getting_started_card.dart';
import '../../../core/widgets/offline_banner_widget.dart';
import 'widgets/horizontal_feature_chips.dart';
import '../../gym/presentation/widgets/gym_dashboard_section.dart';
import '../../settings/presentation/providers/settings_providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _DashboardBody(
                    onStartFocus: () => _onTabTapped(1),
                    onTapWeeklyReview: () => _onTabTapped(2),
                  ),
                  const FocusScreen(key: PageStorageKey('focus_scroller')),
                  AnalyticsScreen(
                    key: const PageStorageKey('analytics_scroller'),
                    onReturnHome: () => _onTabTapped(0),
                  ),
                  CalendarScreen(
                    key: const PageStorageKey('calendar_scroller'),
                    onReturnHome: () => _onTabTapped(0),
                  ),
                  const SettingsScreen(key: PageStorageKey('settings_scroller')),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: bottomSafe > 0 ? bottomSafe + 16 : 24,
            left: 24,
            right: 24,
            child: _FloatingNavBar(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
              isDark: isDark,
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: _currentIndex == 0 ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: IgnorePointer(
          ignoring: _currentIndex != 0,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomSafe > 0 ? bottomSafe + 76 : 92),
            child: FloatingActionButton(
              onPressed: () => QuickAddBottomSheet.show(
                context,
                onNavigateToFocus: () => _onTabTapped(1),
              ),
              backgroundColor: AppColors.primary500,
              elevation: 4,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isDark;

  const _FloatingNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 15),
            blurRadius: 30,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(0, AppIcons.dashboard, 'Home', currentIndex, onTap, isDark),
          _NavItem(1, AppIcons.focus, 'Focus', currentIndex, onTap, isDark),
          _NavItem(2, AppIcons.analytics, 'Insights', currentIndex, onTap, isDark),
          _NavItem(3, AppIcons.calendar, 'Calendar', currentIndex, onTap, isDark),
          _NavItem(4, AppIcons.settings, 'Settings', currentIndex, onTap, isDark),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final int currentIndex;
  final Function(int) onTap;
  final bool isDark;

  const _NavItem(
    this.index,
    this.icon,
    this.label,
    this.currentIndex,
    this.onTap,
    this.isDark,
  );

  @override
  Widget build(BuildContext context) {
    final isSelected = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary500
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppNeutral.n500 : AppNeutral.n400),
                  size: 22,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: AppTextStyles.bodyS.copyWith(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary500
                      : (isDark ? AppNeutral.n500 : AppNeutral.n400),
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardBody extends StatefulWidget {
  final VoidCallback onStartFocus;
  final VoidCallback onTapWeeklyReview;

  const _DashboardBody({
    required this.onStartFocus,
    required this.onTapWeeklyReview,
  });

  @override
  State<_DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<_DashboardBody>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey _habitsKey = GlobalKey();
  final GlobalKey _healthKey = GlobalKey();
  final GlobalKey _focusKey = GlobalKey();
  final GlobalKey _gymKey = GlobalKey();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer(
      builder: (context, ref, child) {
        final unlocked = ref.watch(dashboardUnlockedProvider);
        return Column(
          children: [
            const OfflineBannerWidget(),
            Expanded(
              child: !unlocked
                  ? SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const DashboardHeaderSection(),
                          const SizedBox(height: 24),
                          const GettingStartedCard(),
                          const SizedBox(height: 32),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                'Your personalized metrics will appear here once you begin your journey.',
                                style: AppTextStyles.bodyS.copyWith(
                                  color: isDark ? AppNeutral.n500 : AppNeutral.n400,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        // Silent refresh - no UI feedback
                      },
                      child: SingleChildScrollView(
                        key: const PageStorageKey('dashboard_scroller'),
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const DashboardHeaderSection(),
                            const SizedBox(height: 12),
                            HorizontalFeatureChips(
                              anchors: {
                                'habits': _habitsKey,
                                'health': _healthKey,
                                'focus': _focusKey,
                                'gym': _gymKey,
                              },
                            ),
                            const SizedBox(height: 16),
                            const DashboardProgressSection(),
                            const SizedBox(height: 24),
                            DashboardHealthSection(key: _healthKey),
                            const SizedBox(height: 24),
                            DashboardHabitSection(key: _habitsKey),
                            const SizedBox(height: 24),
                            DashboardFocusMoodSection(
                              key: _focusKey,
                              onStartFocus: widget.onStartFocus,
                            ),
                            if (ref.watch(settingsProvider).gymFeatureEnabled) ...[
                              const SizedBox(height: 24),
                              GymDashboardSection(key: _gymKey),
                            ],
                            const SizedBox(height: 32),
                            _WeeklyReviewBanner(
                              isDark: isDark,
                              onTap: widget.onTapWeeklyReview,
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _WeeklyReviewBanner extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _WeeklyReviewBanner({
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppNeutral.n700, AppNeutral.n800]
                : [AppColors.primary600, AppColors.primary500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.cardRadius,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary500.withAlpha(isDark ? 20 : 50),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.insights_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Review',
                    style: AppTextStyles.bodyL.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Check your summary & streaks',
                    style: AppTextStyles.bodyS.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}