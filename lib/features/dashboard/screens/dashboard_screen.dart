import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_lock/screens/apps_screen.dart';
import '../../stats/screens/stats_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../../core/services/step_service.dart';
import '../../app_lock/services/app_lock_service.dart';
import '../../../core/theme/app_theme.dart';
import 'home_content.dart';
import '../../onboarding/screens/permission_screen.dart';
import '../../../core/services/permission_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final StepService _stepService = StepService();
  final AppLockService _appLockService = AppLockService();

  int _steps = 0;
  int _selectedIndex = 0;
  bool _isError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndInit();
  }

  Future<void> _checkPermissionsAndInit() async {
    try {
      bool allGranted = await PermissionService.requestAllPermissions();
      if (!allGranted) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const PermissionScreen()),
          );
        }
        return;
      }
      await _initServices();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isError = true;
          _errorMessage = 'Failed to initialize services: $e';
        });
      }
    }
  }

  Future<void> _initServices() async {
    try {
      await _stepService.init();
      await _appLockService.init();

      _stepService.stepStream.listen((steps) {
        if (mounted) {
          setState(() {
            _steps = steps;
          });
        }
      }, onError: (error) {
        print('Step stream error: $error');
        // Optionally handle stream errors without crashing the UI
      });

      // Initial load
      setState(() {
        _steps = _stepService.getCurrentSteps();
      });
    } catch (e) {
      print('Error initializing services: $e');
      if (mounted) {
        setState(() {
          _isError = true;
          _errorMessage = 'Error initializing services. Please check if your device supports step counting.';
        });
      }
    }
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isError) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _isError = false;
                      _errorMessage = '';
                    });
                    _checkPermissionsAndInit();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // Fixed Header with SafeArea
          SafeArea(
            bottom: false,
            child: Container(
              color: theme.scaffoldBackgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Hero(
                        tag: 'app_logo',
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppTheme.primaryColor, AppTheme.primaryVariant],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.lock_clock_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Move2Unlock',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: theme.colorScheme.onBackground,
                        ),
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: theme.colorScheme.onBackground,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                    elevation: 4,
                    onSelected: (value) {
                      if (value == 'profile') {
                        _navigateToProfile();
                      } else if (value == 'settings') {
                        _navigateToSettings();
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'profile',
                            child: ListTile(
                              leading: const Icon(Icons.person_outline, size: 20),
                              title: Text(
                                'Profile',
                                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'settings',
                            child: ListTile(
                              leading: const Icon(Icons.settings_outlined, size: 20),
                              title: Text(
                                'Settings',
                                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ),
                        ],
                  ),
                ],
              ),
            ),
          ),
          // Content Area - Switches based on selected tab
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                HomeContent(steps: _steps, onStatsTap: () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                }),
                const AppsContent(),
                const StatsContent(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.dividerColor,
              width: 0.5,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.apps_outlined),
              selectedIcon: Icon(Icons.apps_rounded),
              label: 'Apps',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_rounded),
              selectedIcon: Icon(Icons.bar_chart_rounded),
              label: 'Stats',
            ),
          ],
        ),
      ),
    );
  }
}

// Apps Tab Content - Simple wrapper
class AppsContent extends StatelessWidget {
  const AppsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppsScreen();
  }
}

// Stats Tab Content - Simple wrapper
class StatsContent extends StatelessWidget {
  const StatsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const StatsScreen();
  }
}
