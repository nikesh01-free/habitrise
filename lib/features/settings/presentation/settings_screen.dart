import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/app_modal.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/storage/local_box_names.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/providers/permissions_providers.dart';
import '../../profile/presentation/providers/profile_providers.dart';
import '../../profile/data/models/profile_model.dart';
import 'widgets/profile_edit_bottom_sheet.dart';
import 'providers/settings_providers.dart';
import '../../settings/data/models/app_settings_model.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<void> _handlePermission(
    Permission perm,
    PermissionStatus status,
  ) async {
    if (status.isGranted) {
      if (mounted) {
        AppToast.show(
          context,
          'Permission already granted',
          type: AppToastType.success,
        );
      }
    } else if (status.isPermanentlyDenied) {
      await ref.read(permissionsProvider.notifier).openSystemSettings();
    } else {
      await ref.read(permissionsProvider.notifier).requestPermission(perm);
    }
  }

  void _openProfileSheet() {
    AppModal.showSheet(context: context, child: const ProfileEditBottomSheet());
  }

  void _showResetConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _ResetConfirmDialog(
        onConfirm: () async {
          await _performHardReset();
        },
      ),
    );
  }

  Future<void> _exportDebugLogs() async {
    try {
      final box = Hive.box(LocalBoxNames.appLogs);
      if (box.isEmpty) {
        if (mounted) AppToast.show(context, 'No logs to export');
        return;
      }
      final logs = box.values.toList();
      final logString = logs.map((e) => e.toString()).join('\n\n---\n\n');

      // In a real app we might use share_plus, but for now we can just show it or print it.
      // Since share_plus is in pubspec, let's use it!
      // But we need to import it. Let's just print to console for simplicity if share_plus isn't imported,
      // or show a dialog. Let's show a dialog with the logs.
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Debug Logs'),
            content: SingleChildScrollView(child: Text(logString)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          'Failed to export logs',
          type: AppToastType.error,
        );
      }
    }
  }

  Future<void> _clearDebugLogs() async {
    try {
      final box = Hive.box(LocalBoxNames.appLogs);
      await box.clear();
      if (mounted) {
        AppToast.show(context, 'Logs cleared', type: AppToastType.success);
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          'Failed to clear logs',
          type: AppToastType.error,
        );
      }
    }
  }

  Future<void> _performHardReset() async {
    try {
      await Future.wait([
        Hive.box(LocalBoxNames.habits).clear(),
        Hive.box(LocalBoxNames.habitLogs).clear(),
        Hive.box(LocalBoxNames.waterLogs).clear(),
        Hive.box(LocalBoxNames.stepLogs).clear(),
        Hive.box(LocalBoxNames.focusSessions).clear(),
        Hive.box(LocalBoxNames.moodLogs).clear(),
        Hive.box(LocalBoxNames.appProfile).clear(),
        Hive.box(LocalBoxNames.appSettings).clear(),
        Hive.box(LocalBoxNames.rewards).clear(),
        Hive.box(LocalBoxNames.mealLogs).clear(),
        Hive.box(LocalBoxNames.sleepLogs).clear(),
        Hive.box(LocalBoxNames.gymSchedule).clear(),
        Hive.box(LocalBoxNames.gymWorkoutLogs).clear(),
        Hive.box(LocalBoxNames.meta).clear(),
      ]);

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (mounted) {
        AppToast.show(context, 'Reset complete', type: AppToastType.success);
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } catch (e) {
      AppLogger.error('Wipe procedure failure', e);
      if (mounted) {
        AppToast.show(
          context,
          'Reset had some failures',
          type: AppToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final profile = ref.watch(profileProvider);
    final permState = ref.watch(permissionsProvider);
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppNeutral.n900 : AppNeutral.n50,
      body: RefreshIndicator(
        onRefresh: () async {},
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(isDark)),
            SliverToBoxAdapter(child: _buildProfileCard(profile, isDark)),
            SliverToBoxAdapter(
              child: _buildSection('Appearance', AppIcons.theme, [
                _buildThemeSelector(settings, isDark),
              ], isDark),
            ),
            SliverToBoxAdapter(
              child: _buildSection('Permissions', AppIcons.lock, [
                _buildPermissionTile(
                  icon: AppIcons.notification,
                  title: 'Notifications',
                  subtitle: 'Receive reminders',
                  status: permState.notifications,
                  onTap: () => _handlePermission(
                    Permission.notification,
                    permState.notifications,
                  ),
                  isDark: isDark,
                ),
                _buildPermissionTile(
                  icon: AppIcons.steps,
                  title: 'Activity Tracking',
                  subtitle: 'Count steps & movement',
                  status: permState.activity,
                  onTap: () => _handlePermission(
                    PermissionService().activityPermission,
                    permState.activity,
                  ),
                  isDark: isDark,
                ),
              ], isDark),
            ),
            SliverToBoxAdapter(
              child: _buildSection('Preferences', AppIcons.settings, [
                _buildToggleTile(
                  icon: AppIcons.animation,
                  title: 'Reduced Motion',
                  subtitle: 'Minimize animations',
                  value: settings.reducedMotionEnabled,
                  onChanged: (v) => ref
                      .read(settingsProvider.notifier)
                      .toggleReducedMotion(v),
                  isDark: isDark,
                ),
                _buildToggleTile(
                  icon: Icons.fitness_center,
                  title: 'Gym Tracker',
                  subtitle: 'Workout & strength logging',
                  value: settings.gymFeatureEnabled,
                  onChanged: (v) =>
                      ref.read(settingsProvider.notifier).toggleGymFeature(v),
                  isDark: isDark,
                ),
              ], isDark),
            ),
            SliverToBoxAdapter(
              child: _buildSection('Data Management', Icons.data_usage, [
                _buildActionTile(
                  icon: Icons.bug_report,
                  title: 'Export Debug Logs',
                  subtitle: 'Save local crash logs',
                  onTap: _exportDebugLogs,
                  isDark: isDark,
                ),
                _buildActionTile(
                  icon: Icons.clear_all,
                  title: 'Clear Debug Logs',
                  subtitle: 'Remove saved crash logs',
                  onTap: _clearDebugLogs,
                  isDark: isDark,
                ),
              ], isDark),
            ),
            SliverToBoxAdapter(child: _buildDangerZone(isDark)),
            SliverToBoxAdapter(child: _buildFooter(isDark)),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1E2E), const Color(0xFF16213E)]
              : [AppColors.primary500, AppColors.primary600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary500.withAlpha(50),
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
              color: Colors.white.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: const Icon(AppIcons.settings, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: AppTextStyles.h2.copyWith(color: Colors.white),
              ),
              Text(
                'Customize your experience',
                style: AppTextStyles.bodyS.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildProfileCard(ProfileModel? profile, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppNeutral.n800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppNeutral.n700 : AppNeutral.n200),
      ),
      child: InkWell(
        onTap: _openProfileSheet,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary500, AppColors.primary700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  profile?.displayName.isNotEmpty == true
                      ? profile!.displayName[0].toUpperCase()
                      : '?',
                  style: AppTextStyles.h3.copyWith(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile?.displayName.isNotEmpty == true
                        ? profile!.displayName
                        : 'Champion',
                    style: AppTextStyles.h4.copyWith(
                      color: isDark ? Colors.white : AppNeutral.n900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile != null
                        ? 'Focus: ${profile.userType.toUpperCase()}'
                        : 'Setup your profile',
                    style: AppTextStyles.bodyS.copyWith(color: AppNeutral.n500),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary500.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                AppIcons.edit,
                color: AppColors.primary500,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.05);
  }

  Widget _buildSection(
    String title,
    IconData icon,
    List<Widget> children,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppNeutral.n500, size: 18),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: AppTextStyles.bodyS.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppNeutral.n500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppNeutral.n800 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppNeutral.n700 : AppNeutral.n200,
              ),
            ),
            child: Column(
              children: children.asMap().entries.map((entry) {
                return Column(
                  children: [
                    entry.value,
                    if (entry.key < children.length - 1)
                      Divider(
                        height: 1,
                        indent: 60,
                        color: isDark ? AppNeutral.n700 : AppNeutral.n100,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (150 + children.length * 50).ms);
  }

  Widget _buildThemeSelector(AppSettingsModel settings, bool isDark) {
    final options = ['system', 'light', 'dark'];
    final icons = [Icons.phone_android, Icons.light_mode, Icons.dark_mode];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Theme',
            style: AppTextStyles.bodyM.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppNeutral.n900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(options.length, (i) {
              final isSelected = settings.themeMode == options[i];
              return Expanded(
                child: GestureDetector(
                  onTap: () => ref
                      .read(settingsProvider.notifier)
                      .updateThemeMode(options[i]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary500
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary500
                            : (isDark ? AppNeutral.n700 : AppNeutral.n200),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          icons[i],
                          color: isSelected ? Colors.white : AppNeutral.n500,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          options[i],
                          style: AppTextStyles.bodyS.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppNeutral.n500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required PermissionStatus status,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final isGranted = status.isGranted;
    final isLocked = status.isPermanentlyDenied;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isGranted
                    ? AppSemantic.success.withAlpha(20)
                    : AppNeutral.n500.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isGranted ? AppSemantic.success : AppNeutral.n500,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppNeutral.n900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyS.copyWith(color: AppNeutral.n500),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isGranted
                    ? AppSemantic.success.withAlpha(20)
                    : (isDark ? AppNeutral.n700 : AppNeutral.n100),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isGranted ? 'Allowed' : (isLocked ? 'Blocked' : 'Tap to allow'),
                style: AppTextStyles.bodyS.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isGranted ? AppSemantic.success : AppNeutral.n500,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary500.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary500, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyM.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppNeutral.n900,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyS.copyWith(color: AppNeutral.n500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary500.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary500, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppNeutral.n900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyS.copyWith(color: AppNeutral.n500),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppNeutral.n500),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZone(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppSemantic.error.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppSemantic.error.withAlpha(30)),
      ),
      child: InkWell(
        onTap: _showResetConfirmDialog,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppSemantic.error.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                AppIcons.delete,
                color: AppSemantic.error,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reset All Data',
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppSemantic.error,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Clear everything and start fresh',
                    style: AppTextStyles.bodyS.copyWith(color: AppNeutral.n500),
                  ),
                ],
              ),
            ),
            const Icon(AppIcons.arrowRight, color: AppSemantic.error, size: 20),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.05);
  }

  Widget _buildFooter(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? AppNeutral.n800 : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10),
              ],
            ),
            child: Center(
              child: Icon(
                AppIcons.shield,
                color: AppColors.primary500,
                size: 22,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'HabitRise v1.0.1',
            style: AppTextStyles.bodyS.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppNeutral.n900,
            ),
          ),
          Text(
            'Built with care for your wellbeing',
            style: AppTextStyles.bodyS.copyWith(
              color: AppNeutral.n500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }
}

class _ResetConfirmDialog extends StatefulWidget {
  final VoidCallback onConfirm;

  const _ResetConfirmDialog({required this.onConfirm});

  @override
  State<_ResetConfirmDialog> createState() => _ResetConfirmDialogState();
}

class _ResetConfirmDialogState extends State<_ResetConfirmDialog> {
  late final TextEditingController _textCtrl;
  bool _canReset = false;

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    final match = value.trim().toUpperCase() == 'RESET';
    if (_canReset != match) {
      setState(() => _canReset = match);
    }
  }

  void _triggerReset() {
    if (!_canReset) return;
    Navigator.of(context, rootNavigator: true).pop();
    widget.onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppModal(
      title: 'Reset Everything?',
      description:
          'All your habits, logs, and progress will be permanently deleted.',
      isDangerPrimary: true,
      icon: AppIcons.warning,
      primaryLabel: 'Reset Now',
      secondaryLabel: 'Cancel',
      onPrimary: _canReset
          ? _triggerReset
          : () => AppToast.show(
              context,
              'Type RESET to confirm',
              type: AppToastType.warning,
            ),
      onSecondary: () => Navigator.of(context, rootNavigator: true).pop(),
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: TextField(
          controller: _textCtrl,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyM.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: isDark ? Colors.white : AppNeutral.n900,
          ),
          onChanged: _onTextChanged,
          onSubmitted: (_) => _triggerReset(),
          decoration: InputDecoration(
            hintText: 'TYPE RESET',
            filled: true,
            fillColor: isDark ? AppNeutral.n800 : AppNeutral.n50,
            hintStyle: const TextStyle(
              letterSpacing: 1,
              color: AppNeutral.n500,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppNeutral.n700 : AppNeutral.n200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _canReset ? AppSemantic.success : AppSemantic.error,
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
