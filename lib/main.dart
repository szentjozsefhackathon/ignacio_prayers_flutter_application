import 'package:flutter/material.dart';
import 'data_handlers/data_manager.dart';
import 'menu/prayer_groups_page.dart';

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
  // After the data is saved reload frontend TODO: implement this
  dataManager.checkForUpdates();
}
class MyApp extends StatelessWidget {
  final DataManager dataManager;

  const MyApp({Key? key, required this.dataManager}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: PayerGroupsPage(title: 'Flutter DEMO',dataManager: dataManager),
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan.shade900),
        useMaterial3: true,
      ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}