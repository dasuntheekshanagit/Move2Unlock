import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const helpColor = Color(0xFF3B82F6);

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
                    colors: [helpColor, Color(0xFF2563EB)],
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
                'Help & FAQs',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              centerTitle: false,
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFAQItem(
                    theme,
                    'How does Motivation Lock work?',
                    'Motivation Lock helps you stay focused by locking apps you select. You can unlock them by completing tasks like taking steps or waiting for a time limit. It\'s designed to encourage productivity and help you achieve your goals.',
                    Icons.question_answer_rounded,
                    const Color(0xFF06B6D4),
                  ),
                  const SizedBox(height: 16),
                  _buildFAQItem(
                    theme,
                    'Can I customize lock settings per app?',
                    'Yes! You can set different unlock requirements for each app. Go to App Controls, select an app, and tap the settings icon to configure individual app limits.',
                    Icons.settings_rounded,
                    const Color(0xFFF59E0B),
                  ),
                  const SizedBox(height: 16),
                  _buildFAQItem(
                    theme,
                    'What are global limits?',
                    'Global limits apply to all locked apps at once. You can set a time-based or step-based limit that affects all apps simultaneously.',
                    Icons.public_rounded,
                    const Color(0xFF10B981),
                  ),
                  const SizedBox(height: 16),
                  _buildFAQItem(
                    theme,
                    'How accurate is the step counter?',
                    'The step counter uses your device\'s built-in sensors. Accuracy depends on your device and how you carry it. Normal walking and arm movements are detected accurately.',
                    Icons.directions_walk_rounded,
                    const Color(0xFFEC4899),
                  ),
                  const SizedBox(height: 16),
                  _buildFAQItem(
                    theme,
                    'Can I disable notifications?',
                    'Yes, you can disable notifications for individual apps or globally in the settings.',
                    Icons.notifications_off_rounded,
                    const Color(0xFF8B5CF6),
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

  Widget _buildFAQItem(
    ThemeData theme,
    String question,
    String answer,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.08), color.withOpacity(0.02)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  answer,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.4,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
