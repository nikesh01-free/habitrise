import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/providers/permissions_providers.dart';
import '../../../core/services/permission_service.dart';

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  @override
  void initState() {
    super.initState();

    // Prompt automatically on arrival to guide users frictionlessly
    Future.microtask(() async {
      await ref.read(permissionsProvider.notifier).requestAllRequired();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handlePermissionTap(
    Permission permission,
    PermissionStatus currentStatus,
  ) async {
    if (currentStatus.isPermanentlyDenied) {
      await ref.read(permissionsProvider.notifier).openSystemSettings();
    } else {
      await ref
          .read(permissionsProvider.notifier)
          .requestPermission(permission);
    }
  }

  Widget _buildPermissionRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required Permission permission,
    required PermissionStatus status,
    required bool isDark,
  }) {
    final isGranted = status.isGranted;
    final isDeniedForever = status.isPermanentlyDenied;

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary500.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary600, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyM.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppNeutral.n900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyS.copyWith(color: AppNeutral.n500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isGranted)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppSemantic.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 14),
            )
          else
            AppButton(
              label: isDeniedForever ? 'Settings' : 'Allow',
              size: AppButtonSize.sm,
              variant: isDeniedForever
                  ? AppButtonVariant.ghost
                  : AppButtonVariant.secondary,
              onPressed: () => _handlePermissionTap(permission, status),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final permState = ref.watch(permissionsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppNeutral.n900 : AppNeutral.n50,
      appBar: AppBar(title: const Text('Device Link'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Elevate Precision',
                style: AppTextStyles.h2.copyWith(
                  color: isDark ? Colors.white : AppNeutral.n900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Grant secure system tokens to unlock real-time measurement and reliable alert routines.',
                style: AppTextStyles.bodyM.copyWith(color: AppNeutral.n500),
              ),
              const SizedBox(height: 32),
              _buildPermissionRow(
                title: 'Step Monitoring',
                subtitle: 'Count natural body kinetic motion.',
                icon: Icons.directions_walk_rounded,
                permission: PermissionService().activityPermission,
                status: permState.activity,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _buildPermissionRow(
                title: 'Push Alerting',
                subtitle: 'Secure deadline notifications.',
                icon: Icons.notifications_active_rounded,
                permission: Permission.notification,
                status: permState.notifications,
                isDark: isDark,
              ),
              const Spacer(),
              AppButton(
                label: 'Proceed to Dashboard',
                fullWidth: true,
                size: AppButtonSize.lg,
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('onboarding_completed', true);
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.dashboard,
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
