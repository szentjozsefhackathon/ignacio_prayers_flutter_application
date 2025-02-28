import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData _createTheme(Brightness brightness, Color seed) => ThemeData(
        brightness: brightness,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: brightness,
          dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
          contrastLevel: 1,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      );

  static final light = _createTheme(Brightness.light, const Color(0xFFBA0527));
  static final dark = _createTheme(Brightness.dark, const Color(0xFFBA0527));
}
