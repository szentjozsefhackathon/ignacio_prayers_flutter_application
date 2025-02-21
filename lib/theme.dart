import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const _kPrimaryColor = Color(0xFFBA0527);
  static const _kPrimaryColorDark = Color(0xFFBA0527);

  static final light = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _kPrimaryColor,
      brightness: Brightness.light,
      dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
      contrastLevel: 1,
    ),
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _kPrimaryColorDark,
      brightness: Brightness.dark,
      dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
      contrastLevel: 1,
    ),
  );
}
