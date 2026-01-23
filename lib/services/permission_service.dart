import 'package:permission_handler/permission_handler.dart';
import 'package:usage_stats/usage_stats.dart';
import 'dart:io';

class PermissionService {
  Future<bool> requestActivityRecognitionPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.activityRecognition.request();
      return status.isGranted;
    }
    // iOS handles this differently, usually via Info.plist and automatic prompts on first use of Pedometer
    return true; 
  }

  Future<bool> checkUsageStatsPermission() async {
    if (Platform.isAndroid) {
      return (await UsageStats.checkUsagePermission()) ?? false;
    }
    return true; // Not applicable/available in the same way on iOS for general app locking
  }

  Future<void> requestUsageStatsPermission() async {
    if (Platform.isAndroid) {
      await UsageStats.grantUsagePermission();
    }
  }

  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }
  
  Future<bool> requestOverlayPermission() async {
      if (Platform.isAndroid) {
          final status = await Permission.systemAlertWindow.request();
          return status.isGranted;
      }
      return true;
  }
}
