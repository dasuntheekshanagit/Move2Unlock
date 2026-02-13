import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_lock_service.dart';
import '../../../core/services/step_service.dart';
import '../../../core/theme/app_theme.dart';
import 'limit_settings_screen.dart';
import 'app_selection_screen.dart';

class AppsScreen extends StatefulWidget {
  const AppsScreen({super.key});

  @override
  State<AppsScreen> createState() => _AppsScreenState();
}

class _AppsScreenState extends State<AppsScreen> {
  final AppLockService _appLockService = AppLockService();
  final StepService _stepService = StepService();
  List<AppInfo> _lockedApps = [];
  bool _isLoading = true;
  int _currentSteps = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _appLockService.init();
    await _stepService.init();

    final lockedPackageNames = _appLockService.lockedPackages;

    if (lockedPackageNames.isEmpty) {
      if (mounted) {
        setState(() {
          _lockedApps = [];
          _isLoading = false;
        });
      }
      return;
    }

    final allApps = await InstalledApps.getInstalledApps(true, true);
    final locked = allApps
        .where((app) => lockedPackageNames.contains(app.packageName))
        .toList();

    locked.sort(
      (a, b) =>
          (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase()),
    );

    if (mounted) {
      setState(() {
        _lockedApps = locked;
        _isLoading = false;
      });
    }

    // Listen to step changes
    _stepService.stepStream.listen((steps) {
      if (mounted) {
        setState(() {
          _currentSteps = steps;
        });
      }
    });
  }

  void _refresh() {
    setState(() {
      _isLoading = true;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        _buildSectionTitle(theme, 'Global Settings'),
        const SizedBox(height: 12),
        _buildGlobalSettingsCard(theme),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(theme, 'Locked Apps'),
            TextButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppSelectionScreen(),
                  ),
                );
                _refresh();
              },
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: Text(
                'Manage',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_lockedApps.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.apps_outlined,
                  size: 48,
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                ),
                const SizedBox(height: 16),
                Text(
                  'No apps locked yet',
                  style: GoogleFonts.inter(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AppSelectionScreen(),
                      ),
                    );
                    _refresh();
                  },
                  child: const Text('Select Apps'),
                ),
              ],
            ),
          )
        else
          Column(
            children: List.generate(_lockedApps.length, (index) {
              final app = _lockedApps[index];
              return _buildAppItem(theme, app, index);
            }),
          ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface.withOpacity(0.5),
        fontSize: 11,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildGlobalSettingsCard(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LimitSettingsScreen()),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: const Color(0x0A000000),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.tune_rounded, color: AppTheme.primaryColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Global Limits',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Default rules for all apps',
                    style: GoogleFonts.inter(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 24,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppItem(ThemeData theme, AppInfo app, int index) {
    final isDark = theme.brightness == Brightness.dark;
    final stepRequirement = _appLockService.getStepRequirement(
      app.packageName ?? '',
    );
    final canUnlock = _appLockService.canUnlockApp(
      app.packageName ?? '',
      _currentSteps,
    );
    final stepsRemaining = (stepRequirement - _currentSteps).clamp(
      0,
      stepRequirement,
    );
    final progress = (_currentSteps / stepRequirement).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: const Color(0x0A000000),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            _showAppUnlockDialog(
              theme,
              app,
              canUnlock,
              stepsRemaining,
              stepRequirement,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: app.icon != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(app.icon!, width: 48, height: 48),
                        )
                      : const Icon(Icons.android, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.name ?? 'Unknown',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            canUnlock ? AppTheme.secondaryColor : AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (canUnlock)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: AppTheme.secondaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Ready to unlock',
                                style: GoogleFonts.inter(
                                  color: AppTheme.secondaryColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Text(
                          '$stepsRemaining steps to unlock',
                          style: GoogleFonts.inter(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: Icon(
                    Icons.settings_outlined,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                    size: 24,
                  ),
                  onPressed: () {
                    _showStepSettingsDialog(theme, app);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAppUnlockDialog(
    ThemeData theme,
    AppInfo app,
    bool canUnlock,
    int stepsRemaining,
    int stepRequirement,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: theme.cardTheme.color,
        title: Text(
          app.name ?? 'App',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    '$_currentSteps',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Steps Taken',
                    style: GoogleFonts.inter(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (_currentSteps / stepRequirement).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Required: $stepRequirement',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      if (!canUnlock)
                        Text(
                          'Need: $stepsRemaining',
                          style: GoogleFonts.inter(
                            color: AppTheme.errorColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        )
                      else
                        Text(
                          'Complete!',
                          style: GoogleFonts.inter(
                            color: AppTheme.secondaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (canUnlock)
              Text(
                'You can now unlock this app!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              Text(
                'Keep walking to unlock this app',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showStepSettingsDialog(ThemeData theme, AppInfo app) {
    final packageName = app.packageName ?? '';
    int currentRequirement = _appLockService.getStepRequirement(packageName);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: theme.cardTheme.color,
          title: Text(
            'Set Step Requirement',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'App: ${app.name}',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Steps Required: $currentRequirement',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Slider(
                value: currentRequirement.toDouble(),
                min: 10,
                max: 500,
                divisions: 49,
                label: currentRequirement.toString(),
                activeColor: AppTheme.primaryColor,
                onChanged: (value) {
                  setState(() {
                    currentRequirement = value.toInt();
                  });
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Current Steps:', 
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      '$_currentSteps',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                await _appLockService.setStepRequirement(
                  packageName,
                  currentRequirement,
                );
                if (mounted) {
                  Navigator.pop(context);
                  // Refresh the parent widget
                  this.setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Step requirement updated to $currentRequirement',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
