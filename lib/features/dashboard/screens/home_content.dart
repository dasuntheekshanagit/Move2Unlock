import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../../core/theme/app_theme.dart';
import '../../../core/services/step_service.dart';

class HomeContent extends StatefulWidget {
  final int steps;
  final VoidCallback onStatsTap;

  const HomeContent({super.key, required this.steps, required this.onStatsTap});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final StepService _stepService = StepService();
  Map<String, int> _weeklySteps = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeeklyData();
  }

  Future<void> _loadWeeklyData() async {
    try {
      final data = await _stepService.getWeeklySteps();
      if (mounted) {
        setState(() {
          _weeklySteps = data;
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

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      children: [
        const SizedBox(height: 24),
        _buildGreetingCard(theme),
        const SizedBox(height: 32),
        _buildStepsCard(theme, widget.steps),
        const SizedBox(height: 32),
        _buildMotivationCard(theme),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: widget.onStatsTap,
          child: _buildSmallStatGraph(theme),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildGreetingCard(ThemeData theme) {
    final now = DateTime.now();
    String greeting = 'Good morning';
    if (now.hour >= 12 && now.hour < 17) {
      greeting = 'Good afternoon';
    } else if (now.hour >= 17) {
      greeting = 'Good evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting,',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Dasun', // TODO: Get actual user name
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStepsCard(ThemeData theme, int steps) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(32),
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
          CustomPaint(
            size: const Size(200, 200),
            painter: CircularProgressPainter(
              progress: (steps / 10000).clamp(0.0, 1.0),
              color: AppTheme.primaryColor,
              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
            child: SizedBox(
              width: 200,
              height: 200,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.directions_walk_rounded,
                      size: 32,
                      color: AppTheme.primaryColor.withOpacity(0.8),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      steps.toString(),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'steps today',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatGraph(ThemeData theme) {
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
    if (maxSteps < 10000) maxSteps = 10000; // Minimum scale

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Activity',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last 7 days performance',
                    style: GoogleFonts.inter(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final dateKey = days[index];
                final steps = _weeklySteps[dateKey] ?? 0;
                final value = (steps / maxSteps).clamp(0.0, 1.0);
                final isToday = index == 6;
                
                // Day label
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
                          width: 12,
                          height: math.max(4, 100 * animatedValue), // Min height 4
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
    );
  }

  Widget _buildMotivationCard(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF064E3B).withOpacity(0.3) : const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.format_quote_rounded,
              size: 20,
              color: AppTheme.secondaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'The secret of getting ahead is getting started.',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFD1FAE5) : const Color(0xFF065F46),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '— Mark Twain',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF059669),
            ),
          ),
        ],
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = 16.0;

    // Background Arc
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      math.pi * 0.75,
      math.pi * 1.5,
      false,
      bgPaint,
    );

    // Progress Arc
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [color, const Color(0xFF06D6A0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      math.pi * 0.75,
      math.pi * 1.5 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
