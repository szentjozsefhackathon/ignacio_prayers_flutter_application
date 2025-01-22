import 'settings/impressum_page.dart';
import 'settings/settings_page.dart';

class Routes {
  Routes._();

  static const settings = '/settings';
  static const impressum = '$settings/impressum';

  static final routingTable = {
    settings: (context) => const SettingsPage(),
    impressum: (context) => const ImpressumPage(),
  };
}
