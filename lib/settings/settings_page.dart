import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/constants.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'impressum.dart';
import 'package:ignacio_prayers_flutter_application/layout_templates/theme_provider.dart';


class SettingsPage extends StatefulWidget {
  @override  
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SharedPreferences preferences;
  var themeMode = ThemeMode.system;
  bool dndEnabled = true;
  bool dailyNotifier = true;

  void setThemeMode(ThemeMode mode) {
    setState(() {
      _updatePreference(THEME_MODE_SWITCH_KEY,mode);
      themeMode = mode;
    });
  }


  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      themeMode = EnumToString.fromString(ThemeMode.values, preferences.getString(THEME_MODE_SWITCH_KEY) ?? "system") ?? ThemeMode.system;
      dndEnabled = preferences.getBool(DND_KEY) ?? true;
      dailyNotifier = preferences.getBool(DAILY_NOTIFIER_KEY) ?? true;
    });
  }

  Future<void> _updatePreference(String key, dynamic value) async {
    switch (value.runtimeType) {
      case bool:
        await preferences.setBool(key, value);
        break;
      case String:
        await preferences.setString(key, value);
        break;
      case int:
        await preferences.setInt(key, value);
        break;
      case ThemeMode:
        await preferences.setString(key, EnumToString.convertToString(value));
        break;
    }
    
    setState(() {
      switch (key) {
        case THEME_MODE_SWITCH_KEY:
          themeMode = value;
          break;
        case DND_KEY:
          dndEnabled = value;
          break;
        case DAILY_NOTIFIER_KEY:
          dailyNotifier = value;
          break;
      }
    });
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
        body: TimePickerOptions(
          themeMode: themeMode,
          setThemeMode: setThemeMode,
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


class TimePickerOptions extends StatefulWidget {
  const TimePickerOptions({
    super.key,
    required this.themeMode,
    required this.setThemeMode,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> setThemeMode;

  @override
  State<TimePickerOptions> createState() => _TimePickerOptionsState();
}

class _TimePickerOptionsState extends State<TimePickerOptions> {
  TimeOfDay? selectedTime;
  TimePickerEntryMode entryMode = TimePickerEntryMode.dial;
  Orientation? orientation;
  TextDirection textDirection = TextDirection.ltr;
  MaterialTapTargetSize tapTargetSize = MaterialTapTargetSize.padded;
  bool use24HourTime = false;

  void _entryModeChanged(TimePickerEntryMode? value) {
    if (value != entryMode) {
      setState(() {
        entryMode = value!;
      });
    }
  }

  void _orientationChanged(Orientation? value) {
    if (value != orientation) {
      setState(() {
        orientation = value;
      });
    }
  }

  void _textDirectionChanged(TextDirection? value) {
    if (value != textDirection) {
      setState(() {
        textDirection = value!;
      });
    }
  }

  void _tapTargetSizeChanged(MaterialTapTargetSize? value) {
    if (value != tapTargetSize) {
      setState(() {
        tapTargetSize = value!;
      });
    }
  }

  void _use24HourTimeChanged(bool? value) {
    if (value != use24HourTime) {
      setState(() {
        use24HourTime = value!;
      });
    }
  }

  void _themeModeChanged(ThemeMode? value) {
    widget.setThemeMode(value!);
  }

  @override
  Widget build(BuildContext context) {
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
                EnumCard<TimePickerEntryMode>(
                  choices: TimePickerEntryMode.values,
                  value: entryMode,
                  onChanged: _entryModeChanged,
                ),
                EnumCard<ThemeMode>(
                  choices: ThemeMode.values,
                  value: widget.themeMode,
                  onChanged: _themeModeChanged,
                ),
                EnumCard<TextDirection>(
                  choices: TextDirection.values,
                  value: textDirection,
                  onChanged: _textDirectionChanged,
                ),
                EnumCard<MaterialTapTargetSize>(
                  choices: MaterialTapTargetSize.values,
                  value: tapTargetSize,
                  onChanged: _tapTargetSizeChanged,
                ),
                ChoiceCard<Orientation?>(
                  choices: const <Orientation?>[...Orientation.values, null],
                  value: orientation,
                  title: '$Orientation',
                  choiceLabels: <Orientation?, String>{
                    for (final Orientation choice in Orientation.values)
                      choice: choice.name,
                    null: 'from MediaQuery',
                  },
                  onChanged: _orientationChanged,
                ),
                ChoiceCard<bool>(
                  choices: const <bool>[false, true],
                  value: use24HourTime,
                  onChanged: _use24HourTimeChanged,
                  title: 'Time Mode',
                  choiceLabels: const <bool, String>{
                    false: '12-hour am/pm time',
                    true: '24-hour time',
                  },
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton(
                    child: const Text('Open time picker'),
                    onPressed: () async {
                      final TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime ?? TimeOfDay.now(),
                        initialEntryMode: entryMode,
                        orientation: orientation,
                        builder: (BuildContext context, Widget? child) {
                          // We just wrap these environmental changes around the
                          // child in this builder so that we can apply the
                          // options selected above. In regular usage, this is
                          // rarely necessary, because the default values are
                          // usually used as-is.
                          return Theme(
                            data: Theme.of(context).copyWith(
                              materialTapTargetSize: tapTargetSize,
                            ),
                            child: Directionality(
                              textDirection: textDirection,
                              child: MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                  alwaysUse24HourFormat: use24HourTime,
                                ),
                                child: child!,
                              ),
                            ),
                          );
                        },
                      );
                      setState(() {
                        selectedTime = time;
                      });
                    },
                  ),
                ),
                if (selectedTime != null)
                  Text('Selected time: ${selectedTime!.format(context)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// This is a simple card that presents a set of radio buttons (inside of a
// RadioSelection, defined below) for the user to select from.
class ChoiceCard<T extends Object?> extends StatelessWidget {
  const ChoiceCard({
    super.key,
    required this.value,
    required this.choices,
    required this.onChanged,
    required this.choiceLabels,
    required this.title,
  });

  final T value;
  final Iterable<T> choices;
  final Map<T, String> choiceLabels;
  final String title;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      // If the card gets too small, let it scroll both directions.
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(title),
                ),
                for (final T choice in choices)
                  RadioSelection<T>(
                    value: choice,
                    groupValue: value,
                    onChanged: onChanged,
                    child: Text(choiceLabels[choice]!),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// This aggregates a ChoiceCard so that it presents a set of radio buttons for
// the allowed enum values for the user to select from.
class EnumCard<T extends Enum> extends StatelessWidget {
  const EnumCard({
    super.key,
    required this.value,
    required this.choices,
    required this.onChanged,
  });

  final T value;
  final Iterable<T> choices;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ChoiceCard<T>(
        value: value,
        choices: choices,
        onChanged: onChanged,
        choiceLabels: <T, String>{
          for (final T choice in choices) choice: choice.name,
        },
        title: value.runtimeType.toString());
  }
}

// A button that has a radio button on one side and a label child. Tapping on
// the label or the radio button selects the item.
class RadioSelection<T extends Object?> extends StatefulWidget {
  const RadioSelection({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.child,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T?> onChanged;
  final Widget child;

  @override
  State<RadioSelection<T>> createState() => _RadioSelectionState<T>();
}

class _RadioSelectionState<T extends Object?> extends State<RadioSelection<T>> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 8),
          child: Radio<T>(
            groupValue: widget.groupValue,
            value: widget.value,
            onChanged: widget.onChanged,
          ),
        ),
        GestureDetector(
            onTap: () => widget.onChanged(widget.value), child: widget.child),
      ],
    );
  }
}