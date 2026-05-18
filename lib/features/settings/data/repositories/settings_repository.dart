import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/storage/local_box_names.dart';
import '../models/app_settings_model.dart';

class SettingsRepository {
  final Box _box = Hive.box(LocalBoxNames.appSettings);
  static const String _singletonKey = 'current_settings';
  final _uuid = const Uuid();

  AppSettingsModel getSettings() {
    final raw = _box.get(_singletonKey);
    if (raw != null && raw is Map) {
      try {
        return AppSettingsModel.fromMap(Map<String, dynamic>.from(raw));
      } catch (_) {}
    }
    // Factory default configuration
    final now = DateTime.now();
    return AppSettingsModel(
      id: _uuid.v4(),
      accentColor: '#3B82F6',
      themeMode: 'system',
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> updateSettings(AppSettingsModel updated) async {
    final now = DateTime.now();
    final settings = updated.copyWith(updatedAt: now);
    await _box.put(_singletonKey, settings.toMap());
  }
}
