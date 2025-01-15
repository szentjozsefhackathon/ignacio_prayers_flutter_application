import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kLanguageCode = 'languageCode';

const String kEnglish = 'en';
const String kFarsi = 'fa';
const String kArabic = 'ar';
const String kHindi = 'hi';

Future<Locale> setLocale(String languageCode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(kLanguageCode, languageCode);
  return _locale(languageCode);
}

Future<Locale> getLocale() async {
  final prefs = await SharedPreferences.getInstance();
  final languageCode = prefs.getString(kLanguageCode) ?? kEnglish;
  return _locale(languageCode);
}

Locale _locale(String languageCode) => switch (languageCode) {
      kFarsi => const Locale(kFarsi, 'IR'),
      kArabic => const Locale(kArabic, 'SA'),
      kHindi => const Locale(kHindi, 'IN'),
      _ => const Locale(kEnglish, 'US'),
    };
