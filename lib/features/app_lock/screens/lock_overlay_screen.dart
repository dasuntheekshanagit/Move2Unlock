import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import '../../../core/theme/app_theme.dart';

class LockOverlayScreen extends StatefulWidget {
  final String packageName;
  final int currentSteps;
  final int requiredSteps;

  const LockOverlayScreen({
    super.key,
    required this.packageName,
    required this.currentSteps,
    required this.requiredSteps,
  });

  @override
  State<LockOverlayScreen> createState() => _LockOverlayScreenState();
}

class _LockOverlayScreenState extends State<LockOverlayScreen> {
  AppInfo? _appInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    // Fixed: Added null as the second argument for platformType
    final app = await InstalledApps.getAppInfo(widget.packageName, null);
    if (mounted) {
      setState(() {
        _appInfo = app;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final stepsRemaining = (widget.requiredSteps - widget.currentSteps).clamp(0, widget.requiredSteps);
    final canUnlock = widget.currentSteps >= widget.requiredSteps;

    return PopScope(
      canPop: false, // Prevent back button
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // App Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _appInfo?.icon != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.memory(_appInfo!.icon!),
                            )
                          : const Icon(Icons.android, size: 48),
                ),
                const SizedBox(height: 24),
                Text(
                  _appInfo?.name ?? 'App Locked',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Walk to unlock',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 48),
                
                // Simple Step Counter Display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: canUnlock ? AppTheme.secondaryColor : theme.dividerColor,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        canUnlock ? 'GOAL MET!' : '$stepsRemaining',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: canUnlock ? AppTheme.secondaryColor : theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        canUnlock ? 'You can now open the app' : 'steps remaining',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                if (canUnlock)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Open App',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        // Go back to dashboard/home
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: theme.dividerColor),
                      ),
                      child: Text(
                        'I\'ll walk more',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: theme.colorScheme.onBackground,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
