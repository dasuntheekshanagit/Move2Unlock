import 'package:permission_handler/permission_handler.dart';
import 'package:usage_stats/usage_stats.dart';
import 'dart:io';

class PermissionService {
  Future<bool> requestActivityRecognitionPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.activityRecognition.request();
      return status.isGranted;
    }
    return true; 
  }

  Future<bool> checkActivityRecognitionPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.activityRecognition.status;
      return status.isGranted;
    }
    return true;
  }

  Future<bool> checkUsageStatsPermission() async {
    if (Platform.isAndroid) {
      return (await UsageStats.checkUsagePermission()) ?? false;
    }
    return true; 
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

  Future<bool> checkOverlayPermission() async {
      if (Platform.isAndroid) {
          final status = await Permission.systemAlertWindow.status;
          return status.isGranted;
      }
      return true;
  }
}
