import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  void _close(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 80,
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Unlock Full Potential',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Get unlimited access to all features, remove ads, and support development.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 48),
                    _buildFeatureRow(context, 'Unlimited App Locks'),
                    _buildFeatureRow(context, 'Custom Step Goals'),
                    _buildFeatureRow(context, 'Detailed Statistics'),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: () => _close(context), // Mock purchase
                        child: const Text(
                          'Start Free Trial',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Restore Purchase'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 40, // Adjust for status bar
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _close(context),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
