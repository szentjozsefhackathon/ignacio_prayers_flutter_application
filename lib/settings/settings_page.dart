import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:do_not_disturb/do_not_disturb.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../alarm_service/screens/edit_alarm.dart';
import '../alarm_service/screens/ring.dart';
import '../alarm_service/services/permission.dart';
import '../alarm_service/widgets/tile.dart';
import '../data/settings_data.dart';
import 'impressum_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static final log = Logger('Settings');

  List<AlarmSettings> _alarms = [];

  late final StreamSubscription<AlarmSettings> _ringSubscription;
  late final StreamSubscription<int> _updateSubscription;

  final _dndPlugin = DoNotDisturbPlugin();
  bool? _notifPolicyAccess;

  @override
  void initState() {
    super.initState();
    AlarmPermissions.checkNotificationPermission();
    if (Alarm.android) {
      AlarmPermissions.checkAndroidScheduleExactAlarmPermission();
    }
    _ringSubscription = Alarm.ringStream.stream
        .asBroadcastStream()
        .listen(navigateToRingScreen);
    _updateSubscription = Alarm.updateStream.stream
        .asBroadcastStream()
        .listen((_) => unawaited(_loadAlarms()));
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAlarms());
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsData>();

    return Scaffold(
      appBar: AppBar(title: const Text('Beállítások')),
      body: ListView(
        children: [
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
              title: Text(mode.name),
              value: mode,
              groupValue: settings.themeMode,
              onChanged: (v) {
                if (v != null) {
                  settings.themeMode = v;
                }
              },
            ),
          ),
          SwitchListTile(
            title: const Text('Napi emlékeztető'),
            value: settings.dailyNotifier,
            onChanged: (v) => settings.dailyNotifier = v,
          ),
          ListTile(
            title: const Text('Emlékeztető ideje'),
            subtitle: Text(settings.dailyNotifierTime.format(context)),
            enabled: settings.dailyNotifier,
            onTap: () => navigateToAlarmScreen(null),
          ),
          if (_alarms.isNotEmpty)
            SafeArea(
              child: Column(
                children: _alarms
                    .map(
                      (a) => ExampleAlarmTile(
                        key: Key(a.id.toString()),
                        title: TimeOfDay(
                          hour: a.dateTime.hour,
                          minute: a.dateTime.minute,
                        ).format(context),
                        onPressed: () => navigateToAlarmScreen(a),
                        onDismissed: () async {
                          await Alarm.stop(a.id);
                          await _loadAlarms();
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ListTile(
            title: const Text('Impresszum'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ImpressumPage()),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadAlarms() async {
    final updatedAlarms = await Alarm.getAlarms();
    updatedAlarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    setState(() => _alarms = updatedAlarms);
  }

  Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ExampleAlarmRingScreen(
          alarmSettings: alarmSettings,
        ),
      ),
    );
    unawaited(_loadAlarms());
  }

  Future<void> navigateToAlarmScreen(AlarmSettings? settings) async {
    final res = await showModalBottomSheet<bool?>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.85,
        child: ExampleAlarmEditScreen(alarmSettings: settings),
      ),
    );

    if (res != null && res == true) unawaited(_loadAlarms());
  }

  @override
  void dispose() {
    _ringSubscription.cancel();
    _updateSubscription.cancel();
    super.dispose();
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
