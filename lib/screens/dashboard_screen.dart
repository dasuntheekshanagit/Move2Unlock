import 'package:flutter/material.dart';
import 'app_selection_screen.dart';
import 'limit_settings_screen.dart';
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
  int _lockedAppsCount = 0;
  
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
        _lockedAppsCount = _appLockService.lockedPackages.length;
    });
  }
  
  // Refresh locked apps count when returning from selection screen
  void _refreshData() {
      setState(() {
          _lockedAppsCount = _appLockService.lockedPackages.length;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
              title: Text(
                'Dashboard',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {},
              ),
              const SizedBox(width: 16),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(context),
                  const SizedBox(height: 32),
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          context,
                          'Select Apps',
                          Icons.apps_rounded,
                          Theme.of(context).colorScheme.secondary,
                          () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AppSelectionScreen()),
                            );
                            _refreshData();
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionCard(
                          context,
                          'Set Limits',
                          Icons.timer_rounded,
                          Theme.of(context).colorScheme.tertiary,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LimitSettingsScreen()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Today\'s Progress',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildProgressCard(context),
                  const SizedBox(height: 80), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    // Mock goal for now, should come from settings
    const int stepGoal = 5000;
    int remaining = stepGoal - _steps;
    if (remaining < 0) remaining = 0;
    double progress = _steps / stepGoal;
    if (progress > 1.0) progress = 1.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Steps Remaining',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$remaining',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_walk_rounded,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: Colors.white.withOpacity(0.8),
              ),
              const SizedBox(width: 8),
              Text(
                'Walk to unlock your apps',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          _buildStatRow(context, 'Apps Locked', '$_lockedAppsCount', Icons.lock_outline_rounded),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Theme.of(context).dividerColor.withOpacity(0.5)),
          ),
          _buildStatRow(context, 'Time Saved', '45 min', Icons.hourglass_empty_rounded),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Theme.of(context).dividerColor.withOpacity(0.5)),
          ),
          _buildStatRow(context, 'Steps Taken', '$_steps', Icons.show_chart_rounded),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
