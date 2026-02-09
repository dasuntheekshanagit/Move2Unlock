import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../main.dart';
import '../../../core/theme/app_theme.dart';
import '../../support/screens/help_screen.dart';
import '../../support/screens/support_screen.dart';

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
        MotivationLockApp.of(
          context,
        )?.changeTheme(value ? ThemeMode.dark : ThemeMode.light);
      }
      if (key == 'setting_notifications') _notifications = value;
      if (key == 'setting_sound') _soundEffects = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader(theme, 'Preferences'),
          Card(
            child: Column(
              children: [
                _buildSwitchTile(
                  theme,
                  'Dark Mode',
                  'Use dark theme',
                  Icons.dark_mode_rounded,
                  _darkMode,
                  (v) => _updateSetting('setting_dark_mode', v),
                ),
                Divider(color: theme.dividerColor),
                _buildSwitchTile(
                  theme,
                  'Notifications',
                  'Enable push notifications',
                  Icons.notifications_rounded,
                  _notifications,
                  (v) => _updateSetting('setting_notifications', v),
                ),
                Divider(color: theme.dividerColor),
                _buildSwitchTile(
                  theme,
                  'Sound Effects',
                  'Play sounds on interaction',
                  Icons.volume_up_rounded,
                  _soundEffects,
                  (v) => _updateSetting('setting_sound', v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(theme, 'Help & Support'),
          Card(
            child: Column(
              children: [
                _buildActionTile(
                  theme,
                  'Help & FAQs',
                  null,
                  Icons.help_outline_rounded,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpScreen(),
                      ),
                    );
                  },
                ),
                Divider(color: theme.dividerColor),
                _buildActionTile(
                  theme,
                  'Contact Support',
                  null,
                  Icons.support_agent_rounded,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SupportScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(theme, 'About App'),
          Card(
            child: Column(
              children: [
                _buildActionTile(
                  theme,
                  'Version',
                  '1.0.0',
                  Icons.info_outline_rounded,
                  null,
                ),
                Divider(color: theme.dividerColor),
                _buildActionTile(
                  theme,
                  'Terms of Service',
                  null,
                  Icons.description_outlined,
                  () {},
                ),
                Divider(color: theme.dividerColor),
                _buildActionTile(
                  theme,
                  'Privacy Policy',
                  null,
                  Icons.privacy_tip_outlined,
                  () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
          fontSize: 11,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor, size: 24),
        title: Text(
          title,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildActionTile(
    ThemeData theme,
    String title,
    String? trailingText,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppTheme.primaryColor, size: 24),
      title: Text(
        title,
        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      trailing: trailingText != null
          ? Text(
              trailingText,
              style: GoogleFonts.inter(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            )
          : Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
    );
  }
}
