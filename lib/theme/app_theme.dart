import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color darkBg = Color(0xFF121212);
  static const Color cardBg = Color(0xFF1E1E1E);
  static const Color surfaceBg = Color(0xFF2C2C2C);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color accentPurple = Color(0xFF9C27B0);
  static const Color dangerRed = Color(0xFFF44336);
  static const Color onlineGreen = Color(0xFF4CAF50);
  static const Color offlineGrey = Color(0xFF757575);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: darkBg,
    cardColor: cardBg,
    appBarTheme: AppBarTheme(
      backgroundColor: darkBg,
      elevation: 0,
      iconTheme: IconThemeData(color: primaryGreen),
      titleTextStyle: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      labelStyle: TextStyle(color: textSecondary),
    ),
    cardTheme: CardThemeData(
      color: cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
