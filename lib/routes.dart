import 'package:flutter/widgets.dart';

import 'data/prayer.dart';
import 'menu/prayer_groups_page.dart';
import 'menu/prayers_page.dart';
import 'prayer/prayer_description_page.dart';
import 'prayer/prayer_page.dart';
import 'prayer/prayer_settings_page.dart';
import 'settings/impressum_page.dart';
import 'settings/settings_page.dart';

class Routes {
  Routes._();

  static const home = '/';
  static const prayers = '/prayers';
  static const prayerDescription = '/prayer/description';
  static const prayerSettings = '/prayer/settings';
  static const prayer = '/prayer';
  static const settings = '/settings';
  static const impressum = '$settings/impressum';

  static final routingTable = <String, WidgetBuilder>{
    home: (context) => const PrayerGroupsPage(),
    prayers: (context) => const PrayersPage(),
    prayerDescription: (context) => const PrayerDescriptionPage(),
    prayerSettings: (context) => const PrayerSettingsPage(),
    prayer: (context) => PrayerPage(prayer: context.getRouteArgument<Prayer>()),
    settings: (context) => const SettingsPage(),
    impressum: (context) => const ImpressumPage(),
  };
}

extension RoutesExtension on BuildContext {
  T getRouteArgument<T>() => ModalRoute.of(this)!.settings.arguments as T;
}
