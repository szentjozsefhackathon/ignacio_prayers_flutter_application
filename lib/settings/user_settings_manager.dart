import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constants.dart';
import '../data_descriptors/user_settings_data.dart';

//TODO: change to a provider class

class UserSettingsManager {
  final log = Logger('UserSettingsManager');
  // Future<UserSettingsData>? _userSettingsData; // Backing field for caching

  // Save user settings
  Future<void> saveSaveSettings(UserSettingsData userSettingsData) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(userSettingsData.toJson());
    await prefs.setString(kUserSettings, jsonString);
    log.info('User preferences are saved to storage');
  }

  Future<UserSettingsData> loadUserSettings() async {
    log.info('Reading user preferences from storage');
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString(kUserSettings);

      if (jsonData == null) {
        log.info(
          'No saved user preferences are found, initializing with defaults',
        );
        return UserSettingsData.withDefaults();
      }
      return UserSettingsData.fromJson(json.decode(jsonData));
    } catch (e, stackTrace) {
      log.severe('Error reading user preferences: $e', e, stackTrace);
      rethrow; // Propagate the exception to the caller
    }
  }
}
