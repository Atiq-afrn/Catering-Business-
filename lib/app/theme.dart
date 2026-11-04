import 'package:flutter/material.dart';

class AppTheme {
  // Cohesive executive palette matching the Login button (_navy)
  static const Color primaryDark = Color(0xFF203A5F); // Brand Executive Navy
  static const Color primaryNavy = Color(0xFF203A5F); // Brand Executive Navy
  static const Color primaryLight = Color(0xFF3B5B88); // Lighter Executive Navy

  static const Color accentEmerald = Color(0xFF059669); // Professional Forest Emerald
  static const Color accentEmeraldLight = Color(0xFFECFDF5);

  static const Color accentAmber = Color(0xFFD97706); // Warm subtle amber for warnings/pending
  static const Color accentAmberLight = Color(0xFFFFFBEB);

  static const Color accentBlue = Color(0xFF2563EB); // Royal Blue for primary CTAs
  static const Color accentBlueLight = Color(0xFFEFF6FF);

  static const Color surfaceBackground = Color(0xFFF8FAFC); // Clean crisp backdrop
  static const Color cardSurface = Colors.white;
  static const Color borderLight = Color(0xFFE2E8F0); // Subtle 1px borders

  // ── Professional Text Hierarchy (UPDATED) ──
  static const Color textPrimary   = Color(0xFF0F172A); // Main text & headings
  static const Color textSecondary = Color(0xFF475569); // Labels, subtitles & meta
  static const Color textMuted     = Color(0xFF94A3B8); // Placeholders & hints

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: surfaceBackground,
    primaryColor: primaryDark,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: primaryDark,
      onPrimary: Colors.white,
      secondary: accentEmerald,
      onSecondary: Colors.white,
      error: Color(0xFFDC2626),
      onError: Colors.white,
      surface: cardSurface,
      onSurface: textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: primaryDark,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: textPrimary, // Ensure it uses the new hierarchy
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      iconTheme: IconThemeData(color: primaryDark, size: 20),
    ),
    cardTheme: CardThemeData(
      color: cardSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: borderLight, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      hintStyle: const TextStyle(color: textMuted, fontSize: 13.5),
      labelStyle: const TextStyle(color: textSecondary, fontSize: 13.5, fontWeight: FontWeight.w500),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: borderLight, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: borderLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryNavy, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: primaryDark.withValues(alpha: 0.35),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryDark,
      foregroundColor: Colors.white,
      elevation: 3,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryDark,
        side: const BorderSide(color: borderLight, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
      ),
    ),
    // ── Text Theme configured with the new hierarchy ──
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.3,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 13.5,
        color: textPrimary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: textSecondary,
      ),
    ),
  );
}