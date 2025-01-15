import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../constants/hungarian_language_constants.dart';
import '../data_handlers/data_manager.dart';
import '../data_descriptors/prayer.dart';
import '../data_descriptors/user_settings_data.dart';
import '../settings/user_settings_manager.dart';

import 'prayer_page.dart';


class PrayerSettingsPage extends StatefulWidget {
  final Prayer prayer;
  final DataManager dataManager;

  const PrayerSettingsPage({
    super.key, 
    required this.prayer, 
    required this.dataManager
    });

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
    final Prayer currentPrayer = widget.prayer;

    // If there are no voice options, disable sound
    if (currentPrayer.voiceOptions.isEmpty) {
      _userSettingsData.prayerSoundEnabled = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(currentPrayer.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text(AUTO_PAGE_TURN),
            value: _userSettingsData.autoPageTurn,
            onChanged: (newValue) {
              _userSettingsData.autoPageTurn = newValue;
              _updateUserSettings(_userSettingsData);
            },
          ),
          if(!kIsWeb)
            SwitchListTile(
              title: const Text(DND_SETTINGS),
              value: _userSettingsData.dnd,
              onChanged: (newValue) {
                _userSettingsData.dnd = newValue;
                _updateUserSettings(_userSettingsData);
              },
            ),
          if (currentPrayer.voiceOptions.isNotEmpty)
            ListTile(
              title: const Text(SELECT_VOICE),
              subtitle: Text(_userSettingsData.voiceChoice),
              trailing: DropdownButton<String>(
                value: _userSettingsData.voiceChoice,
                onChanged: (newValue) {
                  if (newValue != null) {
                    _userSettingsData.voiceChoice = newValue;
                    _updateUserSettings(_userSettingsData);
                  }
                },
                items: currentPrayer.voiceOptions
                    .map((voice) => DropdownMenuItem(
                          value: voice,
                          child: Text(voice),
                        ))
                    .toList(),
              ),
            ),
          if (currentPrayer.voiceOptions.isNotEmpty)
            SwitchListTile(
              title: const Text(ENABLE_SOUND),
              value: _userSettingsData.prayerSoundEnabled,
              onChanged: (newValue) {
                _userSettingsData.prayerSoundEnabled = newValue;
                _updateUserSettings(_userSettingsData);
              },
            )
          else
            ListTile(
              title: const Text(ENABLE_SOUND),
              subtitle: const Text(DISABLED_FOR_THIS_PRAYER),
              trailing: Switch(
                value: _userSettingsData.prayerSoundEnabled,
                onChanged: null),
            ),
          ListTile(
            title: const Text(PRAYER_LENGTH),
            subtitle: Text("${_userSettingsData.prayerLength} minutes"),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    int tempLength = _userSettingsData.prayerLength;
                    return AlertDialog(
                      title: const Text(SET_PRAYER_LENGTH),
                      content: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Slider(
                                value: tempLength.toDouble(),
                                min: currentPrayer.minTimeInMinutes.toDouble(),
                                max: 60,
                                divisions: 60 - currentPrayer.minTimeInMinutes,
                                label: "$tempLength $MINUTES",
                                onChanged: (value) {
                                  setState(() {
                                    tempLength = value.toInt();
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(CANCEL),
                        ),
                        TextButton(
                          onPressed: () {
                            _userSettingsData.prayerLength = tempLength;
                            _updateUserSettings(_userSettingsData);
                            Navigator.pop(context);
                          },
                          child: const Text(SAVE),
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
            child: const Text(MORE_SETTINGS),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrayerPage(prayer: currentPrayer, userSettingsData: _userSettingsData, dataManager: widget.dataManager),
                ),
              );
            },
            child: const Text(START_PRAYER),
          ),
        ],
      ),
    );
  }
}