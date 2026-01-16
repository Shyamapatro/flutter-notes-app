import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // CRED-inspired Palette
  static const _black = Color(0xFF0D0D0D);
  static const _offWhite = Color(0xFFF0F0F3);
  static const _accent = Color(0xFF3A3A3A); // Dark gray accent
  static const _highlight = Color(0xFFE2E2E2); // Soft white highlight

  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: GoogleFonts.syncopate(textStyle: base.displayLarge, fontWeight: FontWeight.bold),
      displayMedium: GoogleFonts.syncopate(textStyle: base.displayMedium, fontWeight: FontWeight.bold),
      displaySmall: GoogleFonts.syncopate(textStyle: base.displaySmall, fontWeight: FontWeight.bold),
      headlineLarge: GoogleFonts.spaceGrotesk(textStyle: base.headlineLarge, fontWeight: FontWeight.bold),
      headlineMedium: GoogleFonts.spaceGrotesk(textStyle: base.headlineMedium, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.spaceGrotesk(textStyle: base.titleLarge, fontWeight: FontWeight.w700),
      titleMedium: GoogleFonts.spaceGrotesk(textStyle: base.titleMedium, fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.dmSans(textStyle: base.bodyLarge, height: 1.5, fontSize: 16),
      bodyMedium: GoogleFonts.dmSans(textStyle: base.bodyMedium, height: 1.5),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _offWhite,
        onPrimary: _black,
        surface: _black,
        onSurface: _offWhite,
        surfaceContainerLow: _accent,
        outline: _accent,
      ),
      scaffoldBackgroundColor: _black,
      textTheme: _buildTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: _black,
        foregroundColor: _offWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _offWhite,
        foregroundColor: _black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero), // Brutalist shape
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _accent.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(0),
           borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
           borderRadius: BorderRadius.zero,
           borderSide: BorderSide(color: _offWhite, width: 1),
        ),
      ),
    );
  }

  // We enforce Dark Mode for this specific aesthetic request
  static ThemeData get lightTheme => darkTheme; 
}
