import 'package:flutter/material.dart';

class LimitSettingsScreen extends StatefulWidget {
  const LimitSettingsScreen({super.key});

  @override
  State<LimitSettingsScreen> createState() => _LimitSettingsScreenState();
}

class _LimitSettingsScreenState extends State<LimitSettingsScreen> {
  double _stepsToUnlock = 1000;
  String _unlockType = 'Time Limit';
  double _unlockDuration = 15; // minutes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Limits'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Unlock Requirement'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Steps to Unlock'),
                        Text(
                          '${_stepsToUnlock.toInt()} steps',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _stepsToUnlock,
                      min: 100,
                      max: 10000,
                      divisions: 99,
                      label: _stepsToUnlock.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _stepsToUnlock = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Unlock Reward'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _unlockType,
                      decoration: const InputDecoration(
                        labelText: 'Unlock Type',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Time Limit', 'App Opens', 'Daily Limit']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _unlockType = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    if (_unlockType == 'Time Limit') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Duration'),
                          Text(
                            '${_unlockDuration.toInt()} mins',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _unlockDuration,
                        min: 5,
                        max: 120,
                        divisions: 23,
                        label: _unlockDuration.round().toString(),
                        onChanged: (double value) {
                          setState(() {
                            _unlockDuration = value;
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context);
        },
        label: const Text('Save Settings'),
        icon: const Icon(Icons.save),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
      ),
    );
  }
}
