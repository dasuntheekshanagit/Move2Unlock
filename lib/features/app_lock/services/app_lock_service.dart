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
  static const MethodChannel _nativeChannel = MethodChannel('com.example.motivation_lock/native');

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
    Timer.periodic(const Duration(seconds: 1), (timer) async {
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
        // Notify UI
        service.invoke('onAppLocked', {'package': currentPackage});
        
        // Bring app to foreground using native channel
        // Note: This might fail on Android 10+ if not granted "Display over other apps"
        try {
          // We can't use MethodChannel directly in background isolate easily without setup
          // But since we are in a background service, we can try to launch intent
          // However, the best way is to let the UI handle it if it's alive, 
          // or use a full screen intent notification.
          
          // For this implementation, we rely on the service.invoke to wake up the UI
          // if the UI is listening. If the UI is killed, we need a way to restart it.
          // The FlutterBackgroundService keeps the isolate alive.
          
          // Let's try to launch the app via intent from Dart if possible, 
          // or rely on the fact that we are a foreground service.
          
          // Since we can't easily access context or native activity here, 
          // we will rely on the main isolate to react to 'onAppLocked'
          // BUT, if the main isolate is paused/killed, we need to restart it.
          
          // Actually, we can use the 'device_apps' or 'external_app_launcher' 
          // but we don't have them. 
          // Let's try to use the 'installed_apps' package to start our own app?
          // No, that might be circular.
          
          // The most reliable way on Android 10+ without being a launcher is 
          // showing a high priority notification with fullScreenIntent.
          // But we want to force it.
          
          // Let's try to use the native channel if we can get a handle to it, 
          // but MethodChannels are tied to the engine.
          
          // For now, we will assume the UI is listening.
        } catch (e) {
          print('Error bringing to front: $e');
        }
      }
    }
  }

  // Listen for messages from background service
  void startListeningToService() {
    FlutterBackgroundService().on('onAppLocked').listen((event) async {
      if (event != null && event['package'] != null) {
        final packageName = event['package'] as String;
        
        // Bring app to front natively
        try {
          await _nativeChannel.invokeMethod('showOverlay');
        } catch (e) {
          print('Failed to show overlay: $e');
        }

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
