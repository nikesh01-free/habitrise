import 'dart:io';
import 'package:flutter/material.dart';
import 'package:habitrise/core/theme/app_colors.dart';
import 'package:habitrise/core/theme/app_text_styles.dart';
import 'package:path_provider/path_provider.dart';

class StorageErrorScreen extends StatelessWidget {
  const StorageErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 64,
              ),
              const SizedBox(height: 24),
              Text(
                'Storage Error',
                style: AppTextStyles.h2.copyWith(color: AppColors.primary900),
              ),
              const SizedBox(height: 16),
              Text(
                'Local storage could not be opened.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyL.copyWith(color: AppColors.primary700),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Retry: easiest is to restart the app or call main() again,
                    // but simple navigation to a "restart" mechanism works.
                    // For now, since we have no complex routing here, just tell the user to restart manually,
                    // or pop if we pushed it (but we didn't). Actually, we can restart the app by calling main() again.
                    // Or simple way: Just prompt user to restart app.
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Restart Required'),
                        content: const Text('Please close the app from your recent apps screen and open it again to retry.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Retry',
                    style: AppTextStyles.bodyL.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    _showResetConfirmation(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Reset Local Data',
                    style: AppTextStyles.bodyL.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text('Are you sure you want to reset your local data? This action cannot be undone and will delete all your habits, routines, and logs.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Delete all Hive .hive and .lock files from the app documents dir
              try {
                final appDir = await getApplicationDocumentsDirectory();
                final hiveFiles = appDir
                    .listSync()
                    .whereType<File>()
                    .where((f) =>
                        f.path.endsWith('.hive') || f.path.endsWith('.lock'))
                    .toList();
                for (final file in hiveFiles) {
                  await file.delete();
                }
              } catch (_) {
                // Ignore errors — file may already be gone
              }
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (ctx2) => AlertDialog(
                    title: const Text('Data Reset'),
                    content: const Text('Data reset attempted. Please completely close and restart the app.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx2),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
