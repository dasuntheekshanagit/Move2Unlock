import 'package:flutter/material.dart';
import 'permission_screen.dart';
import 'dashboard_screen.dart';
import '../services/permission_service.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  Future<void> _close(BuildContext context) async {
    final permissionService = PermissionService();
    
    // Check if all permissions are granted
    bool usage = await permissionService.checkUsageStatsPermission();
    bool activity = await permissionService.checkActivityRecognitionPermission();
    bool overlay = await permissionService.checkOverlayPermission();
    
    if (context.mounted) {
      if (usage && activity && overlay) {
        // All granted, go to dashboard
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const DashboardScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else {
        // Not granted, go to permission screen
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const PermissionScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Stack(
        children: [
          // Background Image or Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.05),
                  theme.colorScheme.background,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _close(context),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.cardTheme.color,
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.diamond_outlined,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Unlock Premium',
                    style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: theme.colorScheme.onBackground,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Supercharge your productivity with unlimited access.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 18,
                        ),
                  ),
                  const SizedBox(height: 48),
                  _buildFeatureRow(context, 'Unlimited App Locks', Icons.lock_open_rounded),
                  _buildFeatureRow(context, 'Custom Step Goals', Icons.directions_walk_rounded),
                  _buildFeatureRow(context, 'Advanced Analytics', Icons.bar_chart_rounded),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => _close(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Start 7-Day Free Trial',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Then \$4.99/month. Cancel anytime.',
                    style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, String text, IconData icon) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 22,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
