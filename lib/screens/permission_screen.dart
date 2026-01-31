import 'package:flutter/material.dart';
import '../services/permission_service.dart';
import 'dashboard_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> with WidgetsBindingObserver {
  final PermissionService _permissionService = PermissionService();
  bool _activityPermission = false;
  bool _usageStatsPermission = false;
  bool _overlayPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    bool usage = await _permissionService.checkUsageStatsPermission();
    bool activity = await _permissionService.checkActivityRecognitionPermission();
    bool overlay = await _permissionService.checkOverlayPermission();
    
    if (mounted) {
      setState(() {
        _usageStatsPermission = usage;
        _activityPermission = activity;
        _overlayPermission = overlay;
      });
    }
  }

  Future<void> _requestActivity() async {
    bool granted = await _permissionService.requestActivityRecognitionPermission();
    setState(() {
      _activityPermission = granted;
    });
  }

  Future<void> _requestUsage() async {
    await _permissionService.requestUsageStatsPermission();
    // Wait for user to return
  }
  
  Future<void> _requestOverlay() async {
      bool granted = await _permissionService.requestOverlayPermission();
      setState(() {
          _overlayPermission = granted;
      });
  }

  void _continue() {
    if (_usageStatsPermission && _activityPermission && _overlayPermission) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      // Try to check again in case state is stale
      _checkPermissions().then((_) {
          if (_usageStatsPermission && _activityPermission && _overlayPermission) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const DashboardScreen()),
              );
          } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Please grant all permissions to continue.'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
          }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shield_outlined,
                  size: 28,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Setup Permissions',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onBackground,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'To help you stay focused and track your progress, Motivation Lock needs access to a few things.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  height: 1.5,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              
              // Permission Tiles
              Expanded(
                child: ListView(
                  children: [
                    _buildPermissionTile(
                      context,
                      'Activity Recognition',
                      'Required to count your steps accurately.',
                      Icons.directions_walk_rounded,
                      _activityPermission,
                      _requestActivity,
                    ),
                    const SizedBox(height: 12),
                    _buildPermissionTile(
                      context,
                      'Usage Access',
                      'Required to detect when you open locked apps.',
                      Icons.data_usage_rounded,
                      _usageStatsPermission,
                      _requestUsage,
                    ),
                    const SizedBox(height: 12),
                    _buildPermissionTile(
                      context,
                      'Display Over Apps',
                      'Required to show the lock screen overlay.',
                      Icons.layers_rounded,
                      _overlayPermission,
                      _requestOverlay,
                    ),
                  ],
                ),
              ),
              
              // Bottom Action
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _continue,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Continue to Dashboard',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionTile(
      BuildContext context,
      String title, 
      String subtitle, 
      IconData icon,
      bool isGranted, 
      VoidCallback onTap) {
    final theme = Theme.of(context);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isGranted 
            ? theme.colorScheme.primary.withOpacity(0.05) 
            : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGranted 
              ? theme.colorScheme.primary.withOpacity(0.5) 
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isGranted ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isGranted 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isGranted ? Icons.check_rounded : icon, 
                    color: isGranted 
                        ? Colors.white 
                        : theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title, 
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isGranted ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          height: 1.3,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isGranted)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
