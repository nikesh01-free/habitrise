import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/app_settings_model.dart';
import '../../data/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

class SettingsNotifier extends Notifier<AppSettingsModel> {
  @override
  AppSettingsModel build() {
    final repo = ref.read(settingsRepositoryProvider);
    return repo.getSettings();
  }

  Future<void> updateThemeMode(String themeMode) async {
    final updated = state.copyWith(themeMode: themeMode);
    await _save(updated);
  }

  Future<void> toggleNotifications(bool enabled) async {
    final updated = state.copyWith(notificationsEnabled: enabled);
    await _save(updated);
  }

  Future<void> toggleStepTracking(bool enabled) async {
    final updated = state.copyWith(stepTrackingEnabled: enabled);
    await _save(updated);
  }

  Future<void> toggleReducedMotion(bool enabled) async {
    final updated = state.copyWith(reducedMotionEnabled: enabled);
    await _save(updated);
  }

  Future<void> toggleGymFeature(bool enabled) async {
    final updated = state.copyWith(gymFeatureEnabled: enabled);
    await _save(updated);
  }

  Future<void> _save(AppSettingsModel updated) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.updateSettings(updated);
    state = updated;
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettingsModel>(
  () {
    return SettingsNotifier();
  },
);

final themeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(settingsProvider);
  switch (settings.themeMode) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
});
