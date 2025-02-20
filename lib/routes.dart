import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'data/prayer.dart';
import 'data/prayer_group.dart';
import 'data_handlers/data_manager.dart';
import 'menu/prayer_groups_page.dart';
import 'menu/prayers_page.dart';
import 'prayer/prayer_description_page.dart';
import 'prayer/prayer_page.dart';
import 'prayer/prayer_settings_page.dart';
import 'settings/impressum_page.dart';
import 'settings/settings_page.dart';

class Routes {
  Routes._();

  static final _log = Logger('Routes');

  static const home = '/';

  static const prayersPrefix = '/p';
  static String prayers(PrayerGroup group) => '$prayersPrefix/${group.slug}';

  static const prayerDescriptionPrefix = '/d';
  static String prayerDescription(Prayer prayer) =>
      '$prayerDescriptionPrefix/${prayer.slug}';

  static const prayerSettingsPrefix = '/s';
  static String prayerSettings(Prayer prayer) =>
      '$prayerSettingsPrefix/${prayer.slug}';

  static const prayerPrefix = '/v';
  static String prayer(Prayer prayer) => '$prayerPrefix/${prayer.slug}';

  static const settings = '/settings';
  static const impressum = '$settings/impressum';

  static Route? onGenerateRoute(RouteSettings s) {
    if (s.name == null) {
      return null;
    }
    final uri = Uri.parse(s.name!);
    _log.info('onGenerateRoute: ${s.name}');
    return switch ('/${uri.pathSegments.firstOrNull ?? ''}') {
      home => MaterialPageRoute(
          settings: s,
          builder: (context) => const PrayerGroupsPage(),
        ),
      prayersPrefix => _generateArgRoute(
          settings: s,
          uri: uri,
          findBySlug: DataManager.instance.findPrayerGroup,
          builder: (context, group) => PrayersPage(group: group),
        ),
      prayerDescriptionPrefix => _generateArgRoute(
          settings: s,
          uri: uri,
          findBySlug: DataManager.instance.findPrayer,
          builder: (context, prayer) => PrayerDescriptionPage(prayer: prayer),
        ),
      prayerSettingsPrefix => _generateArgRoute(
          settings: s,
          uri: uri,
          findBySlug: DataManager.instance.findPrayer,
          builder: (context, prayer) => PrayerSettingsPage(prayer: prayer),
        ),
      prayerPrefix => _generateArgRoute(
          settings: s,
          uri: uri,
          findBySlug: DataManager.instance.findPrayer,
          builder: (context, prayer) => PrayerPage(prayer: prayer),
        ),
      settings => MaterialPageRoute(
          settings: s,
          builder: (context) => const SettingsPage(),
        ),
      impressum => MaterialPageRoute(
          settings: s,
          builder: (context) => const ImpressumPage(),
        ),
      _ => kIsWeb ? onUnknownRoute(s) : null,
    };
  }

  static Route onUnknownRoute(RouteSettings s) => MaterialPageRoute(
        settings: s,
        builder: (context) => _NotFoundPage(s.name),
      );

  static Route? _generateArgRoute<T>({
    required RouteSettings settings,
    required Uri uri,
    required Future<T?> Function(String slug) findBySlug,
    required Widget Function(BuildContext context, T prayer) builder,
  }) {
    if (uri.pathSegments.length != 2) {
      _log.warning(
        'generateArgRoute: length of path segments is not 2 but ${uri.pathSegments.length}',
      );
      return kIsWeb ? onUnknownRoute(settings) : null;
    }
    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        final arg = context.getRouteArgument<T>();
        if (arg != null) {
          return builder(context, arg);
        }
        final slug = uri.pathSegments.last;
        return FutureBuilder<T?>(
          future: findBySlug(slug),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text(snapshot.error.toString()),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            final data = snapshot.data;
            if (data == null) {
              return _NotFoundPage(uri.toString());
            }
            return builder(context, data);
          },
        );
      },
    );
  }
}

extension _RoutesExtension on BuildContext {
  T? getRouteArgument<T>() => ModalRoute.of(this)!.settings.arguments as T?;
}

extension _DataManagerExtension on DataManager {
  Future<PrayerGroup?> findPrayerGroup(String slug) => prayerGroups.data
      .then((g) => g.items.singleWhereOrNull((i) => i.slug == slug));

  Future<Prayer?> findPrayer(String slug) async {
    final groups = await prayerGroups.data;
    for (final group in groups) {
      final prayer = group.prayers.singleWhereOrNull((p) => p.slug == slug);
      if (prayer != null) {
        return prayer;
      }
    }
    return null;
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage(this.name);

  final String? name;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              if (name != null) Text(name!),
              const Text('Nincs ilyen oldal'),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  Routes.home,
                ),
                child: const Text('Kezdőoldal'),
              ),
            ],
          ),
        ),
      );
}
