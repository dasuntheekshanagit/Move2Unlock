import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        _buildStatCard(
          theme,
          'Total Steps',
          45231,
          Icons.directions_walk_rounded,
          const Color(0xFF10B981),
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          theme,
          'Time Saved',
          12, // Hours
          Icons.hourglass_empty_rounded,
          const Color(0xFFF59E0B),
          suffix: 'h 30m',
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          theme,
          'Apps Unlocked',
          156,
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
          child: Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (index) {
                    final value = [0.4, 0.6, 0.3, 0.8, 0.5, 0.9, 0.7][index];
                    final isToday = index == 6;
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
                              height: 140 * animatedValue,
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
                              ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index],
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
              ],
            ),
          ),
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
    );
  }
}
