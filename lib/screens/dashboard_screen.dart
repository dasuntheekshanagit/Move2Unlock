import 'package:flutter/material.dart';
import 'apps_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import '../services/step_service.dart';
import '../services/app_lock_service.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(theme),
          const AppsScreen(),
          const StatsScreen(),
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

  Widget _buildHomeTab(ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onBackground,
            fontSize: 22,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          _buildPopupMenu(context),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreetingCard(theme),
                  const SizedBox(height: 20),
                  _buildStepsCard(theme),
                  const SizedBox(height: 20),
                  _buildSmallStatGraph(theme),
                  const SizedBox(height: 20),
                  _buildMotivationCard(theme),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: Theme.of(context).colorScheme.onBackground),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'profile') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        } else if (value == 'settings') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'profile',
          child: ListTile(
            leading: Icon(Icons.person_outline, size: 20),
            title: Text('Profile', style: TextStyle(fontSize: 14)),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        const PopupMenuItem<String>(
          value: 'settings',
          child: ListTile(
            leading: Icon(Icons.settings_outlined, size: 20),
            title: Text('Settings', style: TextStyle(fontSize: 14)),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        const PopupMenuItem<String>(
          value: 'help',
          child: ListTile(
            leading: Icon(Icons.help_outline, size: 20),
            title: Text('Help & Support', style: TextStyle(fontSize: 14)),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildGreetingCard(ThemeData theme) {
    // Mock date
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final dateStr = '${days[now.weekday % 7].toUpperCase()}, ${months[now.month - 1].toUpperCase()} ${now.day}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wb_sunny_outlined, size: 14, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Good Morning,',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w400,
              fontFamily: 'Serif',
              color: theme.colorScheme.onSurface,
              fontSize: 22,
            ),
          ),
          Text(
            'Dasun.',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              fontFamily: 'Serif',
              color: theme.colorScheme.primary,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsCard(ThemeData theme) {
    const int stepGoal = 5000;
    double progress = _steps / stepGoal;
    if (progress > 1.0) progress = 1.0;

    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            top: -16,
            child: Icon(
              Icons.directions_walk,
              size: 120,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.bolt_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Daily Goal',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.more_horiz, color: Colors.white.withOpacity(0.7), size: 20),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$_steps',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6, left: 6),
                    child: Text(
                      '/ 5000',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.black.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                      minHeight: 5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${(progress * 100).toInt()}% completed',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatGraph(ThemeData theme) {
    final data = [0.3, 0.5, 0.4, 0.7, 0.6, 0.8, 0.5];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Activity Trend',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              Text(
                'Last 7 Days',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: data.map((value) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 10,
                      height: 80 * value,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFE4E6)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'SPARK A THOUGHT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '"The only way to do great work is to love what you do."',
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              fontFamily: 'Serif',
              height: 1.4,
              color: Color(0xFF2D2D2D),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
