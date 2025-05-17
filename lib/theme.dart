import 'package:flutter/material.dart';

// https://konyvjelzo.jezsuita.hu/arculat/
const kColorSchemeSeed = Color(0xffba0527);

class AppTheme {
  AppTheme._();

  static ThemeData _createTheme(Brightness brightness) => ThemeData(
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kColorSchemeSeed,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
      contrastLevel: 1,
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );

  static final light = _createTheme(Brightness.light);
  static final dark = _createTheme(Brightness.dark);
}
