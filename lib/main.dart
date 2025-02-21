import 'dart:io' show Platform;
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'theme/theme.dart'; // Import the colors file
import 'data/settings_data.dart';
import 'routes.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });


  if (Platform.isAndroid || Platform.isIOS) {
    // Android-specific code
    await Alarm.init();
  }


  runApp(const IgnacioPrayersApp());
}

class IgnacioPrayersApp extends StatelessWidget {
  const IgnacioPrayersApp({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => SettingsData()..load(),
        builder: (context, widget) {
          final settings = context.watch<SettingsData>();
          return MaterialApp(
            title: 'Ignáci imák',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            initialRoute: Routes.home,
            routes: Routes.routingTable,
          );
        },
      );
}
