import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AppColors {
  // Ana Renkler - iOS Dark Mode
  static const Color primary = Color(0xFF00D9FF); // Cyan
  static const Color secondary = Color(0xFF7C3AED); // Purple
  static const Color accent = Color(0xFFFF6B9D); // Pink

  // Background - iOS stilinde
  static const Color bgDark = Color(0xFF0F1117);
  static const Color bgCard = Color(0xFF1C1C1E); // iOS Card Color
  static const Color bgCardLight = Color(0xFF2C2C2E);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary = Color(0xFF6E6E73);

  // Status
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color danger = Color(0xFFFF3B30);
  static const Color info = Color(0xFF30B0C0);
}

class AppTheme {
  static ThemeData get iOSTheme {
    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.bgDark,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgCard,
        elevation: 0,
        centerTitle: true,
      ),
      cardColor: AppColors.bgCard,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgCard,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
      ),
    );
  }

  static CupertinoThemeData get iOSCupertinoTheme {
    return CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      barBackgroundColor: AppColors.bgCard,
      scaffoldBackgroundColor: AppColors.bgDark,
    );
  }
}
