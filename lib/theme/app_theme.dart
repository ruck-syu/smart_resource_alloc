import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryNavy = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color accentBlue = Color(0xFF38BDF8);
  static const Color urgentRed = Color(0xFFEF4444);
  static const Color healthGreen = Color(0xFF10B981);
  static const Color foodAmber = Color(0xFFF59E0B);
  static const Color shelterIndigo = Color(0xFF6366F1);

  static Color getUrgencyColor(int score) {
    if (score >= 8) return urgentRed;
    if (score >= 5) return foodAmber;
    return healthGreen;
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryNavy,
      colorScheme: const ColorScheme.dark(
        primary: accentBlue,
        surface: surfaceDark,
        surfaceContainerHighest: surfaceDark,
        error: urgentRed,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryNavy,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentBlue,
          foregroundColor: primaryNavy,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
