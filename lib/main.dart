import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/auth_screen.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const MotivationLockApp());
}

class MotivationLockApp extends StatelessWidget {
  const MotivationLockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Motivation Lock',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      home: const AuthScreen(),
    );
  }

  ThemeData _buildLightTheme() {
    final base = ThemeData.light(useMaterial3: true);
    
    // Modern Indigo Theme
    const primaryColor = Color(0xFF6366F1); // Modern Indigo
    const secondaryColor = Color(0xFFEEF2FF); // Very Light Indigo Background
    const surfaceColor = Colors.white;
    const textColor = Color(0xFF1F2937); // Gray 800
    const textSecondaryColor = Color(0xFF6B7280); // Gray 500
    const accentColor = Color(0xFF10B981); // Emerald Green

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: accentColor,
        tertiary: const Color(0xFFF59E0B), // Amber
        surface: surfaceColor,
        background: secondaryColor,
        onBackground: textColor,
        onSurface: textColor,
      ),
      scaffoldBackgroundColor: secondaryColor,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: surfaceColor,
        margin: EdgeInsets.zero,
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F4F6), // Gray 100
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: textSecondaryColor, fontSize: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: secondaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: textColor, size: 22),
      ),
      textTheme: base.textTheme.apply(
        fontFamily: 'System', 
        displayColor: textColor,
        bodyColor: textColor,
      ).copyWith(
        displayLarge: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 32,
          letterSpacing: -1.0,
        ),
        headlineMedium: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 24,
        ),
        titleLarge: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          letterSpacing: -0.5,
        ),
        titleMedium: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        bodyLarge: TextStyle(
          color: textColor,
          fontSize: 14,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: textSecondaryColor,
          fontSize: 13,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          color: textSecondaryColor,
          fontSize: 12,
          height: 1.3,
        ),
      ),
      dividerColor: const Color(0xFFE5E7EB),
    );
  }

  ThemeData _buildDarkTheme() {
    final base = ThemeData.dark(useMaterial3: true);
    
    // Dark Theme Adaptation
    const primaryColor = Color(0xFF818CF8); // Lighter Indigo
    const backgroundColor = Color(0xFF111827); // Gray 900
    const surfaceColor = Color(0xFF1F2937); // Gray 800
    
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: const Color(0xFF34D399),
        surface: surfaceColor,
        background: backgroundColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: surfaceColor,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF374151), // Gray 700
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(size: 22),
      ),
    );
  }
}
