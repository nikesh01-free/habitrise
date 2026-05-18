import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/permission_service.dart';

class AppPermissionsState {
  final PermissionStatus notifications;
  final PermissionStatus activity;

  const AppPermissionsState({
    this.notifications = PermissionStatus.denied,
    this.activity = PermissionStatus.denied,
  });

  AppPermissionsState copyWith({
    PermissionStatus? notifications,
    PermissionStatus? activity,
  }) {
    return AppPermissionsState(
      notifications: notifications ?? this.notifications,
      activity: activity ?? this.activity,
    );
  }

  bool get isReady => notifications.isGranted && activity.isGranted;
}

class PermissionsNotifier extends Notifier<AppPermissionsState> {
  final _service = PermissionService();

  @override
  AppPermissionsState build() {
    // Trigger async refresh immediately upon build attachment
    refresh();
    return const AppPermissionsState();
  }

  Future<void> refresh() async {
    final nStatus = await _service.getStatus(Permission.notification);
    final aStatus = await _service.getStatus(_service.activityPermission);

    state = state.copyWith(notifications: nStatus, activity: aStatus);
  }

  Future<PermissionStatus> requestPermission(Permission permission) async {
    final result = await _service.request(permission);
    await refresh();
    return result;
  }

  Future<void> requestAllRequired() async {
    // Sequentially trigger native prompt requests for base operation permissions
    await _service.request(_service.activityPermission);
    await _service.request(Permission.notification);
    await refresh();
  }

  Future<void> openSystemSettings() async {
    await _service.openSettings();
  }
}

final permissionsProvider =
    NotifierProvider<PermissionsNotifier, AppPermissionsState>(() {
      return PermissionsNotifier();
    });
