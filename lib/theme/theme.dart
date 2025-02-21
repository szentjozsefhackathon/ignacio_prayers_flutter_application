import 'package:flutter/material.dart';
import 'colors.dart'; // Import the colors file

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light().copyWith(
      primary: AppColors.primary,
      onPrimary: AppColors.icons,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: AppColors.secondaryText,
      error: Colors.red,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.icons,
    ),
    dividerColor: AppColors.divider,
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark().copyWith(
      primary: AppColors.primaryDark,
      onPrimary: AppColors.icons,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      surface: Colors.black,
      onSurface: AppColors.secondaryText,
      error: Colors.red,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: AppColors.icons,
    ),
    dividerColor: AppColors.divider,
  );
}
