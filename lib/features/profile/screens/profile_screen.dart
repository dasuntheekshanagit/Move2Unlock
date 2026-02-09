import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/screens/auth_screen.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('user_name') ?? 'User';
      _emailController.text =
          prefs.getString('user_email') ?? 'user@example.com';
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text);
    await prefs.setString('user_email', _emailController.text);
    setState(() {
      _isEditing = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all data on logout for now
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (route) => false,
      );
    }
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
          'My Profile',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check_rounded, color: AppTheme.primaryColor),
              onPressed: _saveProfile,
            )
          else
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: AppTheme.primaryColor),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.primaryColor, AppTheme.primaryVariant],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _nameController.text.isNotEmpty 
                          ? _nameController.text[0].toUpperCase() 
                          : 'U',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildEditableField(
                  theme,
                  'Name',
                  _nameController,
                  Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _buildEditableField(
                  theme,
                  'Email',
                  _emailController,
                  Icons.email_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _buildProfileOption(
            theme,
            'Change Password',
            Icons.lock_outline,
          ),
          _buildProfileOption(
            theme,
            'Notifications',
            Icons.notifications_outlined,
          ),
          _buildProfileOption(
            theme,
            'Privacy Policy',
            Icons.privacy_tip_outlined,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _logout,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.errorColor.withOpacity(0.1),
                foregroundColor: AppTheme.errorColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: const Text('Log Out'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(
    ThemeData theme,
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    
    return TextField(
      controller: controller,
      enabled: _isEditing,
      style: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
          fontSize: 12,
        ),
        prefixIcon: Icon(
          icon,
          size: 20,
          color: AppTheme.primaryColor.withOpacity(0.6),
        ),
        filled: true,
        fillColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        border: _isEditing 
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor),
              )
            : UnderlineInputBorder(
                borderSide: BorderSide(color: theme.dividerColor),
              ),
        enabledBorder: _isEditing
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor),
              )
            : UnderlineInputBorder(
                borderSide: BorderSide(color: theme.dividerColor),
              ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    ThemeData theme,
    String title,
    IconData icon,
  ) {
    return ListTile(
      onTap: () {},
      leading: Icon(icon, size: 24, color: AppTheme.primaryColor),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: theme.colorScheme.onSurface.withOpacity(0.3),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
