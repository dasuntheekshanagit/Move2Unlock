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
  Map<String, int> _appStepRequirements = {}; // packageName -> required steps
  bool _isUnlocked = false;

  // Callback to show lock screen
  Function(String)? onAppLocked;

  Future<void> init() async {
    await _loadLockedApps();
    await _loadAppStepRequirements();
    startMonitoring();
  }

  Future<void> _loadLockedApps() async {
    final prefs = await SharedPreferences.getInstance();
    _lockedPackages = prefs.getStringList('locked_apps') ?? [];
  }

  Future<void> _loadAppStepRequirements() async {
    final prefs = await SharedPreferences.getInstance();
    _appStepRequirements = {};
    for (String packageName in _lockedPackages) {
      final stepCount = prefs.getInt('app_steps_$packageName') ?? 50;
      _appStepRequirements[packageName] = stepCount;
    }
  }

  // Getter for locked packages
  List<String> get lockedPackages => _lockedPackages;

  // Get step requirement for an app
  int getStepRequirement(String packageName) {
    return _appStepRequirements[packageName] ?? 50;
  }

  // Set step requirement for an app
  Future<void> setStepRequirement(String packageName, int steps) async {
    _appStepRequirements[packageName] = steps;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('app_steps_$packageName', steps);
  }

  // Check if app can be unlocked (has required steps been met)
  bool canUnlockApp(String packageName, int currentSteps) {
    final required = getStepRequirement(packageName);
    return currentSteps >= required;
  }

  Future<void> setLockedApps(List<String> packages) async {
    _lockedPackages = packages;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('locked_apps', packages);

    // Initialize step requirements for new apps
    for (String packageName in packages) {
      if (!_appStepRequirements.containsKey(packageName)) {
        _appStepRequirements[packageName] = 50; // Default 50 steps
        await prefs.setInt('app_steps_$packageName', 50);
      }
    }

    // Remove step requirements for unlocked apps
    for (String packageName in _appStepRequirements.keys.toList()) {
      if (!packages.contains(packageName)) {
        _appStepRequirements.remove(packageName);
        await prefs.remove('app_steps_$packageName');
      }
    }
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
          List<UsageInfo> usageStats = await UsageStats.queryUsageStats(
            startDate,
            endDate,
          );

          // Sort by last time used
          usageStats.sort(
            (a, b) => int.parse(
              b.lastTimeUsed!,
            ).compareTo(int.parse(a.lastTimeUsed!)),
          );

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
