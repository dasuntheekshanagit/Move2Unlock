import 'package:flutter/material.dart';
import '../services/permission_service.dart';
import 'dashboard_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  final PermissionService _permissionService = PermissionService();
  bool _activityPermission = false;
  bool _usageStatsPermission = false;
  bool _overlayPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Mock checks for initial state or re-checks
    bool usage = await _permissionService.checkUsageStatsPermission();
    // Note: Activity recognition permission status isn't easily "checked" without requesting on some platforms, 
    // but we can track state. For now, assume false until pressed.
    
    setState(() {
      _usageStatsPermission = usage;
    });
  }

  Future<void> _requestActivity() async {
    bool granted = await _permissionService.requestActivityRecognitionPermission();
    setState(() {
      _activityPermission = granted;
    });
  }

  Future<void> _requestUsage() async {
    await _permissionService.requestUsageStatsPermission();
    // Wait a bit for user to return
    await Future.delayed(const Duration(seconds: 1)); 
    bool granted = await _permissionService.checkUsageStatsPermission();
    setState(() {
      _usageStatsPermission = granted;
    });
  }
  
  Future<void> _requestOverlay() async {
      bool granted = await _permissionService.requestOverlayPermission();
      setState(() {
          _overlayPermission = granted;
      });
  }

  void _continue() {
    if (_activityPermission && _usageStatsPermission && _overlayPermission) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please grant all permissions to continue.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Permissions Required')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'To lock apps and track steps, we need a few permissions.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            _buildPermissionTile(
              'Activity Recognition',
              'To count your steps.',
              _activityPermission,
              _requestActivity,
            ),
            _buildPermissionTile(
              'Usage Access',
              'To detect when you open locked apps.',
              _usageStatsPermission,
              _requestUsage,
            ),
            _buildPermissionTile(
              'Display Over Apps',
              'To show the lock screen over other apps.',
              _overlayPermission,
              _requestOverlay,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _continue,
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionTile(
      String title, String subtitle, bool isGranted, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: isGranted
          ? const Icon(Icons.check_circle, color: Colors.green)
          : FilledButton.tonal(
              onPressed: onTap,
              child: const Text('Grant'),
            ),
    );
  }
}
