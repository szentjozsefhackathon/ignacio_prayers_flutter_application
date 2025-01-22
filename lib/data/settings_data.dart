import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common.dart';

part 'settings_data.g.dart';

const _kUserSettings = 'userData';

@JsonSerializable()
class SettingsData extends ChangeNotifier implements DataDescriptor {
  SettingsData({
    ThemeMode themeMode = ThemeMode.system,
    bool dnd = true,
    bool dailyNotifier = true,
    TimeOfDay dailyNotifierTime = const TimeOfDay(hour: 8, minute: 0),
    bool autoPageTurn = true,
    int prayerLength = 30,
    bool prayerSoundEnabled = true,
    String voiceChoice = 'Férfi 2',
  })  : _themeMode = themeMode,
        _dnd = dnd,
        _dailyNotifier = dailyNotifier,
        _dailyNotifierTime = dailyNotifierTime,
        _autoPageTurn = autoPageTurn,
        _prayerLength = prayerLength,
        _prayerSoundEnabled = prayerSoundEnabled,
        _voiceChoice = voiceChoice;

  factory SettingsData.fromJson(Map<String, dynamic> json) =>
      _$SettingsDataFromJson(json);

  static final log = Logger('UserSettingsData');

  ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;
  set themeMode(ThemeMode newValue) {
    if (_themeMode != newValue) {
      _themeMode = newValue;
      save();
      notifyListeners();
    }
  }

  bool _dnd;
  bool get dnd => _dnd;
  set dnd(bool newValue) {
    if (_dnd != newValue) {
      _dnd = newValue;
      save();
      notifyListeners();
    }
  }

  bool _dailyNotifier;
  bool get dailyNotifier => _dailyNotifier;
  set dailyNotifier(bool newValue) {
    if (_dailyNotifier != newValue) {
      _dailyNotifier = newValue;
      save();
      notifyListeners();
    }
  }

  TimeOfDay _dailyNotifierTime;
  @TimeOfDayConverter()
  TimeOfDay get dailyNotifierTime => _dailyNotifierTime;
  set dailyNotifierTime(TimeOfDay newValue) {
    if (_dailyNotifierTime != newValue) {
      _dailyNotifierTime = newValue;
      save();
      notifyListeners();
    }
  }

  bool _autoPageTurn;
  bool get autoPageTurn => _autoPageTurn;
  set autoPageTurn(bool newValue) {
    if (_autoPageTurn != newValue) {
      _autoPageTurn = newValue;
      save();
      notifyListeners();
    }
  }

  int _prayerLength;
  int get prayerLength => _prayerLength;
  set prayerLength(int newValue) {
    if (_prayerLength != newValue) {
      _prayerLength = newValue;
      save();
      notifyListeners();
    }
  }

  bool _prayerSoundEnabled;
  bool get prayerSoundEnabled => _prayerSoundEnabled;
  set prayerSoundEnabled(bool newValue) {
    if (_prayerSoundEnabled != newValue) {
      _prayerSoundEnabled = newValue;
      save();
      notifyListeners();
    }
  }

  String _voiceChoice;
  String get voiceChoice => _voiceChoice;
  set voiceChoice(String newValue) {
    if (_voiceChoice != newValue) {
      _voiceChoice = newValue;
      save();
      notifyListeners();
    }
  }

  @override
  Map<String, dynamic> toJson() => _$SettingsDataToJson(this);

  Future<void> load() async {
    log.info('Reading user preferences from storage');
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString(_kUserSettings);

      final SettingsData newData;
      if (jsonData == null) {
        log.info(
          'No saved user preferences are found, initializing with defaults',
        );
        newData = SettingsData();
      } else {
        newData = SettingsData.fromJson(json.decode(jsonData));
      }
      _themeMode = newData.themeMode;
      _dnd = newData.dnd;
      _dailyNotifier = newData.dailyNotifier;
      _dailyNotifierTime = newData.dailyNotifierTime;
      _autoPageTurn = newData.autoPageTurn;
      _prayerLength = newData.prayerLength;
      _prayerSoundEnabled = newData.prayerSoundEnabled;
      _voiceChoice = newData.voiceChoice;
      notifyListeners();
    } catch (e, s) {
      log.severe('Error reading user preferences: $e', e, s);
      rethrow;
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(toJson());
    await prefs.setString(_kUserSettings, jsonString);
    log.info('User preferences are saved to storage');
  }
}

class TimeOfDayConverter implements JsonConverter<TimeOfDay, String> {
  const TimeOfDayConverter();

  @override
  TimeOfDay fromJson(String json) {
    final [hour, minute] = json.split(':').map(int.parse).toList();
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  String toJson(TimeOfDay object) => [object.hour, object.minute]
      .map((n) => n.toString().padLeft(2, '0'))
      .join(':');
}
