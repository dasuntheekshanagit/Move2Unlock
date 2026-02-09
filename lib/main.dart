import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/splash/screens/splash_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  // Preload fonts
  GoogleFonts.config.allowRuntimeFetching = true;

  runApp(const MotivationLockApp());
}

class MotivationLockApp extends StatefulWidget {
  const MotivationLockApp({super.key});

  @override
  State<MotivationLockApp> createState() => _MotivationLockAppState();
  
  static _MotivationLockAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MotivationLockAppState>();
}

class _MotivationLockAppState extends State<MotivationLockApp> {
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
