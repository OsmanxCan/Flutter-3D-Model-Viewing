import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Renk paleti - askeri / havacılık teması
  static const Color bgDeep = Color(0xFF080C12);
  static const Color bgSurface = Color(0xFF0D1520);
  static const Color bgPanel = Color(0xFF111C2A);
  static const Color bgCard = Color(0xFF162030);
  static const Color accentBlue = Color(0xFF00A8FF);
  static const Color accentCyan = Color(0xFF00FFE7);
  static const Color accentOrange = Color(0xFFFF6B2B);
  static const Color accentGreen = Color(0xFF00FF88);
  static const Color textPrimary = Color(0xFFE8F4FD);
  static const Color textSecondary = Color(0xFF8AAABB);
  static const Color textMuted = Color(0xFF3D5566);
  static const Color borderGlow = Color(0xFF1A3A5C);
  static const Color gridLine = Color(0xFF0F2035);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDeep,
      colorScheme: const ColorScheme.dark(
        primary: accentBlue,
        secondary: accentCyan,
        tertiary: accentOrange,
        surface: bgSurface,
        background: bgDeep,
      ),
      textTheme: GoogleFonts.rajdhaniTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
          displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          displaySmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          headlineSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
          titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, letterSpacing: 1.5),
          titleMedium: TextStyle(color: textSecondary, fontWeight: FontWeight.w500, letterSpacing: 1.2),
          titleSmall: TextStyle(color: textSecondary, letterSpacing: 1.0),
          bodyLarge: TextStyle(color: textPrimary),
          bodyMedium: TextStyle(color: textSecondary),
          bodySmall: TextStyle(color: textMuted),
          labelLarge: TextStyle(color: accentBlue, fontWeight: FontWeight.w600, letterSpacing: 1.5),
          labelMedium: TextStyle(color: textSecondary, letterSpacing: 1.2),
          labelSmall: TextStyle(color: textMuted, letterSpacing: 1.0),
        ),
      ),
      dividerColor: borderGlow,
    );
  }
}
