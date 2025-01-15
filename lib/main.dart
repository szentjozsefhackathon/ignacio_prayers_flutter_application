import 'package:flutter/material.dart';
import 'menu/prayer_groups_page.dart';
import 'settings/settings_page.dart';
import 'settings/user_settings_manager.dart';
import 'data_descriptors/user_settings_data.dart';
import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';
import 'package:alarm/alarm.dart';
import 'constants/hungarian_language_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();

  runApp(const IgnacioPrayersApp());
}

class IgnacioPrayersApp extends StatefulWidget {
  const IgnacioPrayersApp({super.key});

  @override
  State<IgnacioPrayersApp> createState() => _IgnacioPrayersAppState();
}

class _IgnacioPrayersAppState extends State<IgnacioPrayersApp> {
  // Load user preferences
  final userSettingsManager = UserSettingsManager();


  // TODO: multiple languages
  // final String defaultLocale = Platform.localeName;

  // TODO: Permission handling

  // Add any state variables you need to update
  UserSettingsData _userSettingsData = UserSettingsData.withDefaults();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final UserSettingsData userSettingsData = await userSettingsManager.loadUserSettings();
    setState(() {
      _userSettingsData = userSettingsData;
    });
  }

  void _updateUserSettings(UserSettingsData userSettingsData) {
    Future.microtask((){
      setState(() {
        _userSettingsData = userSettingsData;
      });
      userSettingsManager.saveSaveSettings(userSettingsData);
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: TITLE,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _userSettingsData.themeMode,
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan.shade900),
      //   useMaterial3: true,
      // ),
      home: const PrayerGroupsPage(title: APP_BAR_TITLE),
      routes: {
        '/settings': (context) => SettingsPage(
          userSettings: _userSettingsData,
          updateUserSettings: _updateUserSettings
        ),
      },
    );
  }
}