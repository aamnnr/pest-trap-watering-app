import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Modern Premium Dark Palette
  static const Color darkBg = Color(0xFF0F172A); // Slate 900
  static const Color cardBg = Color(0xFF1E293B); // Slate 800
  static const Color surfaceBg = Color(0xFF334155); // Slate 700

  // Vibrant Accents
  static const Color primaryGreen = Color(0xFF10B981); // Emerald 500
  static const Color accentBlue = Color(0xFF3B82F6); // Blue 500
  static const Color accentPurple = Color(0xFF8B5CF6); // Violet 500
  static const Color dangerRed = Color(0xFFEF4444); // Red 500
  static const Color onlineGreen = Color(0xFF22C55E); // Green 500
  static const Color offlineGrey = Color(0xFF64748B); // Slate 500
  static const Color warningOrange = Color(0xFFF59E0B); // Amber 500

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    final textTheme = GoogleFonts.outfitTextTheme(
      base.textTheme,
    ).apply(bodyColor: textPrimary, displayColor: textPrimary);

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: darkBg,
      cardColor: cardBg,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryGreen),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardBg,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          elevation: 4,
          shadowColor: primaryGreen.withValues(alpha: 0.4),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceBg.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.5)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceBg.withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardBg,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
