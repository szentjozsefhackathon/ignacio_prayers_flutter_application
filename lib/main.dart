import 'package:flutter/material.dart';
import 'data_handlers/data_manager.dart';
import 'menu/prayer_groups_page.dart';
import 'settings/settings_page.dart';
import 'settings/user_settings_manager.dart';
import '../data_descriptors/user_settings_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create a new instance of DataManager
  // By creating the instance data will be loaded from shared preferences
  // if the data is not found in shared preferences the data will be downloaded from the server 
  // (this should be applied only downloading thew app and first startup)
  final dataManager = DataManager();
  final userSettingsManager = UserSettingsManager();

  // if we have valid data we can start the app
  runApp(IgnacioPrayersApp(dataManager: dataManager, userSettingsManager: userSettingsManager));

  // Check for updates in the background
  // If there are updates the data will be downloaded and saved to shared preferences
  // After the data is saved reload frontend TODO: implement this - Stateful widget
  // TODO: check internet availability if not, check valid data in shared preferences if not ask for internet connection
  dataManager.checkForUpdates();

  // TODO: multiple languages
  // final String defaultLocale = Platform.localeName;
}

class IgnacioPrayersApp extends StatefulWidget {
  final DataManager dataManager;
  final UserSettingsManager userSettingsManager;
  const IgnacioPrayersApp({Key? key, required this.dataManager, required this.userSettingsManager}) : super(key: key);

  @override
  State<IgnacioPrayersApp> createState() => _IgnacioPrayersAppState();
}

class _IgnacioPrayersAppState extends State<IgnacioPrayersApp> {
  // Add any state variables you need to update
  UserSettingsData _userSettingsData = UserSettingsData.withDefaults();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final UserSettingsData userSettingsData = await widget.userSettingsManager.loadUserSettings();
    setState(() {
      _userSettingsData = userSettingsData;
    });
  }

  void _updateUserSettings(UserSettingsData userSettingsData) {
    Future.microtask((){
      setState(() {
        _userSettingsData = userSettingsData;
      });
      widget.userSettingsManager.saveSaveSettings(userSettingsData);
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Ignáci imák',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _userSettingsData.themeMode,
      home: PrayerGroupsPage(title: 'Ignáci imák', dataManager: widget.dataManager),
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan.shade900),
      //   useMaterial3: true,
      // ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      routes: {
        '/settings': (context) => SettingsPage(
          userSettings: _userSettingsData,
          updateUserSettings: _updateUserSettings
          // dataManager: widget.dataManager,
        ),
      },
    );
  }
}