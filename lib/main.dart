import 'dart:io' show Platform;
import 'package:alarm/alarm.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'data/settings_data.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  timeago.setLocaleMessages('hu', _TimeagoHuMessages());
  timeago.setDefaultLocale('hu');

  if (kIsWeb) {
    usePathUrlStrategy();
  } else if (Platform.isAndroid || Platform.isIOS) {
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
            theme: ThemeData.light().copyWith(
              snackBarTheme: const SnackBarThemeData(
                behavior: SnackBarBehavior.floating,
              ),
            ),
            darkTheme: ThemeData.dark().copyWith(
              snackBarTheme: const SnackBarThemeData(
                behavior: SnackBarBehavior.floating,
              ),
            ),
            themeMode: settings.themeMode,
            initialRoute: Routes.home,
            onGenerateRoute: Routes.onGenerateRoute,
            onUnknownRoute: Routes.onUnknownRoute,
          );
        },
      );
}

class _TimeagoHuMessages extends timeago.HuMessages {
  @override
  String wordSeparator() => '';

  @override
  String prefixAgo() => '';

  @override
  String suffixFromNow() => '';

  @override
  String prefixFromNow() => '';
}
