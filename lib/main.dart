import 'package:flutter/material.dart';
import 'data_handlers/data_manager.dart';
import 'menu/prayer_groups_page.dart';
import 'settings/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create a new instance of DataManager
  // By creating the instance data will be loaded from shared preferences
  // if the data is not found in shared preferences the data will be downloaded from the server 
  // (this should be applied only downloading thew app and first startup)
  final dataManager = DataManager();

  // if we have valid data we can start the app
  runApp(MyApp(dataManager: dataManager));

  // Check for updates in the background
  // If there are updates the data will be downloaded and saved to shared preferences
  // After the data is saved reload frontend TODO: implement this - Stateful widget
  // TODO: check internet availability if not, check valid data in shared preferences if not ask for internet connection
  dataManager.checkForUpdates();

  // TODO: multiple languages
  // final String defaultLocale = Platform.localeName;
}
class MyApp extends StatelessWidget {
  final DataManager dataManager;

  const MyApp({Key? key, required this.dataManager}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ignáci imák',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.light,
      home: PrayerGroupsPage(title: 'Ignáci imák', dataManager: dataManager),
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan.shade900),
      //   useMaterial3: true,
      // ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      routes: {
        '/settings': (context) => SettingsPage(),
      },
    );
  }
}