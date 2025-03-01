import 'dart:async';

import 'package:do_not_disturb/do_not_disturb.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../data/settings_data.dart';
import '../notifications.dart';
import '../routes.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static final log = Logger('Settings');

  final _dndPlugin = DoNotDisturbPlugin();
  bool? _notifPolicyAccess;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsData>();

    return Scaffold(
      appBar: AppBar(title: const Text('Beállítások')),
      body: ListView(
        children: [
          if (!kIsWeb)
            SwitchListTile(
              title: const Text('Ne zavarjanak'),
              subtitle: const Text(
                'Értesítések és egyéb hangok némítása az ima alatt',
              ),
              value: settings.dnd,
              onChanged: (v) async {
                if (v && _notifPolicyAccess != true) {
                  _checkNotificationPolicyAccessGranted();
                  // TODO: update state when user returns from system settings
                  if (_notifPolicyAccess == null) {
                    return;
                  }
                }
                settings.dnd = v;
              },
            ),
          if (settings.dnd)
            ListTile(
              title: const Text('Ne zavarjanak további beállításai'),
              trailing: const Icon(Icons.open_in_new_rounded),
              onTap: () => _dndPlugin.openDndSettings(),
            ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text('Téma'),
          ),
          ...ThemeMode.values.map(
            (mode) => RadioListTile(
              title: Text(
                switch (mode) {
                  ThemeMode.system => 'rendszer',
                  ThemeMode.light => 'világos',
                  ThemeMode.dark => 'sötét',
                },
              ),
              value: mode,
              groupValue: settings.themeMode,
              onChanged: (v) {
                if (v != null) {
                  settings.themeMode = v;
                }
              },
            ),
          ),
          if (!kIsWeb)
            SwitchListTile(
              title: const Text('Napi emlékeztetők'),
              value: settings.dailyNotifier,
              onChanged: (v) {
                settings.dailyNotifier = v;
                if (!v) {
                  context.read<Notifications>().cancelAll();
                }
              },
            ),
          if (!kIsWeb)
            ListTile(
              title: const Text('Emlékeztető hozzáadása'),
              leading: const Icon(Icons.add_rounded),
              // TODO: do we need dailyNotifierTime (we have alarms)?
              //subtitle: Text(settings.dailyNotifierTime.format(context)),
              enabled: settings.dailyNotifier,
              onTap: () async {
                final now = TZDateTime.now(local);
                final timeOfDay = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(now),
                );
                if (context.mounted && timeOfDay != null) {
                  context.read<Notifications>().scheduleNotificationAt(
                        dateTime: TZDateTime.local(
                          now.year,
                          now.month,
                          now.day,
                          timeOfDay.hour,
                          timeOfDay.minute,
                        ),
                        // TODO: other options
                        repeat: DateTimeComponents.time,
                      );
                }
              },
            ),
          if (!kIsWeb) const PendingNotificationTiles(),
          if (!kIsWeb)
            ListTile(
              title: const Text('Adatok kezelése'),
              onTap: () => Navigator.pushNamed(context, Routes.dataSync),
            ),
          ListTile(
            title: const Text('Impresszum'),
            onTap: () => Navigator.pushNamed(context, Routes.impressum),
          ),
        ],
      ),
    );
  }

  Future<void> _checkNotificationPolicyAccessGranted() async {
    try {
      if (await _dndPlugin.isNotificationPolicyAccessGranted()) {
        if (mounted) {
          setState(() => _notifPolicyAccess = true);
        }
      } else {
        await _dndPlugin.openNotificationPolicyAccessSettings();
        if (mounted) {
          setState(() => _notifPolicyAccess = false);
        }
      }
    } catch (e, s) {
      log.severe('Failed to check notification policy access', e, s);
    }
  }
}
