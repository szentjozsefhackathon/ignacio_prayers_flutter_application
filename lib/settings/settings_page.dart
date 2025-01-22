import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:do_not_disturb/do_not_disturb.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../alarm_service/screens/edit_alarm.dart';
import '../alarm_service/screens/ring.dart';
import '../alarm_service/services/permission.dart';
import '../alarm_service/widgets/tile.dart';
import '../data/settings_data.dart';
import '../data_handlers/data_manager.dart';
import '../routes.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static final log = Logger('Settings');

  List<AlarmSettings> _alarms = [];

  static final _alarmRingStream = Alarm.ringStream.stream.asBroadcastStream();
  static final _alarmUpdateStream =
      Alarm.updateStream.stream.asBroadcastStream();

  late final StreamSubscription<AlarmSettings> _ringSubscription;
  late final StreamSubscription<int> _updateSubscription;

  final _dndPlugin = DoNotDisturbPlugin();
  bool? _notifPolicyAccess;
  bool _updatingData = false;

  @override
  void initState() {
    super.initState();
    AlarmPermissions.checkNotificationPermission();
    if (Alarm.android) {
      AlarmPermissions.checkAndroidScheduleExactAlarmPermission();
    }
    _ringSubscription = _alarmRingStream.listen(_navigateToRingScreen);
    _updateSubscription = _alarmUpdateStream.listen((_) => _loadAlarms());
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAlarms());
  }

  @override
  void dispose() {
    _ringSubscription.cancel();
    _updateSubscription.cancel();
    super.dispose();
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
            onChanged: (v) {
              settings.dailyNotifier = v;
              if (!v) {
                Alarm.stopAll();
              }
            },
          ),
          ListTile(
            title: const Text('Idő hozzáadása'),
            // TODO: do we need dailyNotifierTime (we have alarms)?
            //subtitle: Text(settings.dailyNotifierTime.format(context)),
            enabled: settings.dailyNotifier,
            onTap: () => _navigateToAlarmScreen(null),
          ),
          if (_alarms.isNotEmpty)
            SafeArea(
              child: Column(
                children: _alarms
                    .map(
                      (a) => AlarmTile(
                        key: Key(a.id.toString()),
                        title: TimeOfDay(
                          hour: a.dateTime.hour,
                          minute: a.dateTime.minute,
                        ).format(context),
                        onPressed: () => _navigateToAlarmScreen(a),
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
            onTap: () => Navigator.pushNamed(context, Routes.impressum),
          ),
          if (kDebugMode)
            ListTile(
              title: const Text('Adatok újra-letöltése'),
              enabled: !_updatingData,
              trailing: _updatingData
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                  : null,
              onTap: _updatingData
                  ? null
                  : () async {
                      setState(() => _updatingData = true);
                      await DataManager.instance.versions.deleteLocalData();
                      await DataManager.instance
                          .checkForUpdates(stopOnError: true);
                      if (mounted) {
                        setState(() => _updatingData = false);
                      }
                    },
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

  Future<void> _navigateToRingScreen(AlarmSettings alarmSettings) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => AlarmRingScreen(
          alarmSettings: alarmSettings,
        ),
      ),
    );
    unawaited(_loadAlarms());
  }

  Future<void> _navigateToAlarmScreen(AlarmSettings? settings) async {
    final res = await showModalBottomSheet<bool?>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.85,
        child: AlarmEditScreen(alarmSettings: settings),
      ),
    );

    if (res != null && res == true) unawaited(_loadAlarms());
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
