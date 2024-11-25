import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data_handlers/data_manager.dart';
import '../data_descriptors/prayer.dart';
import 'prayer_page.dart';


class PrayerSettingsPage extends StatefulWidget {
  final Prayer prayer;
  final DataManager dataManager;

  const PrayerSettingsPage({Key? key, required this.prayer, required this.dataManager})
      : super(key: key);

  @override
  _PrayerSettingsPageState createState() => _PrayerSettingsPageState();
}

class _PrayerSettingsPageState extends State<PrayerSettingsPage> {
  late SharedPreferences preferences;
  bool soundEnabled = true;
  String selectedVoice = "Female";
  int prayerLength = 5;


  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    preferences = await SharedPreferences.getInstance();

    setState(() {
      soundEnabled = preferences.getBool('soundEnabled') ?? true;
      selectedVoice = preferences.getString('selectedVoice') ?? "Female";
      prayerLength =
          preferences.getInt('prayerLength') ?? widget.prayer.minTimeInMinutes;
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
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Prayer _currentPrayer = widget.prayer;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPrayer.title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (_currentPrayer.title == "Ignaci szemlelodes")
            ListTile(
              title: Text("Select Voice"),
              subtitle: Text(selectedVoice),
              trailing: DropdownButton<String>(
                value: selectedVoice,
                onChanged: (newValue) {
                  if (newValue != null) {
                    _updatePreference('selectedVoice', newValue);
                  }
                },
                items: ["ferfi","noi"]
                    .map((voice) => DropdownMenuItem(
                          value: voice,
                          child: Text(voice),
                        ))
                    .toList(),
              ),
            ),
          if (_currentPrayer.title == "Sziv imaja")
            SwitchListTile(
              title: Text("Enable Sound"),
              value: soundEnabled,
              onChanged: (newValue) {
                _updatePreference('soundEnabled', newValue);
              },
            )
          else
            ListTile(
              title: Text("Enable Sound"),
              subtitle: Text("Disabled for this prayer"),
              trailing: Switch(value: false, onChanged: null),
            ),
          ListTile(
            title: Text("Prayer Length"),
            subtitle: Text("$prayerLength minutes"),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    int tempLength = prayerLength;
                    return AlertDialog(
                      title: Text("Set Prayer Length"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Slider(
                            value: tempLength.toDouble(),
                            min: _currentPrayer.minTimeInMinutes.toDouble(),
                            max: 60,
                            divisions: 60 - _currentPrayer.minTimeInMinutes,
                            label: "$tempLength minutes",
                            onChanged: (value) {
                              setState(() {
                                tempLength = value.toInt();
                              });
                            },
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            _updatePreference('prayerLength', tempLength);
                            Navigator.pop(context);
                          },
                          child: Text("Save"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrayerPage(prayer: _currentPrayer, dataManager: widget.dataManager),
                ),
              );
            },
            child: Text("Start Prayer"),
          ),
        ],
      ),
    );
  }
}