import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import '../utils/app_logger.dart';

enum AppPermissionType { notifications, activity, unknown }

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Provides the correct cross-platform permission constant for activity tracking.
  Permission get activityPermission {
    return Platform.isIOS ? Permission.sensors : Permission.activityRecognition;
  }

  Future<PermissionStatus> getStatus(Permission permission) async {
    try {
      return await permission.status;
    } catch (e, s) {
      AppLogger.error('Error fetching permission status for $permission', e, s);
      return PermissionStatus.denied;
    }
  }

  Future<PermissionStatus> request(Permission permission) async {
    try {
      final status = await permission.status;

      if (status.isPermanentlyDenied) {
        // Must trigger direct OS system open
        return status;
      }

      return await permission.request();
    } catch (e, s) {
      AppLogger.error('Error requesting permission $permission', e, s);
      return PermissionStatus.denied;
    }
  }

  Future<bool> openSettings() async {
    try {
      return await openAppSettings();
    } catch (e, s) {
      AppLogger.error('Error opening app settings', e, s);
      return false;
    }
  }
}
