import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen>
    with WidgetsBindingObserver {
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
    bool usage = await PermissionService.checkUsageStatsPermission();
    bool activity = await PermissionService
        .checkActivityRecognitionPermission();
    bool overlay = await PermissionService.checkOverlayPermission();

    if (mounted) {
      setState(() {
        _usageStatsPermission = usage;
        _activityPermission = activity;
        _overlayPermission = overlay;
      });
    }
  }

  Future<void> _requestActivity() async {
    bool granted = await PermissionService
        .requestActivityRecognitionPermission();
    setState(() {
      _activityPermission = granted;
    });
  }

  Future<void> _requestUsage() async {
    await PermissionService.requestUsageStatsPermission();
  }

  Future<void> _requestOverlay() async {
    bool granted = await PermissionService.requestOverlayPermission();
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Setup Permissions',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'To help you stay focused and track your progress, Move2Unlock needs access to a few things.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                height: 1.5,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: [
                  _buildPermissionTile(
                    context,
                    1,
                    'Activity Recognition',
                    'Required to count your steps accurately.',
                    Icons.directions_walk_rounded,
                    _activityPermission,
                    _requestActivity,
                    isLast: false,
                  ),
                  _buildPermissionTile(
                    context,
                    2,
                    'Usage Access',
                    'Required to detect when you open locked apps.',
                    Icons.data_usage_rounded,
                    _usageStatsPermission,
                    _requestUsage,
                    isLast: false,
                  ),
                  _buildPermissionTile(
                    context,
                    3,
                    'Display Over Apps',
                    'Required to show the lock screen overlay.',
                    Icons.layers_rounded,
                    _overlayPermission,
                    _requestOverlay,
                    isLast: true,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _continue,
                child: const Text('Continue to Dashboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionTile(
    BuildContext context,
    int step,
    String title,
    String subtitle,
    IconData icon,
    bool isGranted,
    VoidCallback onTap, {
    required bool isLast,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isGranted ? AppTheme.secondaryColor : AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isGranted
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : Text(
                          '$step',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: theme.dividerColor,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: InkWell(
                onTap: isGranted ? null : onTap,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isDark ? [] : [
                      BoxShadow(
                        color: const Color(0x0A000000),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (isGranted)
                        Text(
                          'Granted',
                          style: GoogleFonts.inter(
                            color: AppTheme.secondaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                          ),
                        )
                      else
                        FilledButton.tonal(
                          onPressed: onTap,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Grant'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
