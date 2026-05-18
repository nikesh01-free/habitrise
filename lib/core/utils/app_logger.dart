import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:habitrise/core/storage/local_box_names.dart';

class AppLogger {
  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('🛠️ DEBUG: $message');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      debugPrint('ℹ️ INFO: $message');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('⚠️ WARNING: $message');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('❌ ERROR: $message');
      if (error != null) {
        debugPrint('Details: $error');
      }
      if (stackTrace != null) {
        debugPrint(stackTrace.toString());
      }
    } else {
      _saveLogLocally(message, error, stackTrace);
    }
  }

  static Future<void> _saveLogLocally(String message, dynamic error, StackTrace? stackTrace) async {
    try {
      if (!Hive.isBoxOpen(LocalBoxNames.appLogs)) return;

      final box = Hive.box(LocalBoxNames.appLogs);
      final logEntry = {
        'timestamp': DateTime.now().toIso8601String(),
        'message': message,
        'error': error?.toString() ?? '',
        'stackTrace': stackTrace?.toString().substring(0, stackTrace.toString().length > 1000 ? 1000 : stackTrace.toString().length) ?? '',
      };

      await box.add(logEntry);

      if (box.length > 100) {
        final keysToRemove = box.keys.take(box.length - 100);
        await box.deleteAll(keysToRemove);
      }
    } catch (_) {
      // Safely ignore log persistence failure to prevent crash loops
    }
  }
}
