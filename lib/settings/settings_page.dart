import 'package:flutter/material.dart';
import '../data_descriptors/user_settings_data.dart';
import 'switch_card.dart';
import 'enum_card.dart';

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

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text("Settings"),
  //     ),
  //     body: ListView(
  //       children: [
  //         ListTile(
  //           title: Text("Dark Mode"),
  //           subtitle: Text(_darkMode),
  //           trailing: DropdownButton<String>(
  //             value: _darkMode,
  //             onChanged: (newValue) {
  //               if (newValue != null) {
  //                 _savePreferences(newValue);
  //               }
  //             },
  //             items: _darkModeOptions.map((option) {
  //               return DropdownMenuItem(
  //                 value: option,
  //                 child: Text(option),
  //               );
  //             }).toList(),
  //           ),
  //         ),
  //         SwitchListTile(
  //           title: Text("Do Not Disturb"),
  //           value: dndEnabled,
  //           onChanged: (newValue) {
  //             _updatePreference(DND_KEY, newValue);
  //           },
  //         ),
  //         SwitchListTile(
  //           title: Text("Daily Notifier"),
  //           value: dailyNotifier,
  //           onChanged: (newValue) {
  //             _updatePreference(DAILY_NOTIFIER_KEY, newValue);
  //           },
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(builder: (context) => ImpressumPage()),
  //             );
  //           },
  //           child: Text("Impressum"),
  //         ),
  //       ],
  //     ),
  //   );
  // }
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

  void _themeModeChanged(ThemeMode? value) {
    widget.userSettings.themeMode = value!;
    widget.setUserSettings(widget.userSettings);
  }

  // void _languageChanged(bool? value) {
  //   widget.userSettings.themeMode = value!;
  //   widget.setUserSettings(widget.userSettings);
  // }

  void _handleSwitchChanged(String key) {
    setState(() {
      widget.userSettings.dnd = !widget.userSettings.dnd;
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
                maxCrossAxisExtent: 350,
                mainAxisSpacing: 4,
                mainAxisExtent: 200,
                crossAxisSpacing: 4,
              ),
              children: <Widget>[
                SwitchCard<String>(
                  title: 'Settings',
                  values: _switchStates,
                  onChanged: _handleSwitchChanged,
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
                    onTap: () async {
                      final TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime ?? TimeOfDay(hour: widget.userSettings.dailyNotifierHour, minute: widget.userSettings.dailyNotifierMinute),
                        initialEntryMode: entryMode,
                      );
                      setState(() {
                        selectedTime = time;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}