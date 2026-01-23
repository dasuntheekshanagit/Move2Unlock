import 'package:flutter/material.dart';

class AppSelectionScreen extends StatefulWidget {
  const AppSelectionScreen({super.key});

  @override
  State<AppSelectionScreen> createState() => _AppSelectionScreenState();
}

class _AppSelectionScreenState extends State<AppSelectionScreen> {
  // Mock data for installed apps
  final List<Map<String, dynamic>> _apps = [
    {'name': 'Instagram', 'icon': Icons.camera_alt, 'isSelected': false},
    {'name': 'Facebook', 'icon': Icons.facebook, 'isSelected': false},
    {'name': 'TikTok', 'icon': Icons.music_note, 'isSelected': false},
    {'name': 'YouTube', 'icon': Icons.play_circle_filled, 'isSelected': false},
    {'name': 'Twitter', 'icon': Icons.chat, 'isSelected': false},
    {'name': 'Snapchat', 'icon': Icons.snapchat, 'isSelected': false},
    {'name': 'WhatsApp', 'icon': Icons.message, 'isSelected': false},
    {'name': 'Gmail', 'icon': Icons.email, 'isSelected': false},
    {'name': 'Phone', 'icon': Icons.phone, 'isSelected': false},
    {'name': 'Messages', 'icon': Icons.message_outlined, 'isSelected': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Apps to Lock'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search apps...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _apps.length,
              itemBuilder: (context, index) {
                final app = _apps[index];
                return CheckboxListTile(
                  value: app['isSelected'],
                  onChanged: (bool? value) {
                    setState(() {
                      app['isSelected'] = value!;
                    });
                  },
                  title: Text(app['name']),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      app['icon'],
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context);
        },
        label: const Text('Save Selection'),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
