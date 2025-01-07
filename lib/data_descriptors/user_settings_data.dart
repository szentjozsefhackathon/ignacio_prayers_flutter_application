import 'package:flutter/material.dart';
import 'data_descriptor.dart';
import 'package:enum_to_string/enum_to_string.dart';

class UserSettingsData implements DataDescriptor{
  // Settings
  ThemeMode themeMode;
  bool dnd;
  bool dailyNotifier;
  int dailyNotifierHour;
  int dailyNotifierMinute;
  // TimeOfDay dailyNotifierTime = TimeOfDay(hour: dailyNotifierHour, minute: dailyNotifierMinute);

  // Prayer settings
  bool autoPageTurn;
  int prayerLength;
  bool prayerSoundEnabled;
  String voiceChoice;

  //Default values constructor
  UserSettingsData.withDefaults()
      : themeMode = ThemeMode.system,
        dnd = true,
        dailyNotifier = true,
        dailyNotifierHour = 8,
        dailyNotifierMinute = 0,
        autoPageTurn = true,
        prayerLength = 30,
        prayerSoundEnabled = true,
        voiceChoice = "Férfi 2";

  UserSettingsData({
    required this.themeMode,
    required this.dnd,
    required this.dailyNotifier,
    required this.dailyNotifierHour,
    required this.dailyNotifierMinute,
    required this.autoPageTurn,
    required this.prayerLength,
    required this.prayerSoundEnabled,
    required this.voiceChoice,
  });

  factory UserSettingsData.fromJson(Map<String, dynamic> json) => UserSettingsData(
    themeMode: EnumToString.fromString(ThemeMode.values, json["themeMode"]) ?? ThemeMode.system,
    dnd: json["dnd"],
    dailyNotifier: json["dailyNotifier"],
    dailyNotifierHour: json["dailyNotifierHour"],
    dailyNotifierMinute: json["dailyNotifierHour"],
    autoPageTurn: json["autoPageTurn"],
    prayerLength: json["prayerLength"],
    prayerSoundEnabled: json["prayerSoundEnabled"],
    voiceChoice: json["voiceChoice"],
  );

  Map<String, dynamic> toJson() => {
    "themeMode": EnumToString.convertToString(themeMode),
    "dnd": dnd,
    "dailyNotifier": dailyNotifier,
    "dailyNotifierHour": dailyNotifierHour,
    "dailyNotifierMinute": dailyNotifierMinute,
    "autoPageTurn": autoPageTurn,
    "prayerLength": prayerLength,
    "prayerSoundEnabled": prayerSoundEnabled,
    "voiceChoice": voiceChoice,
  };
}