import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../../core/theme/app_theme.dart';
import '../../../core/services/step_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final StepService _stepService = StepService();
  Map<String, int> _weeklySteps = {};
  int _totalSteps = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final weekly = await _stepService.getWeeklySteps();
      final total = await _stepService.getTotalStepsAllTime();
      
      if (mounted) {
        setState(() {
          _weeklySteps = weekly;
          _totalSteps = total;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Prepare data for graph
    final now = DateTime.now();
    final days = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return date.toIso8601String().split('T')[0];
    });
    
    // Find max steps for scaling
    int maxSteps = 1;
    for (var steps in _weeklySteps.values) {
      if (steps > maxSteps) maxSteps = steps;
    }
    if (maxSteps < 10000) maxSteps = 10000;

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        _buildStatCard(
          theme,
          'Total Steps',
          _totalSteps,
          Icons.directions_walk_rounded,
          const Color(0xFF10B981),
        ),
        const SizedBox(height: 16),
        // Placeholder for Time Saved - logic needs to be implemented based on app usage
        _buildStatCard(
          theme,
          'Time Saved',
          0, 
          Icons.hourglass_empty_rounded,
          const Color(0xFFF59E0B),
          suffix: 'h 0m',
        ),
        const SizedBox(height: 16),
        // Placeholder for Apps Unlocked - logic needs to be implemented
        _buildStatCard(
          theme,
          'Apps Unlocked',
          0,
          Icons.lock_open_rounded,
          const Color(0xFF06B6D4),
        ),
        const SizedBox(height: 32),
        Text(
          'Weekly Activity',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 220,
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
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (index) {
                    final dateKey = days[index];
                    final steps = _weeklySteps[dateKey] ?? 0;
                    final value = (steps / maxSteps).clamp(0.0, 1.0);
                    final isToday = index == 6;
                    
                    final date = DateTime.parse(dateKey);
                    final dayLabel = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][date.weekday - 1];

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: value),
                      duration: Duration(milliseconds: 500 + (index * 100)),
                      curve: Curves.easeOutQuart,
                      builder: (context, animatedValue, child) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 16,
                              height: math.max(4, 140 * animatedValue),
                              decoration: BoxDecoration(
                                gradient: isToday ? const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [AppTheme.primaryColor, AppTheme.primaryVariant],
                                ) : null,
                                color: isToday ? null : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: isToday ? [
                                  BoxShadow(
                                    color: AppTheme.primaryColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ] : null,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              dayLabel,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isToday
                                    ? AppTheme.primaryColor
                                    : theme.colorScheme.onSurface.withOpacity(0.4),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String title,
    int value,
    IconData icon,
    Color color, {
    String? suffix,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: value),
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeOutExpo,
                  builder: (context, animatedValue, child) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          animatedValue.toString(),
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (suffix != null)
                          Text(
                            suffix,
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
