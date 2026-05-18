import 'package:flutter/material.dart';

class AppColors {
  static const Color green = Color(0xFF1D9E75);
  static const Color greenDark = Color(0xFF0F6E56);
  static const Color greenLight = Color(0xFFE1F5EE);
  static const Color greenMid = Color(0xFF5DCAA5);
  static const Color amber = Color(0xFFEF9F27);
  static const Color red = Color(0xFFE24B4A);
  static const Color blue = Color(0xFF378ADD);
  static const Color bg = Color(0xFFF7FAF9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0x14000000);
  static const Color text = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.green,
        background: AppColors.bg,
      ),
      scaffoldBackgroundColor: AppColors.bg,
      fontFamily: 'Sora',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.text,
        elevation: 0,
        shadowColor: AppColors.border,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'Sora',
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.green, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.textLight, fontFamily: 'Sora'),
      ),
    );
  }
}
