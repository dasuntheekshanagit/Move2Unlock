import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

@pragma('vm:entry-point')
class AppLockService {
  static const String _notificationChannelId = 'move2unlock_service_channel';
  static const int _notificationId = 888;

  List<String> _lockedPackages = [];
  Map<String, int> _appStepRequirements = {};
  
  // Callback to show lock screen (only works when app is in foreground/overlay)
  Function(String)? onAppLocked;

  Future<void> init() async {
    await _loadLockedApps();
    await _loadAppStepRequirements();
    await _initializeBackgroundService();
  }

  Future<void> _loadLockedApps() async {
    final prefs = await SharedPreferences.getInstance();
    _lockedPackages = prefs.getStringList('locked_apps') ?? [];
  }

  Future<void> _loadAppStepRequirements() async {
    final prefs = await SharedPreferences.getInstance();
    _appStepRequirements = {};
    if (_lockedPackages.isNotEmpty) {
      for (String packageName in _lockedPackages) {
        final stepCount = prefs.getInt('app_steps_$packageName') ?? 50;
        _appStepRequirements[packageName] = stepCount;
      }
    }
  }

  Future<void> _initializeBackgroundService() async {
    final service = FlutterBackgroundService();
    
    // Create the notification channel explicitly before configuring the service
    // This helps avoid "Bad notification for startForeground" errors
    if (Platform.isAndroid) {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        _notificationChannelId,
        'App Lock Service',
        description: 'Monitors app usage and steps',
        importance: Importance.low, 
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        
        // Use the channel we just created
        notificationChannelId: _notificationChannelId,
        initialNotificationTitle: 'Move2Unlock Active',
        initialNotificationContent: 'Monitoring app usage...',
        foregroundServiceNotificationId: _notificationId,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
      ),
    );
    
    await service.startService();
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();
    
    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    // Start the monitoring loop
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        await _checkAppUsage(service);
      } catch (e) {
        print('Error in background service: $e');
      }
    });
  }

  static Future<void> _checkAppUsage(ServiceInstance service) async {
    if (!Platform.isAndroid) return;

    final prefs = await SharedPreferences.getInstance();
    final lockedApps = prefs.getStringList('locked_apps') ?? [];
    
    if (lockedApps.isEmpty) return;

    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(const Duration(seconds: 2));
    
    List<UsageInfo> usageStats = await UsageStats.queryUsageStats(
      startDate,
      endDate,
    );

    usageStats.sort(
      (a, b) => int.parse(b.lastTimeUsed!).compareTo(int.parse(a.lastTimeUsed!)),
    );

    if (usageStats.isNotEmpty) {
      String currentPackage = usageStats.first.packageName!;
      
      // Ignore our own app
      if (currentPackage == 'com.example.motivation_lock') return;

      if (lockedApps.contains(currentPackage)) {
        service.invoke('onAppLocked', {'package': currentPackage});
      }
    }
  }

  // Listen for messages from background service
  void startListeningToService() {
    FlutterBackgroundService().on('onAppLocked').listen((event) {
      if (event != null && event['package'] != null) {
        final packageName = event['package'] as String;
        if (onAppLocked != null) {
          onAppLocked!(packageName);
        }
      }
    });
  }
  
  List<String> get lockedPackages => _lockedPackages;

  int getStepRequirement(String packageName) {
    return _appStepRequirements[packageName] ?? 50;
  }

  Future<void> setStepRequirement(String packageName, int steps) async {
    _appStepRequirements[packageName] = steps;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('app_steps_$packageName', steps);
  }

  bool canUnlockApp(String packageName, int currentSteps) {
    final required = getStepRequirement(packageName);
    return currentSteps >= required;
  }

  Future<void> setLockedApps(List<String> packages) async {
    _lockedPackages = packages;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('locked_apps', packages);

    for (String packageName in packages) {
      if (!_appStepRequirements.containsKey(packageName)) {
        _appStepRequirements[packageName] = 50;
        await prefs.setInt('app_steps_$packageName', 50);
      }
    }
  }

  Future<List<AppInfo>> getInstalledApps() async {
    return await InstalledApps.getInstalledApps(true, true);
  }
}
