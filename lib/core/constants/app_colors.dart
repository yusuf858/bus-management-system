import 'package:flutter/material.dart';

class AppColors {
  // Primary maroon theme
  static const Color primaryColor = Color(0xFF7B1E1E);
  static const Color primaryDark = Color(0xFF5A1616);
  static const Color primaryLight = Color(0xFF9E3838);

  // Accent gold color
  static const Color accentColor = Color(0xFFD4A537);
  static const Color accentLight = Color(0xFFE6C56D);

  // Background colors
  static const Color backgroundColor = Color(0xFFF5F0E8);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFFAF8F3);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // Border and divider
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color dividerColor = Color(0xFFEEEEEE);

  // Shadows
  static final Color shadowColor = Colors.black.withOpacity(0.1);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentColor, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}