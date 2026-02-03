import 'package:flutter/material.dart';
import '../services/permission_service.dart';
import 'dashboard_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen>
    with WidgetsBindingObserver {
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
    bool activity = await _permissionService
        .checkActivityRecognitionPermission();
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
    bool granted = await _permissionService
        .requestActivityRecognitionPermission();
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
        if (_usageStatsPermission &&
            _activityPermission &&
            _overlayPermission) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please grant all permissions to continue.'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
    const permissionColor = Color(0xFF6366F1); // Indigo color

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [permissionColor, Color(0xFF4F46E5)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 40,
                      right: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      left: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              title: Text(
                'Setup Permissions',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              centerTitle: false,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
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
                  _buildPermissionTile(
                    context,
                    'Activity Recognition',
                    'Required to count your steps accurately.',
                    Icons.directions_walk_rounded,
                    _activityPermission,
                    _requestActivity,
                    const Color(0xFF06B6D4),
                  ),
                  const SizedBox(height: 12),
                  _buildPermissionTile(
                    context,
                    'Usage Access',
                    'Required to detect when you open locked apps.',
                    Icons.data_usage_rounded,
                    _usageStatsPermission,
                    _requestUsage,
                    const Color(0xFFF59E0B),
                  ),
                  const SizedBox(height: 12),
                  _buildPermissionTile(
                    context,
                    'Display Over Apps',
                    'Required to show the lock screen overlay.',
                    Icons.layers_rounded,
                    _overlayPermission,
                    _requestOverlay,
                    const Color(0xFF10B981),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _continue,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shadowColor: permissionColor.withOpacity(0.4),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Continue to Dashboard',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool isGranted,
    VoidCallback onTap,
    Color color,
  ) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: isGranted
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.12), color.withOpacity(0.03)],
              )
            : null,
        color: isGranted ? null : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGranted ? color.withOpacity(0.3) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isGranted
                ? color.withOpacity(0.1)
                : Colors.black.withOpacity(0.02),
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
                    gradient: isGranted
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [color, color.withOpacity(0.8)],
                          )
                        : null,
                    color: isGranted ? null : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isGranted
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    isGranted ? Icons.check_rounded : icon,
                    color: isGranted ? Colors.white : color,
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
                          color: isGranted
                              ? color
                              : theme.colorScheme.onSurface,
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
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
