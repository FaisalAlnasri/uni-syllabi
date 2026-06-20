import 'package:permission_handler/permission_handler.dart';

import '../logging/app_logger.dart';

/// Thin wrapper around the OS notification permission. Kept deliberately small
/// so the scheduling library (e.g. flutter_local_notifications) can be added
/// later without touching call sites like onboarding.
abstract interface class NotificationService {
  /// Whether the user has already granted notification permission.
  Future<bool> isGranted();

  /// Triggers the OS permission prompt. Returns `true` if granted.
  Future<bool> requestPermission();
}

class PermissionHandlerNotificationService implements NotificationService {
  @override
  Future<bool> isGranted() async {
    try {
      return Permission.notification.status.then((s) => s.isGranted);
    } catch (e, st) {
      AppLogger.warning('[Notifications] status check failed', e, st);
      return false;
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (e, st) {
      AppLogger.warning('[Notifications] permission request failed', e, st);
      return false;
    }
  }
}
