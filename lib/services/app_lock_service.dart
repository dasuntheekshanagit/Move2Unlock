import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';

class AppLockService {
  Timer? _monitorTimer;
  List<String> _lockedPackages = [];
  bool _isUnlocked = false;
  
  // Callback to show lock screen
  Function(String)? onAppLocked;

  Future<void> init() async {
    await _loadLockedApps();
    startMonitoring();
  }

  Future<void> _loadLockedApps() async {
    final prefs = await SharedPreferences.getInstance();
    _lockedPackages = prefs.getStringList('locked_apps') ?? [];
  }
  
  // Getter for locked packages
  List<String> get lockedPackages => _lockedPackages;

  Future<void> setLockedApps(List<String> packages) async {
    _lockedPackages = packages;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('locked_apps', packages);
  }
  
  Future<List<AppInfo>> getInstalledApps() async {
      return await InstalledApps.getInstalledApps(true, true);
  }

  void startMonitoring() {
    if (Platform.isAndroid) {
      _monitorTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (_isUnlocked) return;

        try {
          DateTime endDate = DateTime.now();
          DateTime startDate = endDate.subtract(const Duration(seconds: 2));
          List<UsageInfo> usageStats = await UsageStats.queryUsageStats(startDate, endDate);
          
          // Sort by last time used
          usageStats.sort((a, b) => int.parse(b.lastTimeUsed!).compareTo(int.parse(a.lastTimeUsed!)));

          if (usageStats.isNotEmpty) {
            String currentPackage = usageStats.first.packageName!;
            
            if (_lockedPackages.contains(currentPackage)) {
              // App is locked!
              print("Locked app detected: $currentPackage");
              
              if (onAppLocked != null) {
                  onAppLocked!(currentPackage);
              }
            }
          }
        } catch (e) {
          print("Error monitoring apps: $e");
        }
      });
    }
  }

  void stopMonitoring() {
    _monitorTimer?.cancel();
  }
  
  void unlockApps() {
      _isUnlocked = true;
  }
  
  void lockApps() {
      _isUnlocked = false;
  }
}
