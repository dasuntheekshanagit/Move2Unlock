import 'package:permission_handler/permission_handler.dart';
import 'package:usage_stats/usage_stats.dart';
import 'dart:io';

class PermissionService {
  static Future<bool> requestAllPermissions() async {
    if (!Platform.isAndroid) return true;

    // Request standard permissions
    final permissions = [
      Permission.activityRecognition,
      Permission.systemAlertWindow,
      Permission.notification,
    ];

    final statuses = await permissions.request();

    // Check usage stats permission separately as it's a special permission
    bool usageStats = await checkUsageStatsPermission();
    if (!usageStats) {
      // We can't request it directly via permission_handler, usually need to open settings
      // But for this method, we just return false if not granted, so the UI can prompt user
    }

    // Check if all critical permissions are granted
    bool allGranted = statuses.values.every(
      (status) => status.isGranted,
    ) && usageStats;

    return allGranted;
  }

  static Future<bool> requestActivityRecognitionPermission() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.activityRecognition.request();
    return status.isGranted;
  }

  static Future<bool> requestNotificationPermission() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<bool> requestOverlayPermission() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.systemAlertWindow.request();
    return status.isGranted;
  }

  static Future<bool> checkActivityRecognitionPermission() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.activityRecognition.status;
    return status.isGranted;
  }

  static Future<bool> checkNotificationStatus() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  static Future<bool> checkOverlayPermission() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.systemAlertWindow.status;
    return status.isGranted;
  }

  static Future<bool> checkUsageStatsPermission() async {
    if (!Platform.isAndroid) return true;
    return await UsageStats.checkUsagePermission() ?? false;
  }

  static Future<void> requestUsageStatsPermission() async {
    if (!Platform.isAndroid) return;
    await UsageStats.grantUsagePermission();
  }

  static Future<void> openSettings() async {
    openAppSettings();
  }
}
