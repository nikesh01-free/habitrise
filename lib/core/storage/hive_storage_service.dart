import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'local_box_names.dart';
import 'schema_version.dart';

class HiveStorageService {
  /// Initialize Hive and pre-open all essential data boxes safely
  static Future<void> init() async {
    try {
      debugPrint('🌱 Initializing Hive local storage...');
      await Hive.initFlutter();

      // Register future type adapters here later in Phase 4.2

      // 1. Open Core Boxes with full recovery fallbacks
      await _openAllRequiredBoxes();

      // 2. Perform version and schema check
      await _runSchemaVerification();

      debugPrint('✅ Local storage init successful. Ready.');
    } catch (e, stack) {
      debugPrint('❌ CRITICAL HIVE INITIALIZATION FAILURE: $e');
      debugPrint(stack.toString());
      // In production, maybe delete corrupt box files and retry if absolutely critical
      rethrow;
    }
  }

  static Future<void> _openAllRequiredBoxes() async {
    final futures = [
      Hive.openBox(LocalBoxNames.meta),
      Hive.openBox(LocalBoxNames.appProfile),
      Hive.openBox(LocalBoxNames.habits),
      Hive.openBox(LocalBoxNames.habitLogs),
      Hive.openBox(LocalBoxNames.waterLogs),
      Hive.openBox(LocalBoxNames.stepLogs),
      Hive.openBox(LocalBoxNames.focusSessions),
      Hive.openBox(LocalBoxNames.moodLogs),
      Hive.openBox(LocalBoxNames.appSettings),
      Hive.openBox(LocalBoxNames.rewards),
      Hive.openBox(LocalBoxNames.mealLogs),
      Hive.openBox(LocalBoxNames.sleepLogs),
      Hive.openBox(LocalBoxNames.gymSchedule),
      Hive.openBox(LocalBoxNames.gymWorkoutLogs),
      Hive.openBox(LocalBoxNames.appLogs),
    ];

    await Future.wait(futures);
  }

  static Future<void> _runSchemaVerification() async {
    final metaBox = Hive.box(LocalBoxNames.meta);
    final int storedVersion =
        metaBox.get(SchemaVersion.key, defaultValue: SchemaVersion.current)
            as int;

    if (storedVersion < SchemaVersion.current) {
      debugPrint(
        '🔄 Database Schema Outdated ($storedVersion < ${SchemaVersion.current}). Running migrations...',
      );
      await _performMigrations(storedVersion, SchemaVersion.current);
      await metaBox.put(SchemaVersion.key, SchemaVersion.current);
    } else if (storedVersion > SchemaVersion.current) {
      debugPrint(
        '⚠️ Local database downgrade detected. Stored version is higher than app binary allows.',
      );
    } else {
      debugPrint(
        '📦 Schema version matched at v${SchemaVersion.current}. No migrations needed.',
      );
      // Save version initially if it didn't exist
      await metaBox.put(SchemaVersion.key, SchemaVersion.current);
    }
  }

  static Future<void> _performMigrations(int oldVer, int newVer) async {
    // TODO Phase X: Future logic placeholders for incremental migrations
    // Example: if (oldVer == 1 && newVer == 2) { ... migration code }
    debugPrint('⚡ Placeholder: Handled incremental migration step.');
  }

  /// Utility method for complete cold reset debugging (use with caution)
  static Future<void> resetEverythingDangerous() async {
    debugPrint('💣 DESTRUCTIVE ACTION TRIGGERED: NUKING LOCAL STORAGE');
    await Hive.deleteFromDisk();
    await init();
  }
}
