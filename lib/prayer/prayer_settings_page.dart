import 'package:flutter/material.dart';
import '../data_handlers/data_manager.dart';
import '../data_descriptors/prayer.dart';
import 'prayer_page.dart';
import '../data_descriptors/user_settings_data.dart';
import '../settings/user_settings_manager.dart';


class PrayerSettingsPage extends StatefulWidget {
  final Prayer prayer;
  final DataManager dataManager;

  const PrayerSettingsPage({
    Key? key, 
    required this.prayer, 
    required this.dataManager
    }): super(key: key);

  @override
  _PrayerSettingsPageState createState() => _PrayerSettingsPageState();
}

class _PrayerSettingsPageState extends State<PrayerSettingsPage> {
  // Add any state variables you need to update
  final userSettingsManager = UserSettingsManager();
  UserSettingsData _userSettingsData = UserSettingsData.withDefaults();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final UserSettingsData userSettingsData = await userSettingsManager.loadUserSettings();
    setState(() {
      _userSettingsData = userSettingsData;
    });
  }

  void _updateUserSettings(UserSettingsData userSettingsData) {
    Future.microtask((){
      setState(() {
        _userSettingsData = userSettingsData;
      });
      userSettingsManager.saveSaveSettings(userSettingsData);
    });
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
          SwitchListTile(
            title: Text("Automatic Page Turn"),
            value: _userSettingsData.autoPageTurn,
            onChanged: (newValue) {
              _userSettingsData.autoPageTurn = newValue;
              _updateUserSettings(_userSettingsData);
            },
          ),
          SwitchListTile(
            title: Text("Do Not Disturb"),
            value: _userSettingsData.dnd,
            onChanged: (newValue) {
              _userSettingsData.dnd = newValue;
              _updateUserSettings(_userSettingsData);
            },
          ),
          if (_currentPrayer.voiceOptions != [])
            ListTile(
              title: Text("Select Voice"),
              subtitle: Text("Női"),
              trailing: DropdownButton<String>(
                value: "Női",
                onChanged: (newValue) {
                  if (newValue != null) {
                    _userSettingsData.voiceChoice = newValue;
                    _updateUserSettings(_userSettingsData);
                  }
                },
                items: _currentPrayer.voiceOptions
                    .map((voice) => DropdownMenuItem(
                          value: voice,
                          child: Text(voice),
                        ))
                    .toList(),
              ),
            ),
          if (_currentPrayer.voiceOptions != [])
            SwitchListTile(
              title: Text("Enable Sound"),
              value: _userSettingsData.prayerSoundEnabled,
              onChanged: (newValue) {
                _userSettingsData.prayerSoundEnabled = newValue;
                _updateUserSettings(_userSettingsData);
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
            subtitle: Text("${_userSettingsData.prayerLength} minutes"),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    int tempLength = _userSettingsData.prayerLength;
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
                            _userSettingsData.prayerLength = tempLength;
                            _updateUserSettings(_userSettingsData);
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
              Navigator.pushNamed(context, '/settings');
            },
            child: Text("More settings"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrayerPage(prayer: _currentPrayer, userSettingsData: _userSettingsData, dataManager: widget.dataManager),
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