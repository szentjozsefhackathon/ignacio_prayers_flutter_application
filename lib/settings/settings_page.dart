import 'dart:async';
import 'package:flutter/material.dart';
import '../data_descriptors/user_settings_data.dart';
import 'package:do_not_disturb/do_not_disturb.dart';
import 'package:alarm/alarm.dart';

import 'impressum_page.dart';
import 'switch_card.dart';
import 'enum_card.dart';

import '../alarm_service/screens/edit_alarm.dart';
import '../alarm_service/screens/ring.dart';
import '../alarm_service/screens/shortcut_button.dart';
import '../alarm_service/services/permission.dart';
import '../alarm_service/widgets/tile.dart';

class SettingsPage extends StatefulWidget {
  final UserSettingsData userSettings;
  final ValueChanged<UserSettingsData> updateUserSettings;

  const SettingsPage({
    Key? key,
    required this.userSettings,
    required this.updateUserSettings
  }) : super(key: key);

  @override  
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool dndEnabled = true;
  bool dailyNotifier = true;

  final _dndPlugin = DoNotDisturbPlugin();

  void setUserSettings(UserSettingsData userSettings) {
    setState(() {
      widget.updateUserSettings(userSettings);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
        ),
        ),
        body: SettingsOptions(
          userSettings: widget.userSettings,
          setUserSettings: setUserSettings,
        ),
    );
  }
}


class SettingsOptions extends StatefulWidget {
  const SettingsOptions({
    super.key,
    required this.userSettings,
    required this.setUserSettings,
  });

  final UserSettingsData userSettings;
  final ValueChanged<UserSettingsData> setUserSettings;

  @override
  State<SettingsOptions> createState() => _SettingsOptionsState();
}

class _SettingsOptionsState extends State<SettingsOptions> {
  TimeOfDay? selectedTime;
  TimePickerEntryMode entryMode = TimePickerEntryMode.dial;
  Orientation? orientation;
  TextDirection textDirection = TextDirection.ltr;
  MaterialTapTargetSize tapTargetSize = MaterialTapTargetSize.padded;
  bool use24HourTime = true;

  // -----------------------------------------------------------

  List<AlarmSettings> alarms = [];

  static StreamSubscription<AlarmSettings>? ringSubscription;
  static StreamSubscription<int>? updateSubscription;
  
  @override
  void initState() {
    super.initState();
    AlarmPermissions.checkNotificationPermission();
    if (Alarm.android) {
      AlarmPermissions.checkAndroidScheduleExactAlarmPermission();
    }
    unawaited(loadAlarms());
    ringSubscription ??= Alarm.ringStream.stream.listen(navigateToRingScreen);
    updateSubscription ??= Alarm.updateStream.stream.listen((_) {
      unawaited(loadAlarms());
    });
  }

  Future<void> loadAlarms() async {
    final updatedAlarms = await Alarm.getAlarms();
    updatedAlarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    setState(() {
      alarms = updatedAlarms;
    });
  }
  

  Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) =>
            ExampleAlarmRingScreen(alarmSettings: alarmSettings),
      ),
    );
    unawaited(loadAlarms());
  }

  Future<void> navigateToAlarmScreen(AlarmSettings? settings) async {
    final res = await showModalBottomSheet<bool?>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: ExampleAlarmEditScreen(alarmSettings: settings),
        );
      },
    );

    if (res != null && res == true) unawaited(loadAlarms());
  }

  @override
  void dispose() {
    ringSubscription?.cancel();
    updateSubscription?.cancel();
    super.dispose();
  }



  // -----------------------------------------------------------

  void _themeModeChanged(ThemeMode? value) {
    widget.userSettings.themeMode = value!;
    widget.setUserSettings(widget.userSettings);
  }

  // void _languageChanged(bool? value) {
  //   widget.userSettings.themeMode = value!;
  //   widget.setUserSettings(widget.userSettings);
  // }

  void _dndStateChanged(String key) {
    setState(() {
      widget.userSettings.dnd = !widget.userSettings.dnd;
      // Set DND mode (requires permission)
      // if (await _dndPlugin.isNotificationPolicyAccessGranted()) {
      //   await _dndPlugin.setInterruptionFilter(InterruptionFilter.none);
      // } else {
      //   // Guide user to grant permission
      //   await _dndPlugin.openNotificationPolicyAccessSettings();
      //   // Inform user to grant permission and return to the app
      // }
      if (_isDndEnabled) {
        _dndPlugin.setInterruptionFilter(InterruptionFilter.all);
      } else {
        _dndPlugin.setInterruptionFilter(InterruptionFilter.none);
      }
      _isDndEnabled = !_isDndEnabled;
      // TODO: add this persmission as well
      // _dndPlugin.openNotificationPolicyAccessSettings();
      // _dndPlugin.openDndSettings();
      // if (widget.userSettings.dnd) {
      //     _setInterruptionFilter(InterruptionFilter.all);
      //   } else {
      //     _setInterruptionFilter(InterruptionFilter.alarms);
      //   }
      widget.setUserSettings(widget.userSettings);
    });
  }

  @override
  Widget build(BuildContext context) {

    final Map<String, bool> _switchStates = {
      'DND': widget.userSettings.dnd,
    };

    selectedTime = TimeOfDay(hour: widget.userSettings.dailyNotifierHour, minute: widget.userSettings.dailyNotifierMinute);

    return Material(
      child: Column(
        children: <Widget>[
          Expanded(
            child: GridView(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 600,
                mainAxisSpacing: 4,
                mainAxisExtent: 200,
                crossAxisSpacing: 4,
              ),
              children: <Widget>[
                SwitchCard<String>( //TODO: change to EnumCard because of the new way of handling do not disturb
                  title: 'Settings',
                  values: _switchStates,
                  onChanged: _dndStateChanged,
                  switchLabels: {
                    'DND': 'Do Not Disturb',
                  },
                ),
                EnumCard<ThemeMode>(
                  choices: ThemeMode.values,
                  value: widget.userSettings.themeMode,
                  onChanged: _themeModeChanged,
                ),
                Card(
                  child: InkWell(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Switch(
                          value: widget.userSettings.dailyNotifier,
                          onChanged: (bool newValue) => widget.userSettings.dailyNotifier = !widget.userSettings.dailyNotifier,
                        ),
                        Text('Selected time: ${selectedTime!.format(context)}'),
                      ],
                    ),
                    // onTap: () async {
                    //   final TimeOfDay? time = await showTimePicker(
                    //     context: context,
                    //     initialTime: selectedTime ?? TimeOfDay(hour: widget.userSettings.dailyNotifierHour, minute: widget.userSettings.dailyNotifierMinute),
                    //     initialEntryMode: entryMode,
                    //   );
                    //   setState(() {
                    //     selectedTime = time;
                    //   });
                    // },
                    onTap: () => navigateToAlarmScreen(null),
                  ),
                ),
                Card(
                  child: SafeArea(
                    child: alarms.isNotEmpty
                      ? ListView.separated(
                          itemCount: alarms.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            return ExampleAlarmTile(
                              key: Key(alarms[index].id.toString()),
                              title: TimeOfDay(
                                hour: alarms[index].dateTime.hour,
                                minute: alarms[index].dateTime.minute,
                              ).format(context),
                              onPressed: () => navigateToAlarmScreen(alarms[index]),
                              onDismissed: () {
                                Alarm.stop(alarms[index].id).then((_) => loadAlarms());
                              },
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            'No alarms set',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                  ),
                ),
                Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ImpressumPage()),
                      );
                    },
                    child: Center(
                      child: Text("Impressum"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



final _dndPlugin = DoNotDisturbPlugin();

bool _isDndEnabled = false;
bool _notifPolicyAccess = false;
InterruptionFilter _dndStatus = InterruptionFilter.unknown;


Future<void> _checkNotificationPolicyAccessGranted() async {
    try {
      final bool isNotificationPolicyAccessGranted =
          await _dndPlugin.isNotificationPolicyAccessGranted();
      setState(() {
        _notifPolicyAccess = isNotificationPolicyAccessGranted;
      });
    } catch (e) {
      print('Error checking notification policy access: $e');
    }
  }

  Future<void> _checkDndEnabled() async {
    try {
      final bool isDndEnabled = await _dndPlugin.isDndEnabled();
      setState(() {
        _isDndEnabled = isDndEnabled;
      });
    } catch (e) {
      print('Error checking DND status: $e');
    }
  }

  Future<void> _getDndStatus() async {
    try {
      final InterruptionFilter status = await _dndPlugin.getDNDStatus();
      setState(() {
        _dndStatus = status;
      });
    } catch (e) {
      print('Error getting DND status: $e');
    }
  }

  Future<void> _openDndSettings() async {
    try {
      await _dndPlugin.openDndSettings();
    } catch (e) {
      print('Error opening DND settings: $e');
    }
  }

  Future<void> _openNotificationPolicyAccessSettings() async {
    try {
      await _dndPlugin.openNotificationPolicyAccessSettings();
    } catch (e) {
      print('Error opening notification policy access settings: $e');
    }
  }

  Future<void> _setInterruptionFilter(InterruptionFilter filter) async {
    try {
      await _dndPlugin.setInterruptionFilter(filter);
      _checkDndEnabled();
      _getDndStatus();
    } catch (e) {
      print('Error setting interruption filter: $e');
    }
  }
}