import 'package:flutter/material.dart';
import '../../app_lock/screens/apps_screen.dart';
import '../../stats/screens/stats_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../../core/services/step_service.dart';
import '../../app_lock/services/app_lock_service.dart';
import 'home_content.dart';

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

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    await _stepService.init();
    await _appLockService.init();

    _stepService.stepStream.listen((steps) {
      if (mounted) {
        setState(() {
          _steps = steps;
        });
      }
    });

    // Initial load
    setState(() {
      _steps = _stepService.getCurrentSteps();
    });
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

    return Scaffold(
      body: Column(
        children: [
          // Fixed Header with SafeArea
          SafeArea(
            bottom: false,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.08),
                    theme.colorScheme.secondary.withOpacity(0.03),
                  ],
                ),
              ),
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock_clock_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Move2Unlock',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'profile') {
                        _navigateToProfile();
                      } else if (value == 'settings') {
                        _navigateToSettings();
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'profile',
                            child: ListTile(
                              leading: Icon(Icons.person_outline, size: 20),
                              title: Text(
                                'Profile',
                                style: TextStyle(fontSize: 14),
                              ),
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'settings',
                            child: ListTile(
                              leading: Icon(Icons.settings_outlined, size: 20),
                              title: Text(
                                'Settings',
                                style: TextStyle(fontSize: 14),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        indicatorColor: theme.colorScheme.primary.withOpacity(0.15),
        height: 65,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, size: 24),
            selectedIcon: Icon(Icons.home_rounded, size: 24),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.apps_outlined, size: 24),
            selectedIcon: Icon(Icons.apps_rounded, size: 24),
            label: 'Apps',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_rounded, size: 24),
            selectedIcon: Icon(Icons.bar_chart_rounded, size: 24),
            label: 'Stats',
          ),
        ],
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
