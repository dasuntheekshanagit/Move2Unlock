import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/splash/screens/splash_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/services/permission_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  // Disable runtime font fetching to avoid network errors
  // GoogleFonts.config.allowRuntimeFetching = false;

  // Request permissions early
  PermissionService.requestAllPermissions();

  runApp(const MotivationLockApp());
}

class MotivationLockApp extends StatefulWidget {
  const MotivationLockApp({super.key});

  @override
  State<MotivationLockApp> createState() => MotivationLockAppState();
  
  static MotivationLockAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<MotivationLockAppState>();
}

class MotivationLockAppState extends State<MotivationLockApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('setting_dark_mode');
    setState(() {
      if (isDark == true) {
        _themeMode = ThemeMode.dark;
      } else if (isDark == false) {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system;
      }
    });
  }

  void changeTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Move2Unlock',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildLightTheme(),
      darkTheme: AppTheme.buildDarkTheme(),
      themeMode: _themeMode,
      home: const SplashScreen(),
    );
  }
}
