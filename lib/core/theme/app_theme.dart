import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette
  static const primaryColor = Color(0xFF4F46E5); // Deep Indigo
  static const primaryVariant = Color(0xFF7C3AED); // Violet
  static const secondaryColor = Color(0xFF06D6A0); // Mint Green
  static const warningColor = Color(0xFFFBBF24); // Warm Amber
  static const errorColor = Color(0xFFEF4444); // Error Red
  
  // Light Theme Colors
  static const backgroundLight = Color(0xFFF8FAFC); // Cool gray-white
  static const surfaceLight = Color(0xFFFFFFFF); // White
  static const textPrimaryLight = Color(0xFF0F172A); // Main text
  static const textSecondaryLight = Color(0xFF64748B); // Muted text
  static const inputFillLight = Color(0xFFF1F5F9);

  // Dark Theme Colors
  static const backgroundDark = Color(0xFF0F172A); // Deep navy
  static const surfaceDark = Color(0xFF1E293B); // Dark cards
  static const textPrimaryDark = Color(0xFFF1F5F9); // Main text dark
  static const textSecondaryDark = Color(0xFF94A3B8); // Muted text dark
  static const inputFillDark = Color(0xFF1E293B);

  static TextTheme _buildTextTheme(TextTheme base, Color primaryTextColor, Color secondaryTextColor) {
    return base.copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(
        color: primaryTextColor,
        fontWeight: FontWeight.bold,
        fontSize: 32,
        letterSpacing: -1.0,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        color: primaryTextColor,
        fontWeight: FontWeight.bold,
        fontSize: 28,
        letterSpacing: -0.8,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        color: primaryTextColor,
        fontWeight: FontWeight.bold,
        fontSize: 24,
        letterSpacing: -0.6,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        color: primaryTextColor,
        fontWeight: FontWeight.w800,
        fontSize: 20,
        letterSpacing: -0.5,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        color: primaryTextColor,
        fontWeight: FontWeight.w700,
        fontSize: 18,
        letterSpacing: -0.4,
      ),
      titleMedium: GoogleFonts.inter(
        color: primaryTextColor,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      bodyLarge: GoogleFonts.inter(
        color: primaryTextColor,
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.inter(
        color: secondaryTextColor,
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: GoogleFonts.inter(
        color: secondaryTextColor,
        fontSize: 12,
        height: 1.4,
        fontWeight: FontWeight.w500,
      ),
      labelLarge: GoogleFonts.spaceGrotesk(
        color: primaryTextColor,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
    );
  }

  static ThemeData buildLightTheme() {
    final base = ThemeData.light(useMaterial3: true);
    
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: warningColor,
        error: errorColor,
        surface: surfaceLight,
        background: backgroundLight,
        onBackground: textPrimaryLight,
        onSurface: textPrimaryLight,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundLight,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: surfaceLight,
        margin: EdgeInsets.zero,
        shadowColor: const Color(0x0A000000),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFillLight,
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
          borderSide: const BorderSide(color: primaryColor, width: 1.0),
        ),
        contentPadding: const EdgeInsets.all(16),
        hintStyle: GoogleFonts.inter(color: textSecondaryLight, fontSize: 14),
        prefixIconColor: primaryColor.withOpacity(0.5),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          minimumSize: const Size.fromHeight(56),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          minimumSize: const Size.fromHeight(56),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: const IconThemeData(color: textPrimaryLight, size: 24),
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceLight,
        indicatorColor: primaryColor.withOpacity(0.12),
        labelTextStyle: MaterialStateProperty.all(
          GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: textPrimaryLight),
        ),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(size: 22, color: primaryColor);
          }
          return const IconThemeData(size: 22, color: textSecondaryLight);
        }),
        height: 65,
        elevation: 0,
      ),
      textTheme: _buildTextTheme(base.textTheme, textPrimaryLight, textSecondaryLight),
      dividerColor: const Color(0xFFE2E8F0),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E8F0),
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData buildDarkTheme() {
    final base = ThemeData.dark(useMaterial3: true);
    
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: warningColor,
        error: errorColor,
        surface: surfaceDark,
        background: backgroundDark,
        onBackground: textPrimaryDark,
        onSurface: textPrimaryDark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: surfaceDark,
        margin: EdgeInsets.zero,
        shadowColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFillDark,
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
          borderSide: const BorderSide(color: primaryColor, width: 1.0),
        ),
        contentPadding: const EdgeInsets.all(16),
        hintStyle: GoogleFonts.inter(color: textSecondaryDark, fontSize: 14),
        prefixIconColor: primaryColor.withOpacity(0.5),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          minimumSize: const Size.fromHeight(56),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          minimumSize: const Size.fromHeight(56),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: const IconThemeData(color: textPrimaryDark, size: 24),
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceDark,
        indicatorColor: primaryColor.withOpacity(0.12),
        labelTextStyle: MaterialStateProperty.all(
          GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: textPrimaryDark),
        ),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(size: 22, color: primaryColor);
          }
          return const IconThemeData(size: 22, color: textSecondaryDark);
        }),
        height: 65,
        elevation: 0,
      ),
      textTheme: _buildTextTheme(base.textTheme, textPrimaryDark, textSecondaryDark),
      dividerColor: const Color(0xFF334155),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF334155),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
