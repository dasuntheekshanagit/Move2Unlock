import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _soundEffects = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('setting_dark_mode') ?? false;
      _notifications = prefs.getBool('setting_notifications') ?? true;
      _soundEffects = prefs.getBool('setting_sound') ?? true;
    });
  }

  Future<void> _updateSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    setState(() {
      if (key == 'setting_dark_mode') {
        _darkMode = value;
        // Update app theme
        MotivationLockApp.of(context)?.changeTheme(value ? ThemeMode.dark : ThemeMode.light);
      }
      if (key == 'setting_notifications') _notifications = value;
      if (key == 'setting_sound') _soundEffects = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onBackground,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: theme.colorScheme.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader(theme, 'General'),
          _buildSwitchTile(theme, 'Dark Mode', 'Use dark theme', _darkMode, (v) => _updateSetting('setting_dark_mode', v)),
          _buildSwitchTile(theme, 'Notifications', 'Enable push notifications', _notifications, (v) => _updateSetting('setting_notifications', v)),
          _buildSwitchTile(theme, 'Sound Effects', 'Play sounds on interaction', _soundEffects, (v) => _updateSetting('setting_sound', v)),
          
          const SizedBox(height: 32),
          _buildSectionHeader(theme, 'About'),
          _buildActionTile(theme, 'Version', '1.0.0', null),
          _buildActionTile(theme, 'Terms of Service', null, () {}),
          _buildActionTile(theme, 'Privacy Policy', null, () {}),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(ThemeData theme, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
        value: value,
        onChanged: onChanged,
        activeColor: theme.colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildActionTile(ThemeData theme, String title, String? trailingText, VoidCallback? onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: trailingText != null 
            ? Text(trailingText, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)))
            : Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.3)),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
